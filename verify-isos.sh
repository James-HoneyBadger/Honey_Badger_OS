#!/bin/bash

# Honey Badger OS - ISO Verification Script
# Shows all available ISO images with details

echo "🦡 Honey Badger OS - Available ISOs"
echo "==================================="
echo

if [ -d "/home/james/Honey_Badger_OS/ISOs" ]; then
    cd /home/james/Honey_Badger_OS/ISOs
    
    echo "📍 Location: $(pwd)"
    echo
    
    echo "📀 ARM64 (AArch64) ISOs:"
    if [ -d "aarch64" ]; then
        for iso in aarch64/*.iso; do
            if [ -f "$iso" ]; then
                size=$(du -h "$iso" | cut -f1)
                echo "  ✅ $iso ($size)"
            fi
        done
    else
        echo "  ❌ No ARM64 ISOs found"
    fi
    
    echo
    echo "📀 x86_64 ISOs:"
    if [ -d "x86_64" ]; then
        for iso in x86_64/*.iso; do
            if [ -f "$iso" ]; then
                size=$(du -h "$iso" | cut -f1)
                echo "  ✅ $iso ($size)"
            fi
        done
    else
        echo "  ❌ No x86_64 ISOs found"
    fi
    
    echo
    echo "📊 Total ISOs: $(find . -name "*.iso" | wc -l)"
    echo "💾 Total Size: $(du -h . | tail -1 | cut -f1)"
    
else
    echo "❌ ISOs directory not found!"
    exit 1
fi

echo
echo "🚀 Usage:"
echo "  ARM64 (Recommended): qemu-system-aarch64 -M virt -m 2G -cpu cortex-a57 -cdrom ISOs/aarch64/honey-badger-os-themed-20251101.iso"
echo "  x86_64 (Demo):       qemu-system-x86_64 -m 2G -cdrom ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso"
echo