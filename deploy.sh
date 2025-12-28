#!/bin/bash
# Quick deployment script for iopool Tidbyt applet

set -e

# Configuration - All values must be provided via environment variables
DEVICE_ID="${TIDBYT_DEVICE_ID}"
API_TOKEN="${TIDBYT_API_TOKEN}"
IOPOOL_API_KEY="${IOPOOL_API_KEY}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Deploying iopool applet to Tidbyt..."
echo ""

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
echo "📦 Rendering applet..."
pixlet render iopool.star api_key="$IOPOOL_API_KEY" -o iopool_output.webp

if [ $? -ne 0 ]; then
    echo "❌ Failed to render applet"
    exit 1
fi

echo "✅ Applet rendered successfully"
echo ""

# Push to device
echo "📤 Pushing to Tidbyt device..."
pixlet push "$DEVICE_ID" iopool_output.webp \
    --api-token="$API_TOKEN" \
    --installation-id=iopoolspa

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully deployed to your Tidbyt device!"
    echo "   The applet will appear in your device rotation."
else
    echo ""
    echo "❌ Failed to push to device"
    echo "   Check your Device ID and API Token"
    exit 1
fi

