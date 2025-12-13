#!/bin/bash
# ==============================================================================
# PRE-INSTALL SCRIPT
# ==============================================================================
# Pre-flight checks before running the Nix installer.
# Run this BEFORE `nix-darwin` to ensure the system is ready.
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  macOS Pre-Install Checks"
echo "=========================================="
echo ""

FAILED=0

# ------------------------------------------------------------------------------
# Check 1: Xcode Command Line Tools
# ------------------------------------------------------------------------------
echo -n "Checking Xcode Command Line Tools... "
if xcode-select -p &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
    echo "  Run: xcode-select --install"
    FAILED=1
fi

# ------------------------------------------------------------------------------
# Check 2: Homebrew
# ------------------------------------------------------------------------------
echo -n "Checking Homebrew... "
if command -v brew &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
    echo "  Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    FAILED=1
fi

# ------------------------------------------------------------------------------
# Check 3: Nix
# ------------------------------------------------------------------------------
echo -n "Checking Nix... "
if command -v nix &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${YELLOW}○ Not installed${NC}"
    echo "  This is expected for first-time setup."
    echo "  Install with: curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
fi

# ------------------------------------------------------------------------------
# Check 4: Terminal Automation Permission
# ------------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Important: Terminal Permissions${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Terminal.app needs permission to control other apps for the"
echo "Nix installer and darwin-rebuild to work properly."
echo ""
echo "Please verify the following:"
echo ""
echo "  1. Open System Settings → Privacy & Security → Automation"
echo "  2. Find 'Terminal' in the list"
echo "  3. Enable access to 'System Events' and 'Finder'"
echo ""
echo "  If Terminal isn't listed, it will be added automatically"
echo "  when you first run a command that needs it - just click 'OK'"
echo "  when prompted."
echo ""

# Try to trigger the permission check by running a harmless AppleScript
echo -n "Testing Terminal automation access... "
if osascript -e 'tell application "System Events" to return name of first process' &> /dev/null; then
    echo -e "${GREEN}✓ Automation access granted${NC}"
else
    echo -e "${YELLOW}○ May need permission${NC}"
    echo "  You may be prompted to grant access when running the installer."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All pre-flight checks passed!${NC}"
    echo ""
    echo "You're ready to proceed with installation:"
    echo "  1. Install Nix (if not already installed)"
    echo "  2. Run: darwin-rebuild switch --flake ~/.config/nix"
    echo "  3. Run: ./scripts/post-install.sh"
else
    echo -e "${RED}Some checks failed. Please fix the issues above before proceeding.${NC}"
    exit 1
fi

echo ""

