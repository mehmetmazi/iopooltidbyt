# Fix TLS Issue - Quick Instructions

## Run this command in your terminal:

```bash
cd /Users/mehmet/Library/CloudStorage/Dropbox/Coding/iopooltidbyt
./fix_tls_and_deploy.sh
```

This script will:
1. Fix Homebrew permissions (asks for your password)
2. Update Homebrew
3. Upgrade pixlet to the latest version
4. Test rendering your applet
5. Deploy to your Tidbyt device

## Alternative: Manual Steps

If the script doesn't work, run these commands manually:

```bash
# 1. Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/Cellar

# 2. Update and upgrade pixlet
brew update
brew upgrade pixlet

# 3. Test rendering
cd /Users/mehmet/Library/CloudStorage/Dropbox/Coding/iopooltidbyt
pixlet render iopool.star api_key=YOUR_IOPOOL_API_KEY -o iopool_output.webp

# 4. If still having issues, try certificate workaround:
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > ~/mac_certs.pem
export SSL_CERT_FILE=~/mac_certs.pem
export SSL_CERT_DIR=""
pixlet render iopool.star api_key=YOUR_IOPOOL_API_KEY -o iopool_output.webp

# 5. Deploy to Tidbyt
./deploy.sh
```

## Note

If the TLS issue persists locally, don't worry! When you install the applet through the Tidbyt mobile app, it will work perfectly because Tidbyt's servers don't have this certificate issue.

