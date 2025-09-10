#!/bin/bash

# Pi-hole Installer - wget equivalent
# This script downloads and executes the Pi-hole installation script
# Equivalent to: curl -sSL https://install.pi-hole.net | bash

set -euo pipefail

# Get script directory for loading config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
if [[ -f "$SCRIPT_DIR/config.sh" ]]; then
    # shellcheck source=config.sh
    source "$SCRIPT_DIR/config.sh"
else
    # Fallback configuration if config.sh not found
    PIHOLE_INSTALL_URL="https://install.pi-hole.net"
    DOWNLOAD_TIMEOUT=30
    NETWORK_RETRIES=3
    MAX_DOWNLOAD_SIZE="10M"
    VERIFY_SSL=true
    CHECK_SYSTEM_COMPATIBILITY=true
fi

# Runtime variables
TEMP_DIR="/tmp/pihole-installer-$$"
SCRIPT_NAME="pihole-install.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to cleanup temporary files
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        print_status "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set up trap to cleanup on exit
trap cleanup EXIT

# Function to check if required tools are available
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v wget >/dev/null 2>&1; then
        missing_deps+=("wget")
    fi
    
    if ! command -v bash >/dev/null 2>&1; then
        missing_deps+=("bash")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Please install the missing dependencies and try again."
        exit 1
    fi
    
    print_status "All dependencies satisfied."
}

# Function to download the Pi-hole installation script
download_script() {
    print_status "Creating temporary directory..."
    mkdir -p "$TEMP_DIR"
    
    print_status "Downloading Pi-hole installation script from $PIHOLE_INSTALL_URL..."
    
    # Prepare wget options based on configuration
    local wget_opts=()
    wget_opts+=("--timeout=$DOWNLOAD_TIMEOUT")
    wget_opts+=("--tries=$NETWORK_RETRIES")
    wget_opts+=("--max-filesize=$MAX_DOWNLOAD_SIZE")
    wget_opts+=("--progress=bar:force")
    
    if [[ "$VERIFY_SSL" == "true" ]]; then
        wget_opts+=("--check-certificate")
    else
        wget_opts+=("--no-check-certificate")
        print_warning "SSL certificate verification is disabled"
    fi
    
    # Add user agent
    wget_opts+=("--user-agent=Pi-hole-Installer-wget/1.0")
    
    # Perform download with enhanced error handling
    if ! wget "${wget_opts[@]}" -O "$TEMP_DIR/$SCRIPT_NAME" "$PIHOLE_INSTALL_URL"; then
        print_error "Failed to download Pi-hole installation script"
        
        # Try backup URL if available
        if [[ -n "${PIHOLE_BACKUP_URL:-}" ]]; then
            print_status "Trying backup URL: $PIHOLE_BACKUP_URL"
            if wget "${wget_opts[@]}" -O "$TEMP_DIR/$SCRIPT_NAME" "$PIHOLE_BACKUP_URL"; then
                print_status "Successfully downloaded from backup URL"
            else
                print_error "Backup download also failed"
                exit 1
            fi
        else
            exit 1
        fi
    else
        print_status "Download completed successfully."
    fi
    
    # Check file size
    local file_size
    file_size=$(stat -f%z "$TEMP_DIR/$SCRIPT_NAME" 2>/dev/null || stat -c%s "$TEMP_DIR/$SCRIPT_NAME" 2>/dev/null)
    print_status "Downloaded file size: $file_size bytes"
}

# Function to verify the downloaded script
verify_script() {
    print_status "Verifying downloaded script..."
    
    if [[ ! -f "$TEMP_DIR/$SCRIPT_NAME" ]]; then
        print_error "Downloaded script not found"
        exit 1
    fi
    
    if [[ ! -s "$TEMP_DIR/$SCRIPT_NAME" ]]; then
        print_error "Downloaded script is empty"
        exit 1
    fi
    
    # Check if it looks like a valid shell script
    if ! head -1 "$TEMP_DIR/$SCRIPT_NAME" | grep -q "^#!.*sh"; then
        print_warning "Script doesn't start with a proper shebang"
    fi
    
    print_status "Script verification completed."
}

# Function to execute the Pi-hole installation script
execute_script() {
    print_status "Executing Pi-hole installation script..."
    print_warning "This will install Pi-hole on your system."
    
    # Make the script executable
    chmod +x "$TEMP_DIR/$SCRIPT_NAME"
    
    # Execute the script
    bash "$TEMP_DIR/$SCRIPT_NAME" "$@"
}

# Main function
main() {
    print_status "Pi-hole Installer (wget equivalent) starting..."
    print_status "This script will download and execute the Pi-hole installation."
    
    # Load user configuration if available
    if declare -f load_user_config >/dev/null 2>&1; then
        load_user_config
    fi
    
    # Validate configuration
    if declare -f validate_config >/dev/null 2>&1; then
        if ! validate_config; then
            print_error "Configuration validation failed"
            exit 1
        fi
    fi
    
    # Check system requirements
    if declare -f check_system_requirements >/dev/null 2>&1; then
        if ! check_system_requirements; then
            print_error "System requirements check failed"
            exit 1
        fi
    fi
    
    check_dependencies
    download_script
    verify_script
    execute_script "$@"
    
    print_status "Pi-hole installation process completed."
}

# Show help information
show_help() {
    cat << EOF
Pi-hole Installer - wget equivalent

This script downloads and executes the Pi-hole installation script.
It's equivalent to running: curl -sSL https://install.pi-hole.net | bash

Usage: $0 [OPTIONS]

OPTIONS:
  -h, --help     Show this help message
  --dry-run      Download and verify script but don't execute it
  
All other options will be passed to the Pi-hole installer script.

Examples:
  $0                    # Standard installation
  $0 --help            # Show this help
  $0 --dry-run         # Download but don't install
  $0 --unattended      # Unattended installation (passed to Pi-hole installer)

EOF
}

# Parse command line arguments
if [[ $# -gt 0 ]]; then
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --dry-run)
            print_status "Dry run mode - will not execute installation"
            check_dependencies
            download_script
            verify_script
            print_status "Dry run completed. Script downloaded to: $TEMP_DIR/$SCRIPT_NAME"
            print_status "To manually execute: bash $TEMP_DIR/$SCRIPT_NAME"
            exit 0
            ;;
    esac
fi

# Run main function with all arguments
main "$@"
