# Pi-hole Installer Makefile

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
INSTALL_NAME = pihole-installer

.PHONY: help install uninstall test clean dry-run

help: ## Show this help message
	@echo "Pi-hole Installer - wget equivalent"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install the script to system PATH
	@echo "Installing pihole-installer to $(BINDIR)..."
	@mkdir -p $(BINDIR)
	@cp install-pihole.sh $(BINDIR)/$(INSTALL_NAME)
	@chmod +x $(BINDIR)/$(INSTALL_NAME)
	@echo "Installation complete. You can now run: $(INSTALL_NAME)"

uninstall: ## Remove the installed script
	@echo "Uninstalling pihole-installer from $(BINDIR)..."
	@rm -f $(BINDIR)/$(INSTALL_NAME)
	@echo "Uninstallation complete."

test: ## Run basic tests on the script
	@echo "Running basic tests..."
	@bash -n install-pihole.sh && echo "✓ Syntax check passed"
	@./install-pihole.sh --help >/dev/null && echo "✓ Help option works"
	@echo "All tests passed!"

dry-run: ## Run a dry-run to test download functionality
	@echo "Running dry-run test..."
	@./install-pihole.sh --dry-run

clean: ## Clean up any temporary files
	@echo "Cleaning up temporary files..."
	@rm -rf /tmp/pihole-installer-*
	@echo "Cleanup complete."

version: ## Show version information
	@echo "Pi-hole Installer (wget equivalent) v1.0.0"
	@echo "A safer alternative to: curl -sSL https://install.pi-hole.net | bash"
