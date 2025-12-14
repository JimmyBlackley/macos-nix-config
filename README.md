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
7. Run post-install setup automatically
8. Set up SSH keys automatically

### 3. Post-Install

The `install.sh` script runs `post-install.sh` automatically, but you can run it manually if needed:

```bash
./scripts/post-install.sh
```

This launches apps for permission setup, configures Zen Browser, and opens extension pages. See [Post-Install Guide](docs/POST_INSTALL.md) for details.

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

## Documentation

### Detailed Guides

- **[SSH Setup Guide](docs/SSH_SETUP.md)** - Comprehensive guide for setting up SSH keys with GitHub and Bitwarden, including step-by-step instructions and technical details
- **[Scripts Guide](docs/SCRIPTS.md)** - Documentation for all scripts, execution order, location requirements, and how they work
- **[Dotfiles Guide](docs/DOTFILES.md)** - How to add and manage custom dotfiles in the configuration
- **[Post-Install Guide](docs/POST_INSTALL.md)** - Detailed explanation of post-install configuration, permissions, and app setup

---

## Project Structure

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
├── scripts/
│   ├── install.sh         # Full automated installation + verification
│   ├── pre-install.sh     # Pre-flight checks
│   ├── post-install.sh    # Permission setup & extension installs
│   └── setup-ssh.sh       # SSH key setup from Bitwarden
└── docs/
    ├── SSH_SETUP.md       # SSH setup guide
    ├── SCRIPTS.md         # Scripts documentation
    ├── DOTFILES.md        # Dotfiles guide
    └── POST_INSTALL.md    # Post-install guide
```

---

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

---

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

See the [Dotfiles Guide](docs/DOTFILES.md) for comprehensive instructions.

Quick summary:
1. Add files to `dotfiles/your-app/`
2. Link them in `modules/home.nix`:
```nix
xdg.configFile."your-app/config".source = ../dotfiles/your-app/config;
```

### SSH Keys Setup

See the [SSH Setup Guide](docs/SSH_SETUP.md) for detailed instructions.

Quick setup:
```bash
./scripts/setup-ssh.sh
```

This handles:
- GitHub authentication and key generation
- Retrieving additional keys from Bitwarden (folder: `ssh`)
- Automatic public key generation

---

## Scripts

All scripts are located in `scripts/` and should be run from the repository root. See [Scripts Guide](docs/SCRIPTS.md) for detailed documentation.

- **`install.sh`** - Main installation script (runs everything)
- **`pre-install.sh`** - Pre-flight checks
- **`post-install.sh`** - Post-installation setup (permissions, apps, extensions)
- **`setup-ssh.sh`** - SSH key setup (GitHub + Bitwarden)

**Execution:**
```bash
cd ~/.config/nix
./scripts/install.sh  # Runs everything automatically
```

---

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

**Script execution issues**
- See [Scripts Guide](docs/SCRIPTS.md) for troubleshooting
- Ensure scripts have execute permissions: `chmod +x scripts/*.sh`

**SSH key issues**
- See [SSH Setup Guide](docs/SSH_SETUP.md) for troubleshooting

**Post-install problems**
- See [Post-Install Guide](docs/POST_INSTALL.md) for troubleshooting
