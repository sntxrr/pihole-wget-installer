#!/bin/bash

# Pi-hole Installer Configuration
# This file contains safety settings and configuration options

# URL Configuration
PIHOLE_INSTALL_URL="https://install.pi-hole.net"
PIHOLE_BACKUP_URL="https://github.com/pi-hole/pi-hole/raw/master/automated%20install/basic-install.sh"

# Safety Configuration
VERIFY_SSL=true
MAX_DOWNLOAD_SIZE="10M"  # Maximum allowed download size
REQUIRE_CONFIRMATION=false
ALLOW_ROOT=true
CHECK_SYSTEM_COMPATIBILITY=true

# Timeout Configuration (in seconds)
DOWNLOAD_TIMEOUT=30
NETWORK_RETRIES=3
CONNECTION_TIMEOUT=10

# Checksum verification (when available)
ENABLE_CHECKSUM_VERIFICATION=false
# Note: Pi-hole doesn't provide checksums, but this could be extended
# EXPECTED_SHA256=""

# Logging Configuration
LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR
LOG_TO_FILE=false
LOG_FILE="/tmp/pihole-installer.log"

# System Requirements Check
MIN_DISK_SPACE_MB=1024  # 1GB
MIN_RAM_MB=512          # 512MB

# Supported Operating Systems
SUPPORTED_OS=(
    "ubuntu"
    "debian" 
    "raspbian"
    "centos"
    "fedora"
    "rhel"
)

# Function to load user configuration
load_user_config() {
    local user_config_file="$HOME/.pihole-installer.conf"
    
    if [[ -f "$user_config_file" ]]; then
        print_status "Loading user configuration from $user_config_file"
        # shellcheck source=/dev/null
        source "$user_config_file"
    fi
}

# Function to validate configuration
validate_config() {
    # Validate URLs
    if [[ ! "$PIHOLE_INSTALL_URL" =~ ^https?:// ]]; then
        print_error "Invalid PIHOLE_INSTALL_URL: must start with http:// or https://"
        return 1
    fi
    
    # Validate timeouts
    if [[ ! "$DOWNLOAD_TIMEOUT" =~ ^[0-9]+$ ]] || [[ "$DOWNLOAD_TIMEOUT" -lt 5 ]]; then
        print_error "Invalid DOWNLOAD_TIMEOUT: must be a number >= 5"
        return 1
    fi
    
    if [[ ! "$NETWORK_RETRIES" =~ ^[0-9]+$ ]] || [[ "$NETWORK_RETRIES" -lt 1 ]]; then
        print_error "Invalid NETWORK_RETRIES: must be a number >= 1"
        return 1
    fi
    
    return 0
}

# Function to check system requirements
check_system_requirements() {
    if [[ "$CHECK_SYSTEM_COMPATIBILITY" != "true" ]]; then
        return 0
    fi
    
    print_status "Checking system requirements..."
    
    # Check available disk space
    local available_space
    available_space=$(df /tmp | awk 'NR==2 {print $4}')
    local available_mb=$((available_space / 1024))
    
    if [[ "$available_mb" -lt "$MIN_DISK_SPACE_MB" ]]; then
        print_error "Insufficient disk space: ${available_mb}MB available, ${MIN_DISK_SPACE_MB}MB required"
        return 1
    fi
    
    # Check available RAM
    if command -v free >/dev/null 2>&1; then
        local available_ram
        available_ram=$(free -m | awk 'NR==2{printf "%.0f", $7}')
        
        if [[ "$available_ram" -lt "$MIN_RAM_MB" ]]; then
            print_warning "Low available RAM: ${available_ram}MB available, ${MIN_RAM_MB}MB recommended"
        fi
    fi
    
    # Check OS compatibility
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        local os_id="${ID,,}"  # Convert to lowercase
        local os_supported=false
        
        for supported in "${SUPPORTED_OS[@]}"; do
            if [[ "$os_id" == "$supported" ]]; then
                os_supported=true
                break
            fi
        done
        
        if [[ "$os_supported" != "true" ]]; then
            print_warning "Operating system '$ID' may not be officially supported by Pi-hole"
            print_warning "Supported systems: ${SUPPORTED_OS[*]}"
        else
            print_status "Operating system '$ID' is supported"
        fi
    fi
    
    print_status "System requirements check completed"
    return 0
}
