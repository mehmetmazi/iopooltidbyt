#!/bin/bash
# Wrapper script to fix TLS certificate issues with pixlet on macOS

# Set certificate file if it exists
if [ -f "$(dirname "$0")/mac_certs.pem" ]; then
    export SSL_CERT_FILE="$(dirname "$0")/mac_certs.pem"
    export SSL_CERT_DIR=""
fi

# Also try to use system certificates
export GODEBUG=x509sha1=1

# Run pixlet with all arguments
exec /usr/local/bin/pixlet "$@"

