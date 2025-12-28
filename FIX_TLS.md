# Fix TLS Certificate Error for Pixlet

The TLS error (`x509: OSStatus -26276`) occurs because pixlet (a Go application) can't find macOS system certificates.

## Solution 1: Reinstall Pixlet via Homebrew (Recommended)

This is the easiest solution as Homebrew-installed versions handle certificates better:

```bash
# Remove current pixlet installation
rm /usr/local/bin/pixlet

# Install via Homebrew
brew install tidbyt/tap/pixlet

# Test it
pixlet render iopool.star api_key=YOUR_API_KEY -o test.webp
```

## Solution 2: Set SSL Certificate Environment Variable

Export macOS certificates and point pixlet to them:

```bash
# Export certificates from macOS Keychain
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > ~/mac_certs.pem

# Set environment variable before running pixlet
export SSL_CERT_FILE=~/mac_certs.pem
export SSL_CERT_DIR=""

# Then run pixlet
pixlet render iopool.star api_key=YOUR_API_KEY -o test.webp
```

## Solution 3: Update System Certificates

Sometimes macOS certificates need updating:

```bash
# Update Homebrew certificates (if using Homebrew)
brew update

# Or manually update certificates via System Preferences
# System Preferences > Software Update
```

## Solution 4: Use Homebrew's OpenSSL

If you have Homebrew, ensure OpenSSL is properly linked:

```bash
brew install openssl
brew link openssl --force
```

## Quick Test

After applying any solution, test with:

```bash
pixlet render iopool.star api_key=oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk -o iopool_output.webp
```

## Note

If you're deploying to Tidbyt, this local TLS error won't affect the deployed applet - Tidbyt's environment handles certificates correctly.

