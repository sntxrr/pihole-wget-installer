# Pi-hole Installer - wget equivalent

A secure, configurable alternative to `curl -sSL https://install.pi-hole.net | bash` that uses wget for downloading and provides enhanced safety features.

## Overview

This project provides a safer way to install Pi-hole by:
- Using `wget` instead of `curl` for better error handling and progress indication
- Implementing comprehensive safety checks and validation
- Providing configuration options for security-conscious users
- Offering a dry-run mode to inspect scripts before execution
- Including system compatibility checks

## Features

- ✅ **Enhanced Safety**: Downloads to a temporary location before execution
- ✅ **Configuration Support**: Customizable settings via config files
- ✅ **System Checks**: Validates system requirements before installation
- ✅ **Progress Indicators**: Clear status messages and download progress
- ✅ **Dry-run Mode**: Preview downloads without executing
- ✅ **Backup URL Support**: Fallback to alternative download sources
- ✅ **SSL Verification**: Configurable certificate validation
- ✅ **Error Handling**: Comprehensive error reporting and recovery
- ✅ **Universal Compatibility**: Works with all wget versions across different systems

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/pihole-wget-installer.git
cd pihole-wget-installer

# Run the installer
./install-pihole.sh
```

## Installation Options

### Method 1: Direct execution
```bash
./install-pihole.sh
```

### Method 2: System-wide installation
```bash
make install
# Now you can run: pihole-installer
```

### Method 3: Dry-run (recommended first)
```bash
./install-pihole.sh --dry-run
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `--help`, `-h` | Show help information |
| `--dry-run` | Download and verify script without executing |
| `--unattended` | Run Pi-hole installer in unattended mode |

All other options are passed directly to the Pi-hole installation script.

## Configuration

### Global Configuration
The `config.sh` file contains system-wide settings:

```bash
# URL Configuration
PIHOLE_INSTALL_URL="https://install.pi-hole.net"
PIHOLE_BACKUP_URL="https://github.com/pi-hole/pi-hole/raw/master/automated%20install/basic-install.sh"

# Safety Configuration  
VERIFY_SSL=true
MAX_DOWNLOAD_SIZE="10M"
CHECK_SYSTEM_COMPATIBILITY=true

# Timeout Configuration
DOWNLOAD_TIMEOUT=30
NETWORK_RETRIES=3
```

### User Configuration
Create a personal configuration file at `~/.pihole-installer.conf`:

```bash
# Example user configuration
VERIFY_SSL=false           # Disable SSL verification if needed
REQUIRE_CONFIRMATION=true  # Ask before executing
MAX_DOWNLOAD_SIZE="20M"    # Allow larger downloads
```

## Safety Features

### 1. Download Verification
- Validates downloaded file size and content
- Checks for proper shell script format
- Supports backup URL fallback

### 2. System Requirements Check
- Validates available disk space (1GB minimum)
- Checks available RAM (512MB recommended)
- Verifies OS compatibility

### 3. Secure Execution
- Downloads to isolated temporary directory
- Automatic cleanup on exit
- Configurable SSL certificate verification

### 4. Error Handling
- Comprehensive error messages
- Network retry logic
- Graceful failure recovery

## Supported Operating Systems

- Ubuntu
- Debian
- Raspbian  
- CentOS
- Fedora
- RHEL

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make help` | Show available targets |
| `make install` | Install script system-wide |
| `make uninstall` | Remove installed script |
| `make test` | Run basic functionality tests |
| `make dry-run` | Perform a dry-run installation |
| `make clean` | Clean temporary files |
| `make version` | Show version information |

## Security Considerations

### Why use this instead of curl?

1. **Inspection**: The `--dry-run` option allows you to download and inspect the script before execution
2. **Validation**: Built-in checks verify the downloaded script's integrity
3. **Configuration**: Customizable security settings for different environments
4. **Transparency**: Clear progress indication and status messages
5. **Recovery**: Backup URL support and retry logic

### Best Practices

1. **Always run dry-run first**:
   ```bash
   ./install-pihole.sh --dry-run
   ```

2. **Review the downloaded script**:
   ```bash
   # After dry-run, inspect the script
   less /tmp/pihole-installer-*/pihole-install.sh
   ```

3. **Use configuration files** for repeated installations:
   ```bash
   # Create ~/.pihole-installer.conf with your settings
   echo "VERIFY_SSL=true" > ~/.pihole-installer.conf
   echo "REQUIRE_CONFIRMATION=true" >> ~/.pihole-installer.conf
   ```

4. **Test in a safe environment** before production deployment

## Troubleshooting

### Common Issues

**Download Fails with SSL Error**:
```bash
# Temporarily disable SSL verification
echo "VERIFY_SSL=false" > ~/.pihole-installer.conf
./install-pihole.sh
```

**Insufficient Disk Space**:
```bash
# Clean up temporary files
make clean
# Or manually: rm -rf /tmp/pihole-installer-*
```

**OS Not Supported Warning**:
```bash
# Override compatibility check
echo "CHECK_SYSTEM_COMPATIBILITY=false" > ~/.pihole-installer.conf
```

**wget Version Compatibility**:
The script automatically adapts to different wget versions by:
- Using only universally supported options (--timeout, --tries, --no-check-certificate)
- Implementing manual file size checking for older wget versions
- Providing cross-platform file size detection (BSD/GNU stat compatibility)

### Debug Mode

Enable detailed logging by modifying `config.sh`:
```bash
LOG_LEVEL="DEBUG"
LOG_TO_FILE=true
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test with `make test`
5. Submit a pull request

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## Comparison with curl method

| Feature | `curl -sSL \| bash` | This Tool |
|---------|---------------------|-----------|
| Download method | curl | wget |
| Progress indication | None | ✅ Progress bar |
| Pre-execution inspection | ❌ | ✅ Dry-run mode |
| Error handling | Basic | ✅ Comprehensive |
| Configuration | None | ✅ Configurable |
| System checks | None | ✅ Compatibility checks |
| SSL verification | Default | ✅ Configurable |
| Backup URLs | None | ✅ Fallback support |
| Cleanup | None | ✅ Automatic |

## Version History

- **v1.0.0**: Initial release with core functionality
  - wget-based downloading
  - Safety checks and validation
  - Configuration support
  - Dry-run mode

## Support

For issues and questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the Pi-hole documentation at https://docs.pi-hole.net/

---

**Note**: This tool is not officially affiliated with the Pi-hole project. It's a community-created enhancement to provide a safer installation method.
