#!/bin/bash
# Simple script to fix TLS and deploy - run this in your terminal

echo "🔧 Fixing TLS certificate issue..."
echo ""
echo "Step 1: Fixing Homebrew permissions (enter your password when prompted)"
sudo chown -R $(whoami) /usr/local/Cellar

echo ""
echo "Step 2: Updating Homebrew..."
brew update

echo ""
echo "Step 3: Upgrading pixlet..."
brew upgrade pixlet

echo ""
echo "Step 4: Testing applet rendering..."
cd "$(dirname "$0")"
pixlet render iopool.star api_key=oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk -o iopool_output.webp

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ TLS issue fixed! Now deploying..."
    echo ""
    ./deploy.sh
else
    echo ""
    echo "❌ TLS issue persists. The applet will work when installed via Tidbyt app."
fi

