# Scripts Documentation

This guide explains all scripts in the `scripts/` directory, including their purpose, execution order, location requirements, and how they work.

## Scripts Overview

All scripts are located in the `scripts/` directory at the root of the configuration repository:

```
~/.config/nix/scripts/
├── install.sh         # Main installation script (runs everything)
├── pre-install.sh     # Pre-flight checks (standalone or called by install.sh)
├── post-install.sh    # Post-installation setup and permissions
├── setup-ssh.sh       # SSH key setup (GitHub + Bitwarden)
└── test-settings.sh   # Settings verification (optional)
```

## Script Execution Workflow

### First-Time Installation

For a fresh macOS installation, run the scripts in this order:

```bash
cd ~/.config/nix
./scripts/install.sh
```

The `install.sh` script orchestrates the entire installation process and will:
1. Run pre-flight checks (via `pre-install.sh`)
2. Prompt for configuration (hostname, username, git info)
3. Update `flake.nix` with your values
4. Install Nix (if needed)
5. Bootstrap nix-darwin
6. Build and apply configuration
7. Run verification tests
8. Run `post-install.sh` automatically
9. Run `setup-ssh.sh` automatically

### Manual Execution (Advanced)

If you need to run scripts individually:

```bash
cd ~/.config/nix

# 1. Pre-flight checks
./scripts/pre-install.sh

# 2. Main installation (updates flake.nix, installs Nix, applies config)
./scripts/install.sh

# 3. Post-install setup (permissions, app launching)
./scripts/post-install.sh

# 4. SSH key setup (GitHub + Bitwarden)
./scripts/setup-ssh.sh
```

## Script Locations and Requirements

### Location Requirements

**All scripts must be located in `~/.config/nix/scripts/`**

The scripts use relative paths to find each other and the configuration files:

- `install.sh` assumes it's in `scripts/` and references:
  - `scripts/pre-install.sh` (same directory)
  - `scripts/post-install.sh` (same directory)
  - `scripts/setup-ssh.sh` (same directory)
  - `flake.nix` (parent directory)

- Scripts reference `dotfiles/` and `modules/` relative to the repository root

**Do not move scripts to different locations** - they will break.

### Execution Requirements

All scripts require:
- Bash shell (macOS default)
- Execution permissions (usually set automatically by Git)
- To be run from the repository root or with correct relative paths

If you get "Permission denied", make scripts executable:
```bash
chmod +x scripts/*.sh
```

## Detailed Script Documentation

### install.sh

**Purpose:** Complete automated installation of the nix-darwin configuration.

**What it does:**
1. **Pre-flight checks** - Verifies Xcode CLI tools and Homebrew are installed
2. **User configuration** - Prompts for:
   - Hostname (auto-detected, can override)
   - Username (auto-detected, can override)
   - Git name (required)
   - Git email (required)
   - System architecture (aarch64-darwin or x86_64-darwin)
3. **Updates flake.nix** - Automatically modifies the flake with your values
4. **Installs Nix** - Downloads and installs Nix if not present
5. **Bootstraps nix-darwin** - Initial nix-darwin setup if needed
6. **Builds configuration** - Runs `darwin-rebuild switch`
7. **Verification** - Checks installed apps, CLI tools, services, and dotfiles
8. **Post-install** - Automatically runs `post-install.sh`
9. **SSH setup** - Automatically runs `setup-ssh.sh`
10. **Powerlevel10k** - Optionally prompts to configure zsh theme

**Execution:**
```bash
cd ~/.config/nix
./scripts/install.sh
```

**Requirements:**
- Must be run from `~/.config/nix/`
- Requires sudo for `darwin-rebuild switch`
- Terminal automation permission for some operations

**Duration:** 10-30 minutes depending on download speeds

**When to use:**
- First-time installation
- Fresh macOS setup
- After cloning the repository to a new machine

### pre-install.sh

**Purpose:** Pre-flight checks before installation to ensure system is ready.

**What it checks:**
1. Xcode Command Line Tools installed
2. Homebrew installed
3. Nix installed (optional - will be installed if missing)
4. Terminal automation permissions

**Execution:**
```bash
cd ~/.config/nix
./scripts/pre-install.sh
```

**Output:**
- Lists all checks with ✓ (pass), ✗ (fail), or ○ (optional)
- Provides instructions for fixing failures
- Exits with error code if critical checks fail

**When to use:**
- Before running `install.sh` (to verify prerequisites)
- Standalone check if something seems wrong
- Troubleshooting installation issues

### post-install.sh

**Purpose:** Configure apps, permissions, and extensions after Nix configuration is applied.

**What it does:**
1. **Zen Browser setup:**
   - Launches Zen Browser
   - Waits for first-run wizard completion
   - Injects saved profile data (settings, themes, shortcuts)
   - Opens extension install pages

2. **App permission setup:**
   - Opens System Settings → Accessibility
   - Launches apps in batches of 3 (to trigger permission prompts)
   - Includes: Rectangle, Sol, BetterDisplay, Stats, Docker, Tailscale, etc.

3. **System Settings:**
   - Opens Keyboard Shortcuts settings (for Spotlight disable instructions)

**Execution:**
```bash
cd ~/.config/nix
./scripts/post-install.sh
```

**Requirements:**
- Must be run after `darwin-rebuild switch` completes
- Apps must be installed (via Homebrew or Nix)
- Requires user interaction (press Enter between steps)

**Interactive prompts:**
- Press Enter to start Zen setup
- Press Enter after completing Zen wizard
- Press Enter to open extension pages
- Press Enter between app launch batches

**When to use:**
- After first installation
- After applying configuration changes
- When apps need permission re-granting

### setup-ssh.sh

**Purpose:** Set up SSH keys for GitHub and other services.

**What it does:**
1. **GitHub authentication:**
   - Checks if authenticated with `gh auth login`
   - Prompts for browser authentication if needed
   - Automatically generates and uploads SSH key

2. **Bitwarden key retrieval:**
   - Prompts to retrieve keys from Bitwarden
   - Logs in/unlocks Bitwarden vault
   - Retrieves keys from "ssh" folder
   - Saves keys to `~/.ssh/` with correct permissions
   - Generates public keys automatically

3. **SSH agent:**
   - Starts ssh-agent if needed
   - Adds all keys to agent

**Execution:**
```bash
cd ~/.config/nix
./scripts/setup-ssh.sh
```

**Requirements:**
- GitHub CLI (`gh`) installed (via Nix)
- Bitwarden CLI (`bw`) installed (via Nix, optional)
- Bitwarden account access (optional)

**See also:** [SSH Setup Guide](./SSH_SETUP.md) for detailed Bitwarden workflow

**When to use:**
- After first installation
- When setting up SSH keys on a new machine
- After retrieving keys from Bitwarden

### test-settings.sh

**Purpose:** Verify that configuration settings are applied correctly.

**What it checks:**
- System preferences
- Installed applications
- CLI tools availability
- Services running
- Dotfiles present

**Execution:**
```bash
cd ~/.config/nix
./scripts/test-settings.sh
```

**When to use:**
- After configuration changes
- Troubleshooting issues
- Verifying installation success

## Script Dependencies

```
install.sh
├── pre-install.sh (runs automatically)
├── post-install.sh (runs automatically at end)
└── setup-ssh.sh (runs automatically at end)

All other scripts are independent and can run standalone.
```

## Running Scripts from Different Locations

**Recommended:** Always run from repository root:
```bash
cd ~/.config/nix
./scripts/script-name.sh
```

**Alternative:** Run with absolute path:
```bash
~/.config/nix/scripts/script-name.sh
```

**Not recommended:** Running from inside `scripts/` directory (paths will break)

## Troubleshooting Script Execution

### "Permission denied"

**Error:** `bash: ./scripts/install.sh: Permission denied`

**Solution:**
```bash
chmod +x scripts/*.sh
```

### "No such file or directory"

**Error:** Script can't find `flake.nix` or other files

**Solution:**
- Ensure you're running from `~/.config/nix/`
- Check that all files exist in expected locations
- Verify repository structure is intact

### Script fails silently

**Error:** Script exits without output

**Solution:**
- Check script has `set -e` (exits on error)
- Run with `bash -x` for debug output:
  ```bash
  bash -x ./scripts/install.sh
  ```

### Path issues in scripts

**Error:** Scripts reference wrong paths

**Solution:**
- All scripts use `SCRIPT_DIR` variable to find their location
- Scripts reference parent directory with `$(dirname "$SCRIPT_DIR")`
- Don't modify these path calculations

## Customizing Scripts

### Adding New Keys to setup-ssh.sh

Edit `scripts/setup-ssh.sh` and add to the `KEYS` array:

```bash
KEYS=(
    "existing-key:$HOME/.ssh/existing-key"
    "new-key:$HOME/.ssh/new-key"  # Add this line
)
```

### Modifying App List in post-install.sh

Edit `scripts/post-install.sh` and modify the `APPS` array:

```bash
APPS=(
    "/Applications/ExistingApp.app"
    "/Applications/NewApp.app"  # Add this line
)
```

### Changing Batch Size in post-install.sh

Edit `scripts/post-install.sh`:

```bash
BATCH_SIZE=5  # Change from 3 to 5
```

## Script Safety and Idempotency

**Install scripts are safe to run multiple times:**
- `install.sh` - Checks if components exist before installing
- `pre-install.sh` - Only checks, doesn't modify
- `post-install.sh` - Safe to re-run (opens apps, checks permissions)
- `setup-ssh.sh` - Checks if keys exist, won't overwrite without prompting

**Backup before major changes:**
- Scripts modify `flake.nix` automatically
- Consider committing changes or backing up before running

## Related Documentation

- [SSH Setup Guide](./SSH_SETUP.md) - Detailed Bitwarden workflow for SSH keys
- [Post-Install Guide](./POST_INSTALL.md) - Detailed post-install configuration
- [Main README](../README.md) - Overview of the configuration
