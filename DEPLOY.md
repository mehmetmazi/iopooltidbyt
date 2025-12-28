# Deploying iopool Applet to Tidbyt

There are two ways to deploy your applet:

## Option 1: Push Directly to Your Tidbyt Device (Quick Test)

This pushes the applet directly to your device for immediate use.

### Steps:

1. **Get your Tidbyt Device ID and API Token:**
   - Open the Tidbyt mobile app
   - Go to Settings → Your Device
   - Copy your Device ID
   - Go to Settings → Developer → API Token
   - Copy your API Token

2. **Render and push the applet:**
   ```bash
   cd /Users/mehmet/Library/CloudStorage/Dropbox/Coding/iopooltidbyt
   
   # First, render the applet with your API key
   pixlet render iopool.star api_key=oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk -o iopool_output.webp
   
   # Then push to your device
   pixlet push YOUR_DEVICE_ID iopool_output.webp --api-token=YOUR_API_TOKEN
   ```

3. **To keep it in rotation (recommended):**
   ```bash
   pixlet push YOUR_DEVICE_ID iopool_output.webp \
     --api-token=YOUR_API_TOKEN \
     --installation-id=iopoolspa
   ```

### Automate with a script:

You can create a script to automatically update the applet:

```bash
#!/bin/bash
# update_iotpool.sh

DEVICE_ID="YOUR_DEVICE_ID"
API_TOKEN="YOUR_API_TOKEN"
IOPOOL_API_KEY="oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk"

cd /Users/mehmet/Library/CloudStorage/Dropbox/Coding/iopooltidbyt

# Render
pixlet render iopool.star api_key=$IOPOOL_API_KEY -o iopool_output.webp

# Push
pixlet push $DEVICE_ID iopool_output.webp \
  --api-token=$API_TOKEN \
  --installation-id=iopool-spa
```

Run this script periodically (e.g., via cron) to keep your data updated.

---

## Option 2: Publish to Tidbyt Community App Store

This makes your applet available to all Tidbyt users.

### Steps:

1. **Create a manifest file** (app.yaml):
   ```bash
   pixlet community create-manifest
   ```
   Follow the prompts to create your manifest.

2. **Validate your app:**
   ```bash
   pixlet community load-app iopool.star
   pixlet community validate-manifest app.yaml
   ```

3. **Submit to the community repo:**
   - Fork the [Tidbyt community apps repository](https://github.com/tidbyt/community)
   - Add your app files (iopool.star, app.yaml, and any assets)
   - Submit a pull request

### Required files for community publishing:

- `iopool.star` - Your applet code ✅
- `app.yaml` - App manifest (create with `pixlet community create-manifest`)
- `iopool.webp` - App icon (you already have this) ✅

---

## Quick Start: Push to Device Now

If you want to test it immediately on your device:

```bash
cd /Users/mehmet/Library/CloudStorage/Dropbox/Coding/iopooltidbyt

# Replace with your actual values
DEVICE_ID="your-device-id-here"
API_TOKEN="your-api-token-here"

# Render and push
pixlet render iopool.star api_key=oMryXoKbRx7desfBkK7L698RaI4Q8zdV9sGhACHk -o iopool_output.webp
pixlet push $DEVICE_ID iopool_output.webp --api-token=$API_TOKEN --installation-id=iopool-spa
```

---

## Notes:

- The applet will automatically refresh data every 5 minutes (CACHE_TTL = 300)
- If the API fails, it will show cached data (up to 24 hours old)
- The stale indicator (orange box) appears when showing cached data
- Your API key is stored in the applet configuration, not hardcoded in the code

---

## Troubleshooting:

- **TLS errors locally**: These won't affect deployment to Tidbyt
- **Can't find device**: Make sure your device is online and you have the correct Device ID
- **API errors**: Check that your iopool API key is valid and has access to your pool

