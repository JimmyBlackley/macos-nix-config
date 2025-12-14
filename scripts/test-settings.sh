#!/bin/bash
# ==============================================================================
# TEST SYSTEM SETTINGS
# ==============================================================================
# Quick verification script to check if macOS settings are applied correctly
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=========================================="
echo "  System Settings Test"
echo -e "==========================================${NC}"
echo ""

# Test 1: Check Caps Lock to Escape remapping
echo -e "${YELLOW}1. Testing Caps Lock to Escape remapping...${NC}"
CURRENT_MAPPING=$(/usr/bin/hidutil property --get "UserKeyMapping" 2>/dev/null | grep -q "30064771129" && echo "found" || echo "not found")
if [ "$CURRENT_MAPPING" = "found" ]; then
    echo -e "   ${GREEN}✓ Caps Lock remapping is active${NC}"
    echo "   Manual test: Press Caps Lock - it should act as Escape"
else
    echo -e "   ${RED}✗ Caps Lock remapping not found${NC}"
fi
echo ""

# Test 2: Check trackpad tap to click
echo -e "${YELLOW}2. Testing trackpad settings...${NC}"
TAP_TO_CLICK=$(defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 2>/dev/null || defaults read -g com.apple.mouse.tapBehavior 2>/dev/null || echo "unknown")
if [ "$TAP_TO_CLICK" = "0" ] || [ "$TAP_TO_CLICK" = "1" ]; then
    if [ "$TAP_TO_CLICK" = "0" ]; then
        echo -e "   ${GREEN}✓ Tap to click is disabled${NC}"
    else
        echo -e "   ${YELLOW}○ Tap to click is enabled (expected: disabled)${NC}"
    fi
else
    echo -e "   ${YELLOW}○ Could not read tap to click setting${NC}"
fi
echo ""

# Test 3: Check function key behavior
echo -e "${YELLOW}3. Testing function key settings...${NC}"
FN_STATE=$(defaults read -g com.apple.keyboard.fnState 2>/dev/null || echo "unknown")
if [ "$FN_STATE" = "0" ]; then
    echo -e "   ${GREEN}✓ Function keys work as standard (fn for media keys)${NC}"
elif [ "$FN_STATE" = "1" ]; then
    echo -e "   ${YELLOW}○ Function keys control media (expected: standard F keys)${NC}"
else
    echo -e "   ${YELLOW}○ Could not read function key setting${NC}"
fi
echo ""

# Test 4: Check Spotlight shortcuts
echo -e "${YELLOW}4. Testing Spotlight keyboard shortcuts...${NC}"
SPOTLIGHT_64=$(defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -A 3 '"64"' | grep -q 'enabled = 0' && echo "disabled" || echo "enabled")
SPOTLIGHT_65=$(defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -A 3 '"65"' | grep -q 'enabled = 0' && echo "disabled" || echo "enabled")
if [ "$SPOTLIGHT_64" = "disabled" ] && [ "$SPOTLIGHT_65" = "disabled" ]; then
    echo -e "   ${GREEN}✓ Spotlight shortcuts are disabled${NC}"
    echo "   Manual test: Press Cmd+Space - Spotlight should NOT open"
else
    echo -e "   ${YELLOW}○ Some Spotlight shortcuts may still be enabled${NC}"
fi
echo ""

# Test 5: Check LaunchAgent status
echo -e "${YELLOW}5. Testing LaunchAgent status...${NC}"
if launchctl list | grep -q "org.nixdarwin.capslock-to-escape"; then
    echo -e "   ${GREEN}✓ Caps Lock to Escape LaunchAgent is loaded${NC}"
else
    echo -e "   ${YELLOW}○ LaunchAgent not found (may need to apply configuration)${NC}"
fi
echo ""

# Manual tests
echo -e "${BLUE}=========================================="
echo "  Manual Tests Required"
echo -e "==========================================${NC}"
echo ""
echo "Please manually test:"
echo "  • Trackpad: Try swiping from right edge - Notification Center should NOT open"
echo "  • Trackpad: Try three-finger swipe up - Mission Control should NOT open"
echo "  • Trackpad: Try four-finger swipe - App Expose should NOT open"
echo "  • Trackpad: Try pinch gestures - Launchpad should NOT open"
echo "  • Trackpad: Try three-finger swipe down - Desktop should NOT show"
echo "  • Trackpad: Tap to click should be disabled"
echo "  • Keyboard: Press Caps Lock - should act as Escape"
echo "  • Keyboard: Press F1-F12 - should work as standard function keys"
echo "  • Keyboard: Press fn+F1 - should control volume/brightness"
echo "  • Keyboard: Press Cmd+Space - Spotlight should NOT open"
echo "  • Keyboard: Try Mission Control shortcuts (Control+Up) - should NOT work"
echo ""

echo -e "${GREEN}Test complete!${NC}"
echo ""

