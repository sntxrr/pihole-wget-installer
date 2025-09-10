# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a secure Pi-hole installer that provides a safer alternative to the traditional `curl -sSL https://install.pi-hole.net | bash` approach. The project uses `wget` instead of `curl` and implements comprehensive safety features, validation, and configuration options.

## Core Architecture

### Key Components

1. **Main Installer** (`install-pihole.sh`)
   - Entry point that orchestrates the entire installation process
   - Handles argument parsing, dry-run mode, and help display
   - Sources configuration and executes the download-verify-install pipeline

2. **Configuration System** (`config.sh`)
   - Centralized configuration with safety defaults
   - User configuration override support via `~/.pihole-installer.conf`
   - System requirements checking and OS compatibility validation
   - Configurable timeouts, SSL verification, and download limits

3. **Build System** (`Makefile`)
   - System-wide installation to `/usr/local/bin` as `pihole-installer`
   - Testing, cleanup, and dry-run targets
   - Version management

### Architecture Pattern

The installer follows a modular bash script architecture:
- **Configuration Loading**: `config.sh` defines defaults, user config overrides
- **Validation Pipeline**: Dependencies → System requirements → Configuration validation
- **Download Pipeline**: Primary URL → Backup URL fallback → Size/content verification
- **Execution Pipeline**: Make executable → Execute with user arguments → Cleanup

## Common Commands

### Development and Testing
```bash
# Test script syntax and basic functionality
make test

# Run dry-run to test download without execution
make dry-run
./install-pihole.sh --dry-run

# Clean temporary files
make clean
```

### Installation Methods
```bash
# Direct execution
./install-pihole.sh

# System-wide installation
make install
pihole-installer

# Unattended installation (passes flag to Pi-hole installer)
./install-pihole.sh --unattended
```

### Build and Maintenance
```bash
# Show available make targets
make help

# Show version information
make version

# Install system-wide
make install

# Remove system installation
make uninstall
```

## Configuration Architecture

The project uses a layered configuration system:

1. **Default Configuration** (`config.sh`) - Base settings
2. **User Configuration** (`~/.pihole-installer.conf`) - User overrides
3. **Runtime Configuration** - Command-line arguments and environment variables

### Key Configuration Categories
- **Safety Settings**: SSL verification, file size limits, system checks
- **Network Settings**: Timeouts, retries, connection limits
- **URL Configuration**: Primary and backup download URLs
- **System Requirements**: Disk space, RAM, OS compatibility

## Safety and Security Features

### Download Safety
- File size limits (`MAX_DOWNLOAD_SIZE`)
- SSL certificate verification (configurable)
- Backup URL fallback system
- Content validation (shebang checking)
- Temporary directory isolation with automatic cleanup

### System Validation
- Dependency checking (wget, bash availability)
- Disk space requirements (1GB minimum)
- RAM availability checks (512MB recommended)
- OS compatibility verification against supported list

### Execution Safety
- Dry-run mode for script inspection
- Comprehensive error handling with colored output
- Automatic cleanup on script exit (via trap)
- User confirmation options (configurable)

## Debugging and Troubleshooting

### Debug Mode
Enable detailed logging by modifying `config.sh`:
```bash
LOG_LEVEL="DEBUG"
LOG_TO_FILE=true
```

### Common Override Patterns
```bash
# Disable SSL verification temporarily
echo "VERIFY_SSL=false" > ~/.pihole-installer.conf

# Skip system compatibility checks
echo "CHECK_SYSTEM_COMPATIBILITY=false" > ~/.pihole-installer.conf

# Increase download size limit
echo "MAX_DOWNLOAD_SIZE=20M" > ~/.pihole-installer.conf
```

## Script Development Guidelines

### Error Handling
- Use `set -euo pipefail` for strict error handling
- Implement comprehensive cleanup via EXIT trap
- Provide colored, categorized output (INFO/WARN/ERROR)

### Configuration Loading Pattern
```bash
# Load base configuration
source "$SCRIPT_DIR/config.sh"

# Load user overrides if available
if declare -f load_user_config >/dev/null 2>&1; then
    load_user_config
fi

# Validate configuration
if declare -f validate_config >/dev/null 2>&1; then
    validate_config || exit 1
fi
```

### Dependency and System Checking
- Check tool availability before use
- Validate system resources (disk, RAM)
- Verify OS compatibility against supported list
- Fail gracefully with helpful error messages

## File Structure Context

- `install-pihole.sh` - Main executable entry point
- `config.sh` - Configuration definitions and validation functions
- `Makefile` - Build system with install/test/clean targets
- `README.md` - Comprehensive user documentation with examples
- `LICENSE` - MIT license

The project is designed as a single-purpose tool that can be used standalone or installed system-wide, with emphasis on security, configurability, and user safety compared to traditional curl-based installation methods.
