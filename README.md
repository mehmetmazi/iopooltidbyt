# iopool Tidbyt Applet

Display your spa/pool water quality (temperature, pH, ORP) on your Tidbyt device.

## Setup

1. **Set environment variables:**

   ```bash
   export TIDBYT_DEVICE_ID="your-device-id"
   export TIDBYT_API_TOKEN="your-api-token"
   export IOPOOL_API_KEY="your-iopool-api-key"
   ```

   Or create a `.env` file (see `.env.example`) and source it:
   ```bash
   source .env
   ```

2. **Deploy:**

   ```bash
   ./deploy.sh
   ```

## Getting Your Credentials

- **Tidbyt Device ID**: Tidbyt app → Settings → Your Device → Device ID
- **Tidbyt API Token**: Tidbyt app → Settings → Developer → API Token
- **iopool API Key**: iopool app settings

## Features

- Near real-time updates (1 minute cache)
- Color-coded status indicators:
  - 🟢 Green: Ideal values
  - 🟡 Yellow: Acceptable range
  - 🔴 Red: Needs attention
- Automatic fallback to cached data if API is unavailable
- Stale data indicator (orange box)

## Security Note

**Never commit sensitive credentials to version control!**
- Use environment variables
- Add `.env` to `.gitignore`
- Keep your API tokens secure

