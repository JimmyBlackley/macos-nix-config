#!/bin/bash
# ==============================================================================
# FULL INSTALLATION SCRIPT
# ==============================================================================
# Complete automated installation of the nix-darwin configuration.
# Run this on a fresh macOS install after cloning the repo.
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Capture original username before any sudo commands
ORIGINAL_USER=$(whoami)

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================
# Sanitize hostname to valid format (replace spaces with hyphens, remove special chars)
sanitize_hostname() {
    local hostname="$1"
    # Replace spaces with hyphens first
    hostname=$(echo "$hostname" | sed "s/ /-/g")
    # Remove special characters except hyphens and alphanumeric
    hostname=$(echo "$hostname" | sed "s/[^a-zA-Z0-9-]//g")
    # Replace multiple consecutive hyphens with single hyphen
    hostname=$(echo "$hostname" | sed "s/-\+/-/g")
    # Remove leading/trailing hyphens
    hostname=$(echo "$hostname" | sed "s/^-\|-$//g")
    echo "$hostname"
}

echo ""
echo -e "${BLUE}=========================================="
echo "  macOS Nix Configuration Installer"
echo -e "==========================================${NC}"
echo ""

# ==============================================================================
# PRE-FLIGHT CHECKS
# ==============================================================================
echo -e "${YELLOW}[1/7] Running pre-flight checks...${NC}"
echo ""

FAILED=0

# Check Xcode CLI tools
echo -n "  Xcode Command Line Tools... "
if xcode-select -p &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
    echo "      Run: xcode-select --install"
    FAILED=1
fi

# Check Homebrew
echo -n "  Homebrew... "
if command -v brew &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
    echo "      Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    FAILED=1
fi

# Check Terminal automation
echo -n "  Terminal automation access... "
if osascript -e 'tell application "System Events" to return name of first process' &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}○ May need permission${NC}"
    echo "      Grant Terminal access in System Settings → Privacy & Security → Automation"
fi

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}Pre-flight checks failed. Please fix the issues above.${NC}"
    exit 1
fi

echo ""

# ==============================================================================
# USER CONFIGURATION
# ==============================================================================
echo -e "${YELLOW}[2/7] Configuring for your system...${NC}"
echo ""

# Auto-detect values
RAW_HOSTNAME=$(scutil --get ComputerName 2>/dev/null || hostname -s)
DETECTED_HOSTNAME=$(sanitize_hostname "$RAW_HOSTNAME")
DETECTED_USERNAME="$ORIGINAL_USER"
DETECTED_ARCH=$(uname -m)

if [ "$DETECTED_ARCH" = "arm64" ]; then
    DETECTED_SYSTEM="aarch64-darwin"
else
    DETECTED_SYSTEM="x86_64-darwin"
fi

# Prompt for values with defaults
echo -e "${CYAN}Please confirm or update your configuration:${NC}"
echo ""

read -p "  Hostname [$DETECTED_HOSTNAME] (press Enter to use default): " INPUT_HOSTNAME
if [ -z "$INPUT_HOSTNAME" ]; then
    HOSTNAME="$DETECTED_HOSTNAME"
    echo -e "    ${GREEN}Using default: $HOSTNAME${NC}"
else
    HOSTNAME=$(sanitize_hostname "$INPUT_HOSTNAME")
fi

read -p "  Username [$DETECTED_USERNAME] (press Enter to use default): " INPUT_USERNAME
if [ -z "$INPUT_USERNAME" ]; then
    USERNAME="$DETECTED_USERNAME"
    echo -e "    ${GREEN}Using default: $USERNAME${NC}"
else
    USERNAME="$INPUT_USERNAME"
fi

read -p "  Git name (for commits): " GIT_NAME
while [ -z "$GIT_NAME" ]; do
    echo -e "    ${RED}Git name is required${NC}"
    read -p "  Git name (for commits): " GIT_NAME
done

read -p "  Git email (for commits): " GIT_EMAIL
while [ -z "$GIT_EMAIL" ]; do
    echo -e "    ${RED}Git email is required${NC}"
    read -p "  Git email (for commits): " GIT_EMAIL
done

echo "  System architecture:"
if [ "$DETECTED_SYSTEM" = "aarch64-darwin" ]; then
    echo "    1) aarch64-darwin (Apple Silicon) [detected - recommended]"
    echo "    2) x86_64-darwin (Intel)"
    read -p "  Select [1]: " INPUT_SYSTEM
    INPUT_SYSTEM="${INPUT_SYSTEM:-1}"
else
    echo "    1) aarch64-darwin (Apple Silicon)"
    echo "    2) x86_64-darwin (Intel) [detected - recommended]"
    read -p "  Select [2]: " INPUT_SYSTEM
    INPUT_SYSTEM="${INPUT_SYSTEM:-2}"
fi

case "$INPUT_SYSTEM" in
    1)
        SYSTEM="aarch64-darwin"
        ;;
    2)
        SYSTEM="x86_64-darwin"
        ;;
    *)
        echo -e "    ${RED}Invalid selection. Using detected architecture: $DETECTED_SYSTEM${NC}"
        SYSTEM="$DETECTED_SYSTEM"
        ;;
esac

echo ""
echo -e "  ${GREEN}Configuration:${NC}"
echo "    Hostname: $HOSTNAME"
echo "    Username: $USERNAME"
echo "    Git name: $GIT_NAME"
echo "    Git email: $GIT_EMAIL"
echo "    System: $SYSTEM"
echo ""

read -p "  Is this correct? [Y/n]: " CONFIRM
if [[ "$CONFIRM" =~ ^[Nn] ]]; then
    echo "Aborted. Please run the script again."
    exit 1
fi

# Update flake.nix with the configuration
echo ""
echo "  Updating flake.nix..."

sed -i '' "s|hostname = \".*\";|hostname = \"$HOSTNAME\";|" "$NIX_CONFIG_DIR/flake.nix"
sed -i '' "s|username = \".*\";|username = \"$USERNAME\";|" "$NIX_CONFIG_DIR/flake.nix"
sed -i '' "s|gitName = \".*\";|gitName = \"$GIT_NAME\";|" "$NIX_CONFIG_DIR/flake.nix"
sed -i '' "s|gitEmail = \".*\";|gitEmail = \"$GIT_EMAIL\";|" "$NIX_CONFIG_DIR/flake.nix"
sed -i '' "s|system = \".*-darwin\";|system = \"$SYSTEM\";|" "$NIX_CONFIG_DIR/flake.nix"

echo -e "  ${GREEN}✓ Configuration saved${NC}"
echo ""

# ==============================================================================
# INSTALL NIX (if needed)
# ==============================================================================
echo -e "${YELLOW}[3/7] Checking Nix installation...${NC}"
echo ""

# Check if Nix is installed (check multiple indicators)
NIX_INSTALLED=false
if command -v nix &> /dev/null; then
    NIX_INSTALLED=true
elif [ -d /nix ]; then
    # Nix directory exists, try to source it
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        if command -v nix &> /dev/null; then
            NIX_INSTALLED=true
        fi
    fi
fi

if [ "$NIX_INSTALLED" = true ]; then
    echo -e "  Nix is already installed ${GREEN}✓${NC}"
else
    echo "  Nix is not installed. Installing..."
    echo ""
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source nix
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    
    echo ""
    echo -e "  Nix installed ${GREEN}✓${NC}"
fi

echo ""

# ==============================================================================
# BOOTSTRAP NIX-DARWIN (if needed)
# ==============================================================================
echo -e "${YELLOW}[4/7] Setting up nix-darwin...${NC}"
echo ""

# Source nix environment if available
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -f /etc/static/bashrc ]; then
    . /etc/static/bashrc
fi

if command -v darwin-rebuild &> /dev/null; then
    echo -e "  nix-darwin is already installed ${GREEN}✓${NC}"
else
    echo "  Bootstrapping nix-darwin..."
    cd "$NIX_CONFIG_DIR"
    sudo nix run nix-darwin -- switch --flake .
    echo -e "  nix-darwin bootstrapped ${GREEN}✓${NC}"
    
    # Source nix environment again after bootstrap to ensure darwin-rebuild is in PATH
    if [ -f /etc/static/bashrc ]; then
        . /etc/static/bashrc
    elif [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
fi

echo ""

# ==============================================================================
# BUILD AND SWITCH
# ==============================================================================
echo -e "${YELLOW}[5/7] Building and applying configuration...${NC}"
echo ""

# Check and handle /etc/zshenv conflict before darwin-rebuild
if [ -f /etc/zshenv ]; then
    echo "  Found /etc/zshenv, renaming to avoid conflict..."
    sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin
    echo -e "  ${GREEN}✓ Renamed /etc/zshenv to /etc/zshenv.before-nix-darwin${NC}"
    echo ""
fi

cd "$NIX_CONFIG_DIR"

# Ensure darwin-rebuild is available
if ! command -v darwin-rebuild &> /dev/null; then
    echo -e "  ${YELLOW}Warning: darwin-rebuild not in PATH, attempting to find it...${NC}"
    # Try to find darwin-rebuild in common locations
    if [ -f /run/current-system/sw/bin/darwin-rebuild ]; then
        DARWIN_REBUILD="/run/current-system/sw/bin/darwin-rebuild"
    elif [ -f /nix/var/nix/profiles/system/sw/bin/darwin-rebuild ]; then
        DARWIN_REBUILD="/nix/var/nix/profiles/system/sw/bin/darwin-rebuild"
    else
        echo -e "  ${RED}Error: darwin-rebuild not found${NC}"
        echo "  Please ensure nix-darwin is properly installed"
        exit 1
    fi
else
    DARWIN_REBUILD="darwin-rebuild"
fi

sudo "$DARWIN_REBUILD" switch --flake .

echo ""
echo -e "  Configuration applied ${GREEN}✓${NC}"
echo ""

# ==============================================================================
# VERIFICATION TESTS
# ==============================================================================
echo -e "${YELLOW}[6/7] Verifying installation...${NC}"
echo ""

TEST_FAILED=0

# Test Nix Apps
echo "  Nix Apps:"
for app in "Sol.app" "ntsc-rs.app" "Zen Browser (Beta).app"; do
    echo -n "    $app... "
    if [ -d "/Applications/Nix Apps/$app" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ Missing${NC}"
        TEST_FAILED=1
    fi
done

# Test Homebrew Apps
echo ""
echo "  Homebrew Apps:"
BREW_APPS=(
    "Docker.app"
    "Tailscale.app"
    "Visual Studio Code.app"
    "Cursor.app"
    "Ghostty.app"
    "Obsidian.app"
    "Rectangle.app"
    "Stats.app"
    "Hidden Bar.app"
    "BetterDisplay.app"
    "Blender.app"
    "VLC.app"
    "Spotify.app"
    "Slack.app"
    "Bitwarden.app"
    "Steam.app"
)

for app in "${BREW_APPS[@]}"; do
    echo -n "    $app... "
    if [ -d "/Applications/$app" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}○ Not found${NC}"
    fi
done

# Test CLI tools
echo ""
echo "  CLI Tools:"
CLI_TOOLS=(
    "git"
    "nvim"
    "tmux"
    "fzf"
    "lazygit"
    "btop"
    "node"
    "bun"
    "go"
    "python3"
    "rustup"
)

for tool in "${CLI_TOOLS[@]}"; do
    echo -n "    $tool... "
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ Missing${NC}"
        TEST_FAILED=1
    fi
done

# Test services
echo ""
echo "  Services:"
echo -n "    sketchybar... "
if pgrep -x sketchybar &> /dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}○ Not running${NC}"
fi

echo -n "    tailscaled... "
if pgrep -x tailscaled &> /dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}○ Not running${NC}"
fi

# Test dotfiles
echo ""
echo "  Dotfiles:"
DOTFILES=(
    "$HOME/.config/ghostty/config"
    "$HOME/.config/sketchybar/sketchybarrc"
    "$HOME/Library/Preferences/eu.exelban.Stats.plist"
    "$HOME/Library/Application Support/Rectangle/RectangleConfig.json"
)

for dotfile in "${DOTFILES[@]}"; do
    name=$(basename "$dotfile")
    echo -n "    $name... "
    if [ -e "$dotfile" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ Missing${NC}"
        TEST_FAILED=1
    fi
done

# Test p10k
echo ""
echo "  Powerlevel10k:"
echo -n "    .p10k.zsh... "
if [ -f "$HOME/.p10k.zsh" ] && [ -s "$HOME/.p10k.zsh" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}○ Not configured (run: p10k configure)${NC}"
fi

echo ""

# ==============================================================================
# POST-INSTALL SETUP
# ==============================================================================
echo -e "${YELLOW}[7/7] Running post-install setup...${NC}"
echo ""

# Run post-install script for app permissions
if [ -f "$SCRIPT_DIR/post-install.sh" ]; then
    echo "  Running post-install script for app permissions..."
    bash "$SCRIPT_DIR/post-install.sh"
    echo -e "  ${GREEN}✓ Post-install script completed${NC}"
else
    echo -e "  ${YELLOW}○ Post-install script not found${NC}"
fi

echo ""

# Run SSH setup script
if [ -f "$SCRIPT_DIR/setup-ssh.sh" ]; then
    echo "  Setting up SSH keys (GitHub + Bitwarden)..."
    bash "$SCRIPT_DIR/setup-ssh.sh"
    echo -e "  ${GREEN}✓ SSH setup completed${NC}"
else
    echo -e "  ${YELLOW}○ SSH setup script not found${NC}"
fi

echo ""

# Prompt for Powerlevel10k configuration
if [ ! -f "$HOME/.p10k.zsh" ] || [ ! -s "$HOME/.p10k.zsh" ]; then
    echo -e "  ${CYAN}Powerlevel10k configuration${NC}"
    read -p "  Would you like to configure Powerlevel10k now? [Y/n]: " CONFIGURE_P10K
    if [[ ! "$CONFIGURE_P10K" =~ ^[Nn] ]]; then
        if command -v p10k &> /dev/null || command -v p10k configure &> /dev/null; then
            p10k configure || echo -e "    ${YELLOW}Note: p10k configure may need to be run manually in your terminal${NC}"
            if [ -f "$HOME/.p10k.zsh" ] && [ -s "$HOME/.p10k.zsh" ]; then
                mkdir -p "$NIX_CONFIG_DIR/dotfiles/p10k"
                cp "$HOME/.p10k.zsh" "$NIX_CONFIG_DIR/dotfiles/p10k/.p10k.zsh"
                echo -e "    ${GREEN}✓ Powerlevel10k config saved${NC}"
            fi
        else
            echo -e "    ${YELLOW}Note: p10k command not found. Run 'p10k configure' manually after restarting your terminal${NC}"
        fi
    fi
else
    echo -e "  ${GREEN}Powerlevel10k already configured ✓${NC}"
fi

echo ""

# ==============================================================================
# SUMMARY
# ==============================================================================
echo -e "${YELLOW}Installation Complete!${NC}"
echo ""

if [ $TEST_FAILED -eq 0 ]; then
    echo -e "${GREEN}All core components installed successfully!${NC}"
else
    echo -e "${YELLOW}Some components may need attention (see above).${NC}"
fi

echo ""
echo "Final step:"
echo "  Restart your terminal to apply all changes"
echo ""