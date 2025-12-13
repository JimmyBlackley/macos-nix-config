# macOS Nix Configuration

A declarative macOS system configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## Quick Start

### 1. Install Prerequisites

**Xcode Command Line Tools:**
```bash
xcode-select --install
```

**Homebrew:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add Homebrew to PATH (follow printed instructions, or for Apple Silicon):
```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Clone and Install

```bash
git clone https://github.com/YOUR_USERNAME/nix-config.git ~/.config/nix
cd ~/.config/nix
./scripts/install.sh
```

The install script will:
1. Run pre-flight checks
2. **Prompt for your configuration** (hostname, username, git name/email)
3. Automatically update `flake.nix` with your values
4. Install Nix if needed
5. Build and apply the configuration
6. Verify everything installed correctly

### 4. Post-Install

```bash
./scripts/post-install.sh
```

This launches apps for permission setup, configures Zen Browser, and opens extension pages.

---

## Daily Usage

**Apply configuration changes:**
```bash
sudo darwin-rebuild switch --flake ~/.config/nix
```

**Update flake inputs:**
```bash
nix flake update
```

---

## Structure

```
├── flake.nix              # Main entry point + user configuration
├── modules/
│   ├── system.nix         # macOS preferences (Dock, Finder, keyboard, etc.)
│   ├── packages.nix       # CLI tools and Nix packages
│   ├── homebrew.nix       # GUI apps via Homebrew
│   ├── services.nix       # Background services (sketchybar, tailscale)
│   └── home.nix           # User config (git, zsh, direnv, dotfiles)
├── packages/
│   ├── ntsc-rs.nix        # NTSC video effects from GitHub releases
│   └── sol.nix            # Sol launcher from GitHub releases
├── dotfiles/
│   ├── ghostty/           # Terminal config
│   ├── p10k/              # Powerlevel10k theme config
│   ├── sketchybar/        # Menu bar config + plugins
│   ├── stats/             # Stats.app preferences
│   ├── rectangle/         # Window manager config
│   └── zen/               # Zen Browser profile (settings, themes)
└── scripts/
    ├── install.sh         # Full automated installation + verification
    ├── pre-install.sh     # Pre-flight checks
    ├── post-install.sh    # Permission setup & extension installs
    └── setup-ssh.sh       # SSH key setup from Bitwarden
```

## What's Included

### System Preferences
- Dark mode
- Touch ID for sudo
- Firewall enabled
- Caps Lock → Control
- Dock: auto-hide, right side, persistent apps
- Finder: show hidden files, no desktop icons
- Spotlight shortcuts disabled (using Sol)
- Menu bar: analog clock, volume shown, input sources hidden
- Display never sleeps when connected to power
- Double-click title bar disabled

### Packages (Nix)
- **Dev tools:** git, neovim, tmux, lazygit, fzf, direnv, btop
- **Languages:** Node.js, Bun, Go, Python, Rust, Java
- **Databases:** PostgreSQL, SQLite
- **Custom:**
  - [ntsc-rs](https://github.com/valadaptive/ntsc-rs) - Video effects
  - [Sol](https://github.com/ospfranco/sol) - Native Swift launcher

### Homebrew Casks
VS Code, Cursor, Docker, Blender, Obsidian, Ghostty, Tailscale, Hidden Bar, and more.

### Services
- **sketchybar** - Custom menu bar (clock, CPU, RAM, battery, network)
- **tailscale** - VPN
- **betterdisplay-cleanup** - Launchd agent

### Dotfiles
- **Ghostty** - Terminal theme and settings
- **Powerlevel10k** - Zsh theme configuration
- **Sketchybar** - Menu bar layout and plugins
- **Stats** - System monitor preferences
- **Rectangle** - Window management shortcuts
- **Zen Browser** - Settings, keyboard shortcuts, themes

## Customization

### Adding Packages

**Nix packages:** Edit `modules/packages.nix`
```nix
environment.systemPackages = with pkgs; [
  your-package
];
```

**Homebrew casks:** Edit `modules/homebrew.nix`
```nix
casks = [
  "your-app"
];
```

### Changing System Preferences

Edit `modules/system.nix` - see [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html).

### Adding Dotfiles

1. Add files to `dotfiles/your-app/`
2. Link them in `modules/home.nix`:
```nix
xdg.configFile."your-app/config".source = ../dotfiles/your-app/config;
```

## SSH Keys Setup

Set up SSH keys for GitHub and other services:

```bash
./scripts/setup-ssh.sh
```

This script:
1. **GitHub Authentication** (required):
   - Uses `gh auth login` to authenticate via browser
   - Generates `~/.ssh/id_ed25519` automatically
   - Uploads the key to your GitHub account

2. **Other Keys from Bitwarden** (optional):
   - Prompts to retrieve additional keys from Bitwarden
   - Looks for folder "ssh" in your vault
   - Retrieves keys and generates public keys automatically

**Bitwarden Structure:**
- Folder: `ssh`
- Secure Notes (name = filename):
  - `id_ed25519` → `~/.ssh/id_ed25519`
  - `id_rsa` → `~/.ssh/id_rsa`
  - `keys/ssh-key-2025-01-07.key` → `~/.ssh/keys/ssh-key-2025-01-07.key`
  - `keys/ssh-key-2025-04-08.key` → `~/.ssh/keys/ssh-key-2025-04-08.key`
  - `keys/tide.key` → `~/.ssh/keys/tide.key`
  - `access_token_tidey` → `~/.ssh/access_token_tidey`

**Note:** Public keys (`.pub` files) are generated automatically - don't store them in Bitwarden.

## Zen Browser

The post-install script handles Zen setup:
1. Launch Zen and complete its first-run wizard
2. Script injects your saved settings into Zen's profile

Profile data stored in `dotfiles/zen/profile/`:
- Settings (`prefs.js`)
- Keyboard shortcuts (`zen-keyboard-shortcuts.json`)
- Themes (`zen-themes.json`)
- Custom CSS (`chrome/`)
- Containers (`containers.json`)

**Not synced** (for privacy): bookmarks, history, passwords, cookies.

## Troubleshooting

**"command not found: darwin-rebuild"**
```bash
nix run nix-darwin -- switch --flake ~/.config/nix
```

**Homebrew not in PATH**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Permission denied**
```bash
sudo darwin-rebuild switch --flake ~/.config/nix
```

**Flake not evaluating changes**
- Ensure files are tracked by git: `git add -A`
