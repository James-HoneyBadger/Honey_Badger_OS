# Makefile for Honey Badger OS
# Provides convenient targets for building the distribution

.PHONY: help setup build clean install-deps check test

# Default target
all: help

# Configuration
PROJECT_ROOT := $(CURDIR)
BUILD_DIR := $(PROJECT_ROOT)/build
SCRIPTS_DIR := $(PROJECT_ROOT)/scripts
CONFIG_FILE := $(PROJECT_ROOT)/config/honey-badger-os.conf

help:
	@echo "Honey Badger OS Build System"
	@echo "============================"
	@echo ""
	@echo "Available targets:"
	@echo "  setup        - Set up build environment and install dependencies"
	@echo "  check        - Check system requirements and configuration"
	@echo "  build        - Build the ISO image (requires root)"
	@echo "  clean        - Clean build artifacts"
	@echo "  install-deps - Install build dependencies only"
	@echo "  test         - Test the build configuration"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make setup   # First time setup"
	@echo "  make check   # Verify everything is ready"
	@echo "  sudo make build  # Build the ISO"
	@echo ""

setup:
	@echo "Setting up Honey Badger OS build environment..."
	$(SCRIPTS_DIR)/setup.sh

check:
	@echo "Checking build requirements..."
	@bash -c 'source $(CONFIG_FILE) && echo "Configuration loaded: $$DISTRO_NAME $$DISTRO_VERSION"'
	@echo "Checking dependencies..."
	@which debootstrap > /dev/null || (echo "ERROR: debootstrap not found. Run 'make setup' first." && exit 1)
	@which live-build > /dev/null || (echo "ERROR: live-build not found. Run 'make setup' first." && exit 1)
	@echo "All checks passed!"

build:
	@echo "Building Honey Badger OS ISO..."
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "ERROR: Build must be run as root. Use 'sudo make build'"; \
		exit 1; \
	fi
	$(SCRIPTS_DIR)/build-iso.sh

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)/iso/*
	rm -rf $(BUILD_DIR)/tmp/*
	rm -rf $(PROJECT_ROOT)/live-build/.build
	rm -rf $(PROJECT_ROOT)/live-build/binary*
	rm -rf $(PROJECT_ROOT)/live-build/cache
	rm -rf $(PROJECT_ROOT)/live-build/chroot*
	@echo "Build artifacts cleaned."

install-deps:
	@echo "Installing build dependencies..."
	sudo apt-get update
	sudo apt-get install -y \
		build-essential \
		debootstrap \
		squashfs-tools \
		xorriso \
		isolinux \
		syslinux-efi \
		grub-pc-bin \
		grub-efi-amd64-bin \
		grub-efi-arm64-bin \
		mtools \
		dosfstools \
		live-build \
		wget \
		curl \
		rsync \
		git \
		qemu-user-static \
		binfmt-support

test:
	@echo "Testing build configuration..."
	@echo "Validating package lists..."
	@for list in $(PROJECT_ROOT)/packages/*.list; do \
		echo "Checking $$list..."; \
		grep -v '^#' "$$list" | grep -v '^$$' | while read pkg; do \
			if [ -n "$$pkg" ]; then \
				echo "  - $$pkg"; \
			fi; \
		done; \
	done
	@echo "Configuration test completed."

# Development targets
dev-setup:
	@echo "Setting up development environment..."
	git config --local core.autocrlf input
	git config --local pull.rebase true
	@echo "Development environment ready."

# Package management
update-packages:
	@echo "Updating package information..."
	@echo "This would typically update package versions in the lists"
	@echo "based on the latest available versions."

# ISO verification
verify-iso:
	@echo "Verifying ISO image..."
	@if [ -f "$(BUILD_DIR)/iso/honey-badger-os-1.0-arm64.iso" ]; then \
		echo "ISO found: $(BUILD_DIR)/iso/honey-badger-os-1.0-arm64.iso"; \
		ls -lh "$(BUILD_DIR)/iso/honey-badger-os-1.0-arm64.iso"; \
		file "$(BUILD_DIR)/iso/honey-badger-os-1.0-arm64.iso"; \
	else \
		echo "ERROR: ISO not found. Run 'make build' first."; \
		exit 1; \
	fi