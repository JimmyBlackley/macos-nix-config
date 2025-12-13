#!/bin/bash
# ==============================================================================
# SSH KEY SETUP
# ==============================================================================
# 1. Authenticates with GitHub CLI (generates and uploads SSH key)
# 2. Retrieves other SSH keys from Bitwarden folder "ssh"
#
# GitHub: Uses `gh auth login` to generate and register SSH key automatically
#
# Bitwarden folder "ssh" for other keys:
#   - id_ed25519                   → ~/.ssh/id_ed25519
#   - id_rsa                       → ~/.ssh/id_rsa
#   - keys/ssh-key-2025-01-07.key  → ~/.ssh/keys/ssh-key-2025-01-07.key
#   - keys/ssh-key-2025-04-08.key  → ~/.ssh/keys/ssh-key-2025-04-08.key
#   - keys/tide.key                → ~/.ssh/keys/tide.key
#   - access_token_tidey           → ~/.ssh/access_token_tidey
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
echo "  SSH Key Setup"
echo -e "==========================================${NC}"
echo ""

# Source nix environment to ensure commands are available
if [ -f /etc/static/bashrc ]; then
    . /etc/static/bashrc
elif [ -f /etc/static/zshrc ]; then
    . /etc/static/zshrc
elif [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Create directories
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.ssh/keys"
chmod 700 "$HOME/.ssh"
chmod 700 "$HOME/.ssh/keys"

# ==============================================================================
# STEP 1: GitHub Authentication
# ==============================================================================
echo -e "${YELLOW}[1/2] GitHub Authentication${NC}"
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo ""
    echo "This usually means:"
    echo "  1. The nix-darwin configuration hasn't been applied yet, or"
    echo "  2. You need to restart your terminal to pick up the new environment"
    echo ""
    echo "Try running:"
    echo "  sudo darwin-rebuild switch --flake ~/.config/nix"
    echo ""
    echo "If that doesn't work, restart your terminal and try again."
    exit 1
fi

# Check if already authenticated
if gh auth status &> /dev/null; then
    echo -e "${GREEN}✓ Already authenticated with GitHub${NC}"
else
    echo "Authenticating with GitHub..."
    echo "This will:"
    echo "  • Open a browser to authenticate"
    echo "  • Generate a new SSH key"
    echo "  • Upload it to your GitHub account"
    echo ""
    
    gh auth login --web --git-protocol ssh
    
    echo ""
    echo -e "${GREEN}✓ GitHub authentication complete${NC}"
fi

# Ensure SSH key exists for GitHub
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo ""
    echo "Generating SSH key for GitHub..."
    ssh-keygen -t ed25519 -C "$(gh api user --jq .email 2>/dev/null || echo 'github')" -f "$HOME/.ssh/id_ed25519" -N ""
    gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)"
    echo -e "${GREEN}✓ SSH key generated and added to GitHub${NC}"
fi

echo ""

# ==============================================================================
# STEP 2: Bitwarden Keys (Optional)
# ==============================================================================
echo -e "${YELLOW}[2/2] Other SSH Keys from Bitwarden${NC}"
echo ""

# Check if bw is installed
if ! command -v bw &> /dev/null; then
    echo -e "${YELLOW}Bitwarden CLI not installed, skipping other keys${NC}"
    echo ""
else
    read -p "Retrieve other SSH keys from Bitwarden? [y/N]: " RETRIEVE_BW
    
    if [[ "$RETRIEVE_BW" =~ ^[Yy] ]]; then
        # Login/unlock Bitwarden
        BW_STATUS=$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "unauthenticated")
        
        if [ "$BW_STATUS" = "unauthenticated" ]; then
            echo "Logging in to Bitwarden..."
            echo -e "${YELLOW}Enter your Bitwarden email:${NC}"
            read -r BW_EMAIL
            BW_SESSION=$(bw login "$BW_EMAIL" --raw)
            export BW_SESSION
        elif [ "$BW_STATUS" != "unlocked" ]; then
            echo "Unlocking Bitwarden vault..."
            BW_SESSION=$(bw unlock --raw)
            export BW_SESSION
        fi
        
        if [ -z "$BW_SESSION" ]; then
            echo -e "${RED}Failed to unlock Bitwarden${NC}"
        else
            echo -e "${GREEN}✓ Bitwarden unlocked${NC}"
            echo ""
            
            # Sync vault
            echo "Syncing vault..."
            bw sync --session "$BW_SESSION" > /dev/null 2>&1 || true
            sleep 3  # Allow vault to sync before accessing folder
            echo ""
            
            # Define keys (excluding github - we use gh auth for that)
            KEYS=(
                "id_ed25519:$HOME/.ssh/id_ed25519"
                "id_rsa:$HOME/.ssh/id_rsa"
                "access_token_tidey:$HOME/.ssh/access_token_tidey"
                "keys/ssh-key-2025-01-07.key:$HOME/.ssh/keys/ssh-key-2025-01-07.key"
                "keys/ssh-key-2025-04-08.key:$HOME/.ssh/keys/ssh-key-2025-04-08.key"
                "keys/tide.key:$HOME/.ssh/keys/tide.key"
            )
            
            echo -e "${YELLOW}Retrieving SSH keys from Bitwarden (folder: ssh)...${NC}"
            echo ""
            
            KEYS_SAVED=0
            
            # Get the folder ID for "ssh"
            SSH_FOLDER_ID=$(bw list folders --session "$BW_SESSION" 2>/dev/null | jq -r '.[] | select(.name == "ssh") | .id' || echo "")
            
            if [ -z "$SSH_FOLDER_ID" ]; then
                echo -e "${YELLOW}Folder 'ssh' not found in Bitwarden, skipping${NC}"
            else
                echo "Found folder 'ssh'"
                
                # Retrieve and save each key
                for key_entry in "${KEYS[@]}"; do
                    bw_name="${key_entry%%:*}"
                    target_path="${key_entry##*:}"
                    
                    # Ensure parent directory exists
                    mkdir -p "$(dirname "$target_path")"
                    
                    echo -n "  $bw_name → $target_path... "
                    
                    # Search for the item by name in the ssh folder
                    ITEM=$(bw list items --folderid "$SSH_FOLDER_ID" --session "$BW_SESSION" 2>/dev/null | jq -r ".[] | select(.name == \"$bw_name\")" || echo "")
                    
                    if [ -z "$ITEM" ] || [ "$ITEM" = "null" ]; then
                        echo -e "${YELLOW}not found${NC}"
                        continue
                    fi
                    
                    # Extract content from notes
                    CONTENT=$(echo "$ITEM" | jq -r '.notes // empty')
                    
                    if [ -z "$CONTENT" ]; then
                        echo -e "${RED}no content in notes${NC}"
                        continue
                    fi
                    
                    # Save the key
                    echo "$CONTENT" > "$target_path"
                    chmod 600 "$target_path"
                    
                    # Generate public key if it's an SSH key (not a token)
                    if [[ "$bw_name" != *"token"* ]] && [[ "$bw_name" != *"access"* ]]; then
                        ssh-keygen -y -f "$target_path" > "${target_path}.pub" 2>/dev/null || true
                    fi
                    
                    KEYS_SAVED=$((KEYS_SAVED + 1))
                    echo -e "${GREEN}✓${NC}"
                done
                
                echo ""
                echo "Keys retrieved from Bitwarden: $KEYS_SAVED"
            fi
        fi
    else
        echo "Skipping Bitwarden keys"
    fi
fi

echo ""

# ==============================================================================
# Add keys to ssh-agent
# ==============================================================================
echo "Adding keys to ssh-agent..."
eval "$(ssh-agent -s)" > /dev/null 2>&1 || true

for key in "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_rsa" "$HOME/.ssh/keys"/*.key; do
    if [ -f "$key" ]; then
        ssh-add "$key" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✓ Keys added to ssh-agent${NC}"
echo ""

# ==============================================================================
# Summary
# ==============================================================================
echo -e "${GREEN}=========================================="
echo "  SSH Setup Complete"
echo -e "==========================================${NC}"
echo ""
echo "Test GitHub: ssh -T git@github.com"
echo ""
