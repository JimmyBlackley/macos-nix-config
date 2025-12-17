#!/bin/bash
# ==============================================================================
# POST-INSTALL SCRIPT
# ==============================================================================
# Launches apps that require manual permission grants and sets up dotfiles.
# Run this after `darwin-rebuild switch` to trigger all permission prompts.
# ==============================================================================

set -e

echo "=========================================="
echo "  macOS Post-Install Setup"
echo "=========================================="
echo ""
echo "This script will:"
echo "  • Launch apps in batches of 3 for permission setup"
echo "  • Open Zen Browser with extension install pages"
echo ""
echo "Press Enter to continue (Ctrl+C to cancel)..."
read -r

# ==============================================================================
# CONFIGURATION
# ==============================================================================
BATCH_SIZE=3

# Apps to launch (will be filtered to only existing ones)
APPS=(
    # Accessibility permissions needed
    "/Applications/Rectangle.app"
    "/Applications/Nix Apps/Sol.app"
    "/Applications/BetterDisplay.app"
    "/Applications/Stats.app"
    "/Applications/Hidden Bar.app"
    
    # Network/VPN permissions
    "/Applications/Docker.app"
    "/Applications/Tailscale.app"
    
    # Other apps that may need first-launch setup
    "/Applications/Ghostty.app"
    "/Applications/Obsidian.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Cursor.app"
    "/Applications/Zed.app"
    "/Applications/Bitwarden.app"
    "/Applications/Slack.app"
    "/Applications/Spotify.app"
    "/Applications/VLC.app"
    "/Applications/Blender.app"
    "/Applications/Figma.app"
    "/Applications/Steam.app"
    "/Applications/Calibre.app"
    "/Applications/UTM.app"
    "/Applications/Arduino IDE.app"
    "/Applications/Inkscape.app"
    "/Applications/REAPER.app"
    "/Applications/Autodesk Fusion.app"
    "/Applications/UltiMaker Cura.app"
    "/Applications/Beekeeper Studio.app"
    "/Applications/JProfiler.app"
    "/Applications/balenaEtcher.app"
    "/Applications/Keka.app"
    "/Applications/PDFsam Basic.app"
    "/Applications/Battery Toolkit.app"
    "/Applications/mpv.app"
    "/Applications/Ungoogled Chromium.app"
)

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Filter to only apps that exist and store in array
get_existing_apps() {
    local existing=()
    for app in "${APPS[@]}"; do
        if [ -d "$app" ]; then
            existing+=("$app")
        fi
    done
    # Use printf to handle paths with spaces correctly
    printf '%s\n' "${existing[@]}"
}

# Get app name from path
get_app_name() {
    basename "$1" .app
}

# Open a single app
open_app() {
    local app_path="$1"
    local app_name
    app_name=$(get_app_name "$app_path")
    echo "  → Opening $app_name..."
    
    # Always use full path - most reliable method
    if [ -d "$app_path" ]; then
        if open "$app_path" 2>/dev/null; then
            sleep 0.5
            return 0
        else
            echo "    ⚠ Failed to open $app_name (app exists but won't launch)"
            return 1
        fi
    else
        echo "    ⚠ App not found at $app_path"
        return 1
    fi
}

# ==============================================================================
# STEP 1: Launch Zen Browser - First Run Setup
# ==============================================================================
echo ""
echo "=== Zen Browser Setup ==="
echo ""

ZEN_APP="/Applications/Nix Apps/Zen Browser (Beta).app"
ZEN_DIR="$HOME/Library/Application Support/zen"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")/dotfiles"

if [ -d "$ZEN_APP" ]; then
    echo "→ Launching Zen Browser..."
    echo "  Complete the first-run setup wizard in Zen."
    echo ""
    open "$ZEN_APP"
    
    echo "Press Enter AFTER you've completed Zen's initial setup..."
    read -r
    
    # Quit Zen to apply our profile data
    echo ""
    echo "→ Applying saved profile (bookmarks, settings, etc.)..."
    osascript -e 'quit app "Zen Browser (Beta)"' 2>/dev/null || true
    sleep 2
    
    # Find Zen's current default profile from installs.ini
    DEFAULT_PROFILE=$(grep "Default=" "$ZEN_DIR/installs.ini" 2>/dev/null | head -1 | cut -d= -f2)
    
    if [ -n "$DEFAULT_PROFILE" ] && [ -d "$ZEN_DIR/$DEFAULT_PROFILE" ]; then
        TARGET="$ZEN_DIR/$DEFAULT_PROFILE"
        DOTFILES="$DOTFILES_DIR/zen/profile"
        
        echo "  Target profile: $DEFAULT_PROFILE"
        
        # Only copy SAFE files (no passwords, cookies, history, etc.)
        
        # Copy prefs.js (settings)
        if [ -f "$DOTFILES/prefs.js" ]; then
            cp "$DOTFILES/prefs.js" "$TARGET/"
            echo "  ✓ Settings"
        fi
        
        # Copy Zen-specific files
        for f in zen-keyboard-shortcuts.json zen-themes.json; do
            if [ -f "$DOTFILES/$f" ]; then
                cp "$DOTFILES/$f" "$TARGET/"
                echo "  ✓ $f"
            fi
        done
        
        # Copy chrome folder (custom CSS)
        if [ -d "$DOTFILES/chrome" ]; then
            cp -r "$DOTFILES/chrome" "$TARGET/"
            echo "  ✓ Custom CSS"
        fi
        
        # Copy containers
        if [ -f "$DOTFILES/containers.json" ]; then
            cp "$DOTFILES/containers.json" "$TARGET/"
            echo "  ✓ Containers"
        fi
        
        # Copy handlers (file associations)
        if [ -f "$DOTFILES/handlers.json" ]; then
            cp "$DOTFILES/handlers.json" "$TARGET/"
            echo "  ✓ File handlers"
        fi
        
        echo ""
        echo "→ Relaunching Zen with your profile data..."
        open "$ZEN_APP"
        sleep 3
    else
        echo "  ⚠ Could not find Zen's default profile"
        echo "  Opening Zen anyway..."
        open "$ZEN_APP"
        sleep 3
    fi
else
    echo "⚠ Zen Browser not found at $ZEN_APP"
fi

echo ""
echo "Press Enter to open extension install pages..."
read -r

# ==============================================================================
# STEP 2: Open Zen Browser Extensions
# ==============================================================================
echo ""
echo "=== Zen Browser Extensions ==="
echo ""
echo "Opening extension install pages..."
echo "(Click 'Add to Firefox' on each tab)"
sleep 1

# Zen Browser extensions
open "https://addons.mozilla.org/firefox/addon/ublock-origin/"
sleep 0.3
open "https://addons.mozilla.org/firefox/addon/bitwarden-password-manager/"
sleep 0.3
open "https://addons.mozilla.org/firefox/addon/darkreader/"
sleep 0.3
open "https://addons.mozilla.org/firefox/addon/react-devtools/"
sleep 0.3
open "https://addons.mozilla.org/firefox/addon/facebook-container/"
sleep 0.3
open "https://addons.mozilla.org/firefox/addon/redirector/"
sleep 0.3
open "https://addons.mozilla.org/firefox/addon/multithreaded-download-manager/"

# Open Finder at the Redirector config so it's easy to import rules
REDIRECTOR_CONFIG="$DOTFILES_DIR/zen/Redirector.json"
if [ -f "$REDIRECTOR_CONFIG" ]; then
    echo "→ Extension pages opened in browser"
    echo "→ Opening Finder with Redirector Redirector.json selected (for Import)..."
    open -R "$REDIRECTOR_CONFIG" 2>/dev/null || open "$(dirname "$REDIRECTOR_CONFIG")"
else
    echo "→ Extension pages opened in browser"
    echo "→ Note: Redirector config file not found at $REDIRECTOR_CONFIG"
fi

echo ""
echo "Press Enter to continue with app launching..."
read -r

# ==============================================================================
# STEP 3: Open System Settings for Accessibility
# ==============================================================================
echo ""
echo "=== Opening System Settings ==="
echo ""
echo "→ Opening Accessibility settings..."
echo "  (Grant permissions to apps as they launch)"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
sleep 2

# ==============================================================================
# STEP 4: Launch Apps in Batches
# ==============================================================================
echo ""
echo "=== Launching Apps in Batches of $BATCH_SIZE ==="
echo ""

# Get existing apps as array
EXISTING_APPS=()
while IFS= read -r app; do
    [ -n "$app" ] && EXISTING_APPS+=("$app")
done < <(get_existing_apps)

TOTAL_APPS=${#EXISTING_APPS[@]}

if [ $TOTAL_APPS -eq 0 ]; then
    echo "No apps found to launch."
else
    echo "Found $TOTAL_APPS apps to launch."
    echo ""
    
    BATCH_NUM=1
    i=0
    while [ $i -lt $TOTAL_APPS ]; do
        # Calculate how many apps in this batch
        COUNT=$((TOTAL_APPS - i))
        if [ $COUNT -gt $BATCH_SIZE ]; then
            COUNT=$BATCH_SIZE
        fi
        
        echo "--- Batch $BATCH_NUM ($COUNT apps) ---"
        
        # Launch apps in this batch
        j=0
        while [ $j -lt $COUNT ]; do
            idx=$((i + j))
            open_app "${EXISTING_APPS[$idx]}"
            j=$((j + 1))
        done
        
        # Update index
        i=$((i + COUNT))
        
        # Wait for confirmation before next batch (unless this is the last batch)
        REMAINING=$((TOTAL_APPS - i))
        if [ $REMAINING -gt 0 ]; then
            echo ""
            echo "Press Enter to launch next batch ($REMAINING apps remaining)..."
            read -r
        fi
        
        BATCH_NUM=$((BATCH_NUM + 1))
    done
fi

# ==============================================================================
# NEXT STEPS
# ==============================================================================
echo ""
echo "=========================================="
echo "  Next Steps"
echo "=========================================="
echo ""
echo "1. In System Settings → Privacy & Security → Accessibility:"
echo "   Enable: Rectangle, Sol, BetterDisplay, Stats, Hidden Bar"
echo ""
echo "2. Approve Docker's network extension when prompted"
echo ""
echo "3. Log in to Tailscale via the menu bar icon"
echo ""
echo "4. Remove BetterDisplay from Login Items:"
echo "   System Settings → General → Login Items"
echo "   (The launchd agent handles the cleanup instead)"
echo ""
echo "5. Optional: Grant Full Disk Access to Sol for file search"
echo ""
echo "6. Hidden Bar: Cmd+drag menu bar icons left of the | divider to hide them"
echo ""
echo "7. Zen Browser: Click 'Add to Firefox' on each extension tab"
echo ""
echo "8. Disable Spotlight keyboard shortcuts (using Sol instead):"
echo "   System Settings → Keyboard → Keyboard Shortcuts → Spotlight"
echo "   Disable: Show Spotlight search, Show Finder search window"
echo ""

# Try to open System Settings to Keyboard Shortcuts/Spotlight
echo "→ Opening Keyboard Shortcuts settings..."
# Try different URL schemes depending on macOS version
if open "x-apple.systempreferences:com.apple.preference.keyboard?KeyboardShortcuts" 2>/dev/null; then
    echo "  System Settings opened. Select 'Spotlight' in the left sidebar."
elif open "x-apple.systempreferences:com.apple.Keyboard-Settings.extension" 2>/dev/null; then
    echo "  System Settings opened. Navigate to: Keyboard Shortcuts → Spotlight"
elif open -b com.apple.systempreferences 2>/dev/null; then
    echo "  System Settings opened. Navigate to: Keyboard → Keyboard Shortcuts → Spotlight"
else
    echo "  Please open System Settings manually: Keyboard → Keyboard Shortcuts → Spotlight"
fi

echo ""
echo "Done! You may need to restart some apps after granting permissions."
echo ""
