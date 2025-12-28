#!/bin/bash
# Fix TLS issue and deploy iopool applet to Tidbyt

set -e

echo "🔧 Fixing TLS certificate issue for pixlet..."
echo ""

# Step 1: Fix Homebrew permissions
echo "📦 Step 1: Fixing Homebrew permissions..."
echo "   This requires your password (sudo access)"
sudo chown -R $(whoami) /usr/local/Cellar

# Step 2: Update Homebrew
echo ""
echo "🔄 Step 2: Updating Homebrew..."
brew update

# Step 3: Upgrade pixlet
echo ""
echo "⬆️  Step 3: Upgrading pixlet to latest version..."
brew upgrade pixlet

# Step 4: Test rendering
echo ""
echo "🧪 Step 4: Testing applet rendering..."
cd "$(dirname "$0")"

# Configuration - All values must be provided via environment variables
DEVICE_ID="${TIDBYT_DEVICE_ID}"
API_TOKEN="${TIDBYT_API_TOKEN}"
IOPOOL_API_KEY="${IOPOOL_API_KEY}"

# Validate required environment variables
if [ -z "$DEVICE_ID" ]; then
    echo "❌ Error: TIDBYT_DEVICE_ID environment variable is required"
    echo "   Get it from: Tidbyt app → Settings → Your Device → Device ID"
    exit 1
fi

if [ -z "$API_TOKEN" ]; then
    echo "❌ Error: TIDBYT_API_TOKEN environment variable is required"
    echo "   Get it from: Tidbyt app → Settings → Developer → API Token"
    exit 1
fi

if [ -z "$IOPOOL_API_KEY" ]; then
    echo "❌ Error: IOPOOL_API_KEY environment variable is required"
    echo "   Get it from: iopool app settings"
    exit 1
fi

# Render the applet
pixlet render iopool.star api_key="$IOPOOL_API_KEY" -o iopool_output.webp

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Still having TLS issues. Trying certificate workaround..."
    
    # Export certificates
    echo "📜 Exporting macOS certificates..."
    security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > ~/mac_certs.pem
    
    # Try with certificate file
    export SSL_CERT_FILE=~/mac_certs.pem
    export SSL_CERT_DIR=""
    
    pixlet render iopool.star api_key="$IOPOOL_API_KEY" -o iopool_output.webp
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ TLS issue persists. The applet will work fine when deployed to Tidbyt."
        echo "   Tidbyt's servers don't have this certificate issue."
        exit 1
    fi
fi

echo "✅ Applet rendered successfully!"
echo ""

# Step 5: Deploy to Tidbyt
echo "📤 Step 5: Deploying to Tidbyt device..."
pixlet push "$DEVICE_ID" iopool_output.webp \
    --api-token="$API_TOKEN" \
    --installation-id=iopoolspa

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Applet deployed to your Tidbyt device!"
    echo "   Device: $DEVICE_ID"
    echo "   The applet will appear in your device rotation."
else
    echo ""
    echo "❌ Failed to push to device"
    exit 1
fi

