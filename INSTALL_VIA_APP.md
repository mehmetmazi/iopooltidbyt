# Installing iopool Applet via Tidbyt iOS App

## Current Situation

When you use `pixlet push`, the applet appears in your device rotation but **does NOT show up** in the "Apps" list in the Tidbyt iOS app. This is because `pixlet push` sends a static rendered image, not an installable app.

## To Make It Show Up in the Apps List

You have two options:

### Option 1: Install via URL (if supported)

1. Host your `iopool.star` file somewhere accessible (GitHub, Dropbox, etc.)
2. In Tidbyt iOS app, go to **Apps** → **Add App** → **Install from URL**
3. Enter the URL to your `iopool.star` file
4. Configure the API key when prompted
5. The applet will now show up in your Apps list and can be managed

### Option 2: Publish to Community App Store

1. Create an app manifest:
   ```bash
   pixlet community create-manifest
   ```

2. Submit to the [Tidbyt community apps repository](https://github.com/tidbyt/community)
   - Fork the repo
   - Add your files (iopool.star, app.yaml, iopool.webp)
   - Submit a pull request

3. Once approved, it will be available in the Community Apps section
4. Install it through the Tidbyt app like any other community app

### Option 3: Keep Using `pixlet push` (Current Method)

**Pros:**
- ✅ Works immediately
- ✅ Full control over updates
- ✅ No approval process needed

**Cons:**
- ❌ Doesn't show in Apps list
- ❌ Can't manage through the app
- ❌ Need to manually update via script

**To see it on your device:**
- It should appear in the rotation automatically
- Check your device rotation settings in the Tidbyt app
- It may be named "iopoolspa" (the installation ID)

## Recommendation

If you want it to show up in the Apps list, go with **Option 2** (Community App Store) for the best experience. Otherwise, the current `pixlet push` method works fine - you just won't see it in the Apps list, but it will appear in your device rotation.

