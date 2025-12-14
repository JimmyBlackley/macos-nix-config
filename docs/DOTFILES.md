# Adding Custom Dotfiles

This guide explains how to add your own dotfiles to the configuration and have them automatically linked to the correct locations on your system.

## Overview

The configuration manages dotfiles using Nix's `home-manager` module. Dotfiles are stored in the `dotfiles/` directory and automatically symlinked to their target locations when the configuration is applied.

## Current Dotfiles Structure

```
dotfiles/
├── ghostty/              # Terminal configuration
│   └── config
├── p10k/                 # Powerlevel10k zsh theme
│   └── .p10k.zsh
├── sketchybar/           # Menu bar configuration
│   ├── sketchybarrc
│   └── plugins/          # Custom menu bar plugins
├── stats/                # Stats.app preferences
│   └── eu.exelban.Stats.plist
├── rectangle/            # Rectangle window manager
│   └── RectangleConfig.json
├── ssh/                  # SSH configuration
│   ├── config
│   ├── known_hosts
│   └── *.pub            # Public keys (generated, not managed)
└── zen/                  # Zen Browser profile
    ├── profiles.ini
    ├── extensions.txt
    └── profile/          # Browser settings, themes, etc.
```

## How Dotfiles Are Managed

### Linking Mechanism

Dotfiles are linked via `modules/home.nix` using `home-manager`'s file management:

```nix
home.file = {
  ".config/ghostty/config" = {
    source = ../dotfiles/ghostty/config;
  };
};
```

This creates a symlink:
- **Source:** `~/.config/nix/dotfiles/ghostty/config`
- **Target:** `~/.config/ghostty/config`

### File Types Supported

The configuration supports various dotfile locations:

1. **XDG Config Directory** (`~/.config/`):
   ```nix
   xdg.configFile."app/config".source = ../dotfiles/app/config;
   ```

2. **Home Directory** (`~/`):
   ```nix
   home.file.".apprc".source = ../dotfiles/app/.apprc;
   ```

3. **Library Preferences** (`~/Library/Preferences/`):
   ```nix
   home.file."Library/Preferences/com.app.prefs.plist" = {
     source = ../dotfiles/app/prefs.plist;
   };
   ```

4. **Application Support** (`~/Library/Application Support/`):
   ```nix
   home.file."Library/Application Support/App/config.json" = {
     source = ../dotfiles/app/config.json;
   };
   ```

## Adding Your Own Dotfiles

### Step 1: Create the Dotfile Directory

Create a directory for your application's dotfiles:

```bash
mkdir -p ~/.config/nix/dotfiles/your-app
```

### Step 2: Add Your Configuration File

Copy your existing configuration file to the dotfiles directory:

```bash
# If you already have the config file
cp ~/.config/your-app/config ~/.config/nix/dotfiles/your-app/config

# Or create a new one
nano ~/.config/nix/dotfiles/your-app/config
```

### Step 3: Update modules/home.nix

Edit `modules/home.nix` and add your dotfile to the `home.file` or `xdg.configFile` section.

**Example: Adding a config file to `~/.config/your-app/config`:**

```nix
{ config, pkgs, ... }:
{
  home-manager.users."${username}" = {
    # ... existing configuration ...
    
    xdg.configFile = {
      # ... existing config files ...
      
      # Your new dotfile
      "your-app/config".source = ../dotfiles/your-app/config;
    };
  };
}
```

**Example: Adding a file to home directory (`~/.yourrc`):**

```nix
home.file = {
  # ... existing files ...
  
  ".yourrc" = {
    source = ../dotfiles/your-app/.yourrc;
  };
};
```

**Example: Adding a macOS plist file:**

```nix
home.file = {
  # ... existing files ...
  
  "Library/Preferences/com.your.app.plist" = {
    source = ../dotfiles/your-app/prefs.plist;
    force = true;  # Overwrite if exists
  };
};
```

### Step 4: Apply the Configuration

Apply the changes:

```bash
cd ~/.config/nix
sudo darwin-rebuild switch --flake .
```

### Step 5: Verify

Check that the symlink was created:

```bash
ls -la ~/.config/your-app/config
# Should show: config -> /Users/username/.config/nix/dotfiles/your-app/config
```

## Advanced Examples

### Multiple Files for One Application

If your app has multiple config files:

```nix
xdg.configFile = {
  "your-app/config.json" = {
    source = ../dotfiles/your-app/config.json;
  };
  "your-app/themes/theme.json" = {
    source = ../dotfiles/your-app/theme.json;
  };
};
```

### Entire Directory

To link an entire directory:

```nix
xdg.configFile."your-app" = {
  source = ../dotfiles/your-app;
  recursive = true;  # Copy directory recursively
};
```

**Note:** Using `recursive = true` copies the directory contents, not a symlink. This is useful when apps modify files in place.

### File with Text Substitution

For files that need variable substitution:

```nix
home.file.".gitconfig" = {
  text = ''
    [user]
      name = ${gitName}
      email = ${gitEmail}
    [core]
      editor = nvim
  '';
};
```

### Conditional Files

Only link file if a condition is met:

```nix
home.file = {
  ".zshrc.local" = lib.mkIf (username == "james") {
    source = ../dotfiles/james/.zshrc.local;
  };
};
```

### Force Overwrite

Some apps create default config files. Use `force = true` to overwrite:

```nix
home.file."Library/Preferences/com.app.prefs.plist" = {
  source = ../dotfiles/app/prefs.plist;
  force = true;  # Overwrite existing file
};
```

## Managing Existing Dotfiles

### Updating an Existing Dotfile

1. Edit the file in `dotfiles/`:
   ```bash
   nano ~/.config/nix/dotfiles/ghostty/config
   ```

2. Apply changes:
   ```bash
   sudo darwin-rebuild switch --flake ~/.config/nix
   ```

The changes are immediately active since it's a symlink.

### Removing a Dotfile

1. Remove from `modules/home.nix`
2. Remove from `dotfiles/` directory (optional)
3. Apply changes:
   ```bash
   sudo darwin-rebuild switch --flake ~/.config/nix
   ```

The symlink will be removed, but the original file (if it existed) won't be deleted.

### Backing Up Existing Dotfiles

Before adding a dotfile to the configuration, backup any existing versions:

```bash
# Backup existing config
cp ~/.config/your-app/config ~/.config/your-app/config.backup

# Copy to dotfiles directory
cp ~/.config/your-app/config ~/.config/nix/dotfiles/your-app/config
```

## Special Cases

### SSH Keys

SSH keys are handled specially:
- Private keys: Managed by `scripts/setup-ssh.sh` (from Bitwarden or GitHub)
- Public keys: Generated automatically from private keys
- Config file: Managed via `dotfiles/ssh/config` → `~/.ssh/config`
- Known hosts: Managed via `dotfiles/ssh/known_hosts` → `~/.ssh/known_hosts`

**Do not add SSH private keys to dotfiles/** - they should be in Bitwarden.

### Zen Browser Profile

Zen Browser profile is handled by `scripts/post-install.sh`:
- Profile data in `dotfiles/zen/profile/` is copied (not symlinked) after first launch
- This is because Zen modifies files in place

See [Post-Install Guide](./POST_INSTALL.md) for details.

### Powerlevel10k

Powerlevel10k config (`~/.p10k.zsh`) is managed separately:
- Generated by running `p10k configure`
- Stored in `dotfiles/p10k/.p10k.zsh`
- Linked via `home.file.".p10k.zsh"`

## File Permissions

Nix preserves file permissions from the source. For sensitive files, ensure correct permissions in dotfiles directory:

```bash
chmod 600 ~/.config/nix/dotfiles/your-app/secret-config
```

## Best Practices

1. **Organize by application:** Keep each app's files in its own directory
2. **Use descriptive names:** Name files clearly (e.g., `config.json` not `c.json`)
3. **Document special cases:** Add comments in `home.nix` for complex setups
4. **Version control:** Commit dotfiles to Git (except secrets)
5. **Test changes:** Apply and verify after adding new dotfiles
6. **Keep it minimal:** Only add files you actually customize
7. **Use .gitignore:** Exclude sensitive files from Git

## Troubleshooting

### Symlink not created

**Problem:** File exists but isn't a symlink

**Solution:**
- Check for existing file at target location (remove it first)
- Use `force = true` in the Nix configuration
- Verify the source path is correct

### File not updating

**Problem:** Changes to dotfile don't appear

**Solution:**
- Ensure you edited the file in `dotfiles/` (not the symlink target)
- Some apps cache config - restart the app
- Verify the symlink is correct: `ls -la ~/.config/your-app/config`

### Permission denied

**Problem:** App can't write to config file

**Solution:**
- Some apps need write access - use `recursive = true` to copy instead of symlink
- Check file permissions: `chmod 644 dotfiles/your-app/config`
- For apps that modify configs in place, copying may be necessary

### Path errors in Nix

**Problem:** `error: file '...' was not found`

**Solution:**
- Verify the path is relative to `modules/home.nix`
- Use `../dotfiles/` (go up from `modules/` to root, then into `dotfiles/`)
- Check the file actually exists: `ls -la dotfiles/your-app/config`

## Related Documentation

- [Main README](../README.md) - Overview of the configuration
- [Post-Install Guide](./POST_INSTALL.md) - Special handling for some dotfiles
