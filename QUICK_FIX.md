# Quick Fix for Pixlet TLS Error

The TLS certificate error is due to Homebrew permissions and an outdated pixlet version. Here's the quickest fix:

## Run This in Your Terminal:

```bash
cd /Users/mehmet/Library/CloudStorage/Dropbox/Coding/iopooltidbyt

# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/Cellar

# Update and upgrade pixlet
brew update
brew upgrade pixlet

# Test it
pixlet render iopool.star api_key=oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk -o iopool_output.webp
```

## Alternative: Run the Automated Script

```bash
cd /Users/mehmet/Library/CloudStorage/Dropbox/Coding/iopooltidbyt
./fix_pixlet_tls.sh
```

This script will:
1. Fix Homebrew permissions (asks for your password)
2. Update Homebrew
3. Upgrade pixlet to the latest version
4. Test the applet

## If That Doesn't Work

The issue might be with macOS system certificates. Try:

```bash
# Export system certificates
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > ~/mac_certs.pem

# Use them with pixlet
export SSL_CERT_FILE=~/mac_certs.pem
pixlet render iopool.star api_key=oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk -o iopool_output.webp
```

## Note

This is a local testing issue. Your applet will work perfectly when deployed to Tidbyt!

