# Post-Install Configuration Guide

This guide explains what happens during the post-install setup and how to configure applications, permissions, and extensions after the main Nix configuration is applied.

## Overview

The `post-install.sh` script handles configuration tasks that require user interaction or can't be automated through Nix:

1. **Zen Browser setup** - Profile injection and extension installation
2. **App permission requests** - Launching apps to trigger permission dialogs
3. **System Settings guidance** - Opening relevant settings panels

## When to Run Post-Install

Run the post-install script after:

1. **First-time installation** - After `install.sh` completes (it runs automatically)
2. **After applying configuration changes** - If you've updated apps or services
3. **Permission issues** - When apps need permission re-granting
4. **New macOS installation** - After restoring or setting up a new Mac

## Running Post-Install

```bash
cd ~/.config/nix
./scripts/post-install.sh
```

The script is interactive - you'll be prompted to press Enter at various stages.

## Step-by-Step Process

### Step 1: Zen Browser Setup

The script handles Zen Browser configuration specially because it requires a first-run wizard:

1. **Launch Zen Browser**
   - Script opens Zen Browser automatically
   - Complete the first-run wizard (choose defaults, import settings, etc.)
   - Press Enter in terminal when done

2. **Profile Data Injection**
   - Script closes Zen Browser temporarily
   - Copies saved profile data from `dotfiles/zen/profile/` to Zen's profile directory
   - Data includes:
     - Settings (`prefs.js`)
     - Keyboard shortcuts (`zen-keyboard-shortcuts.json`)
     - Themes (`zen-themes.json`)
     - Custom CSS (`chrome/`)
     - Containers (`containers.json`)
     - File handlers (`handlers.json`)

3. **Extension Installation**
   - Script reopens Zen Browser
   - Opens extension install pages in tabs:
     - uBlock Origin
     - Bitwarden Password Manager
     - Dark Reader
     - React DevTools
     - Facebook Container
     - Redirector
     - Multithreaded Download Manager
   - Click "Add to Firefox" on each tab to install
   - Press Enter when done

**Why this approach?**
- Zen Browser creates its profile during first launch
- We can't inject config until the profile exists
- Extensions must be installed manually via the Mozilla Add-ons site

### Step 2: System Settings Preparation

The script opens System Settings to the Accessibility panel:

- **Location:** System Settings → Privacy & Security → Accessibility
- **Purpose:** Ready for granting permissions as apps launch
- **Action required:** Keep this window open to grant permissions

### Step 3: App Launching (Batches)

Apps are launched in batches of 3 to avoid overwhelming permission dialogs:

**Batch 1 (Accessibility-critical apps):**
- Rectangle.app (window management)
- Sol.app (launcher)
- BetterDisplay.app (display management)

**Batch 2:**
- Stats.app (system monitor)
- Hidden Bar.app (menu bar cleaner)
- Docker.app (container runtime)

**Subsequent batches:**
- Tailscale.app, Ghostty.app, Obsidian.app, VS Code, Cursor, and more

**For each batch:**
1. Script launches 3 apps
2. Permission dialogs appear
3. Grant permissions in System Settings (Accessibility panel)
4. Press Enter to launch next batch

### Step 4: System Settings - Keyboard Shortcuts

The script opens Keyboard Shortcuts settings:

- **Location:** System Settings → Keyboard → Keyboard Shortcuts → Spotlight
- **Purpose:** Disable Spotlight shortcuts (using Sol launcher instead)
- **Action required:**
  - Disable "Show Spotlight search" (Cmd+Space)
  - Disable "Show Finder search window" (Cmd+Option+Space)

## Required Permissions

### Accessibility Permissions

These apps need Accessibility permission (System Settings → Privacy & Security → Accessibility):

- **Rectangle** - Window management
- **Sol** - Launcher and window control
- **BetterDisplay** - Display management
- **Stats** - System monitoring
- **Hidden Bar** - Menu bar management

### Network Permissions

- **Docker** - Network extension (prompted automatically)
- **Tailscale** - VPN connection (requires manual login)

### Optional Permissions

- **Sol** - Full Disk Access (for file search) - Optional but recommended

## Post-Install Checklist

After running the script, complete these steps:

### 1. Grant Accessibility Permissions

1. Open System Settings → Privacy & Security → Accessibility
2. Enable toggle for each app:
   - ☑ Rectangle
   - ☑ Sol
   - ☑ BetterDisplay
   - ☑ Stats
   - ☑ Hidden Bar

### 2. Configure Docker

1. Approve network extension when prompted
2. Start Docker Desktop
3. Complete initial setup if needed

### 3. Configure Tailscale

1. Click Tailscale menu bar icon
2. Sign in to your Tailscale account
3. Connect to your network

### 4. Configure BetterDisplay

1. Open BetterDisplay preferences
2. Remove from Login Items:
   - System Settings → General → Login Items
   - Find BetterDisplay and remove it
   - (The launchd agent handles cleanup instead)

### 5. Configure Hidden Bar

1. Hidden Bar appears in menu bar
2. Cmd+drag icons left of the `|` divider to hide them
3. Icons right of the divider remain visible

### 6. Install Zen Browser Extensions

1. For each extension tab opened:
   - Click "Add to Firefox" button
   - Confirm installation
2. Extensions will be available immediately

### 7. Disable Spotlight Shortcuts

1. System Settings → Keyboard → Keyboard Shortcuts → Spotlight
2. Uncheck:
   - ☐ Show Spotlight search
   - ☐ Show Finder search window

### 8. (Optional) Grant Full Disk Access to Sol

1. System Settings → Privacy & Security → Full Disk Access
2. Click the `+` button
3. Navigate to `/Applications/Nix Apps/Sol.app`
4. Add Sol
5. Restart Sol

## App-Specific Configuration

### Rectangle

Rectangle is a window manager with keyboard shortcuts:

- **Left half:** Cmd+Ctrl+Left
- **Right half:** Cmd+Ctrl+Right
- **Full screen:** Cmd+Ctrl+F
- **Center:** Cmd+Ctrl+C

Configure shortcuts in Rectangle preferences.

### Sol

Sol is a native Swift launcher (Spotlight alternative):

- **Launch:** Cmd+Space (after disabling Spotlight)
- **Features:** File search, app launching, calculations
- **Config:** Edit `dotfiles/` if you have custom Sol config

### Stats

Stats shows system metrics in the menu bar:

- **Click menu bar icon** to configure
- **Select metrics** to display (CPU, RAM, disk, network)
- **Preferences stored in:** `dotfiles/stats/eu.exelban.Stats.plist`

### Hidden Bar

Hidden Bar cleans up the menu bar:

- **Hidden items:** Left of the `|` divider
- **Visible items:** Right of the divider
- **Toggle:** Click the divider to show/hide

### Zen Browser

Zen Browser uses your saved profile:

- **Settings:** Applied from `dotfiles/zen/profile/prefs.js`
- **Themes:** Applied from `dotfiles/zen/profile/zen-themes.json`
- **Shortcuts:** Applied from `dotfiles/zen/profile/zen-keyboard-shortcuts.json`
- **Custom CSS:** From `dotfiles/zen/profile/chrome/`

**Not synced** (for privacy):
- Bookmarks
- History
- Passwords
- Cookies

### Redirector rules (manual import)

Redirector rules are stored in the repo at:

- `dotfiles/zen/Redirector.json`

During the Zen extensions step, the post-install script:

- Opens the Redirector extension install page in Zen.
- Opens a Finder window with `Redirector.json` selected.

To load your rules:

1. In Zen, open the Redirector extension’s options page.
2. Use the **Import** feature and select the `Redirector.json` file from the Finder window.
3. Any future changes you want to make permanent should be exported from Redirector and saved back to `dotfiles/zen/Redirector.json` in this repo.

## Troubleshooting

### Apps don't launch

**Problem:** Script can't open apps

**Solution:**
- Check apps are installed: `ls /Applications/AppName.app`
- Verify Homebrew/Nix apps are in expected locations
- Some apps may be in `/Applications/Nix Apps/`

### Permission dialogs don't appear

**Problem:** Apps launch but no permission requests

**Solution:**
- Quit and relaunch the app manually
- Some apps only request permissions when specific features are used
- Check System Settings to see if permission was auto-denied

### Zen Browser profile not applied

**Problem:** Settings not appearing in Zen

**Solution:**
- Ensure you completed the first-run wizard before pressing Enter
- Check profile directory exists: `ls ~/Library/Application\ Support/zen/`
- Manually copy files if needed:
  ```bash
  cp -r ~/.config/nix/dotfiles/zen/profile/* ~/Library/Application\ Support/zen/*/
  ```

### Extensions not installing

**Problem:** Can't install Zen extensions

**Solution:**
- Ensure you're signed in to Firefox account (if required)
- Try installing from the Add-ons website directly
- Some extensions may require Firefox account login

### Script hangs or freezes

**Problem:** Script stops responding

**Solution:**
- Press Ctrl+C to cancel
- Check if an app is waiting for input
- Run script again - it's safe to re-run

## Re-running Post-Install

The script is safe to run multiple times:

- Apps will just launch again (if already running, they may not show permission dialogs)
- Zen Browser setup only runs if profile doesn't exist
- No data is lost or overwritten unnecessarily

**When to re-run:**
- After adding new apps to the configuration
- If permissions were denied and need to be re-granted
- After macOS updates that reset permissions

## Customizing Post-Install

### Adding New Apps

Edit `scripts/post-install.sh` and add to the `APPS` array:

```bash
APPS=(
    # ... existing apps ...
    "/Applications/YourNewApp.app"
)
```

### Changing Batch Size

Edit `scripts/post-install.sh`:

```bash
BATCH_SIZE=5  # Change from 3 to 5
```

### Adding Extension URLs

Edit `scripts/post-install.sh` and add to the extension opening section:

```bash
open "https://addons.mozilla.org/firefox/addon/your-extension/"
sleep 0.3
```

## Related Documentation

- [Scripts Guide](./SCRIPTS.md) - How scripts work and execute
- [SSH Setup Guide](./SSH_SETUP.md) - SSH key configuration
- [Dotfiles Guide](./DOTFILES.md) - Managing configuration files
- [Main README](../README.md) - Overview of the configuration
