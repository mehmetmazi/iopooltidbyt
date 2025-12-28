#!/bin/bash
# Script to fix TLS certificate issues with pixlet on macOS

set -e

echo "🔧 Fixing pixlet TLS certificate issue..."

# Step 1: Fix Homebrew permissions (if needed)
echo "📦 Checking Homebrew permissions..."
if [ ! -w /usr/local/Cellar ]; then
    echo "⚠️  Need to fix Homebrew permissions. Running: sudo chown -R $(whoami) /usr/local/Cellar"
    sudo chown -R $(whoami) /usr/local/Cellar
    echo "✅ Permissions fixed"
else
    echo "✅ Permissions OK"
fi

# Step 2: Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# Step 3: Upgrade pixlet to latest version
echo "⬆️  Upgrading pixlet..."
brew upgrade pixlet

# Step 4: Verify installation
echo "✅ Verifying pixlet installation..."
pixlet --help > /dev/null 2>&1 && echo "✅ Pixlet is working" || echo "❌ Pixlet not found"

# Step 5: Test with the applet
echo ""
echo "🧪 Testing pixlet with your applet..."
cd "$(dirname "$0")"
pixlet render iopool.star api_key=oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk -o iopool_output.webp

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! TLS issue is fixed!"
    echo "📁 Output saved to: iopool_output.webp"
else
    echo ""
    echo "❌ Still having issues. Trying alternative fix..."
    
    # Alternative: Export certificates and set environment variable
    echo "📜 Exporting macOS certificates..."
    security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > ~/mac_certs.pem
    
    echo ""
    echo "💡 To use the certificate workaround, run:"
    echo "   export SSL_CERT_FILE=~/mac_certs.pem"
    echo "   export SSL_CERT_DIR=\"\""
    echo "   pixlet render iopool.star api_key=YOUR_API_KEY -o output.webp"
fi

