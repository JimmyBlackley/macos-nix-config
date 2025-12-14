# SSH Key Setup Guide

This guide explains how to set up SSH keys for GitHub and other services using the automated setup script and Bitwarden integration.

## Overview

The SSH setup process consists of two parts:
1. **GitHub Authentication** - Automatic key generation and upload via GitHub CLI
2. **Other Keys from Bitwarden** - Retrieve additional SSH keys stored in your Bitwarden vault

## Prerequisites

### Required
- GitHub CLI (`gh`) - Installed automatically via the Nix configuration
- Git - Installed automatically via the Nix configuration

### Optional (for Bitwarden keys)
- Bitwarden CLI (`bw`) - Installed automatically via the Nix configuration (`bitwarden-cli`)
- Active Bitwarden account with vault access
- Bitwarden vault unlocked or session available

## Step-by-Step Guide

### Part 1: GitHub SSH Key Setup

The GitHub setup is fully automated:

1. **Run the setup script:**
   ```bash
   cd ~/.config/nix
   ./scripts/setup-ssh.sh
   ```

2. **Authenticate with GitHub:**
   - If not already authenticated, the script will prompt you
   - A browser window will open for GitHub authentication
   - Follow the prompts to authorize the GitHub CLI
   - Select SSH as your preferred Git protocol

3. **Automatic key generation:**
   - If no SSH key exists, `gh auth login` will automatically generate `~/.ssh/id_ed25519`
   - The public key will be uploaded to your GitHub account
   - The key will be titled with your computer's hostname

4. **Verification:**
   ```bash
   ssh -T git@github.com
   ```
   You should see: `Hi username! You've successfully authenticated...`

### Part 2: Bitwarden SSH Keys Setup

To retrieve additional SSH keys from Bitwarden:

#### 1. Install and Authenticate Bitwarden CLI

If `bw` is not installed, it will be available after running `darwin-rebuild switch`.

**First-time setup:**
```bash
# Login to Bitwarden
bw login your-email@example.com

# Unlock your vault (you'll be prompted for master password)
bw unlock
```

**Subsequent uses:**
```bash
# Unlock vault (stays unlocked for current session)
bw unlock
```

The setup script will handle authentication automatically if you're not already logged in.

#### 2. Create the SSH Folder in Bitwarden

1. Open Bitwarden (web, desktop app, or CLI)
2. Create a new folder named exactly: **`ssh`** (case-sensitive)
3. This folder will contain all your SSH key Secure Notes

#### 3. Add SSH Keys as Secure Notes

For each SSH key you want to store:

1. **Create a Secure Note:**
   - In Bitwarden, navigate to the `ssh` folder
   - Click "Add Item" → "Secure Note"
   - Name the note exactly as the target filename (see mapping below)

2. **Add the private key content:**
   - Copy the entire private key content (including `-----BEGIN` and `-----END` lines)
   - Paste it into the "Notes" field of the Secure Note
   - Save the note

3. **Important naming rules:**
   - The note name must exactly match the target filename
   - Use forward slashes (`/`) for subdirectories (e.g., `keys/mykey.key`)
   - Do NOT include the file path, only the filename
   - Do NOT store `.pub` files (public keys are generated automatically)

#### 4. Run the Setup Script

```bash
cd ~/.config/nix
./scripts/setup-ssh.sh
```

When prompted:
- Enter `y` to retrieve keys from Bitwarden
- Enter your Bitwarden email if logging in for the first time
- Enter your master password when prompted to unlock
- Wait for the script to retrieve and install keys

#### 5. Verify Keys Are Installed

```bash
# Check SSH directory
ls -la ~/.ssh/

# Check keys directory (if you have keys in subdirectories)
ls -la ~/.ssh/keys/

# Test keys are loaded in ssh-agent
ssh-add -l
```

## Bitwarden Folder Structure

### Required Structure

In Bitwarden, create a folder named `ssh` (case-sensitive) and add Secure Notes with these exact names:

```
Bitwarden
└── ssh (folder)
    ├── id_ed25519 (Secure Note)
    ├── id_rsa (Secure Note)
    ├── access_token_tidey (Secure Note)
    └── keys/ (path separator in note name)
        ├── ssh-key-2025-01-07.key (Secure Note named "keys/ssh-key-2025-01-07.key")
        ├── ssh-key-2025-04-08.key (Secure Note named "keys/ssh-key-2025-04-08.key")
        └── tide.key (Secure Note named "keys/tide.key")
```

### Note Name → File Path Mapping

The script maps Bitwarden note names to file paths as follows:

| Bitwarden Note Name | Target File Path | Notes |
|---------------------|------------------|-------|
| `id_ed25519` | `~/.ssh/id_ed25519` | Main SSH key |
| `id_rsa` | `~/.ssh/id_rsa` | RSA key (legacy) |
| `access_token_tidey` | `~/.ssh/access_token_tidey` | Token file (no `.pub` generated) |
| `keys/ssh-key-2025-01-07.key` | `~/.ssh/keys/ssh-key-2025-01-07.key` | Subdirectory key |
| `keys/ssh-key-2025-04-08.key` | `~/.ssh/keys/ssh-key-2025-04-08.key` | Subdirectory key |
| `keys/tide.key` | `~/.ssh/keys/tide.key` | Subdirectory key |

**Important:** 
- Use forward slashes in note names to create subdirectories
- The script automatically creates parent directories as needed
- Only store private keys - public keys (`.pub`) are generated automatically

### Example Secure Note Content

For a Secure Note named `id_rsa`, the Notes field should contain:

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACD... (rest of key content) ...
-----END OPENSSH PRIVATE KEY-----
```

Or for an older RSA key:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA... (rest of key content) ...
-----END RSA PRIVATE KEY-----
```

## Technical Details

### How the Script Works

The `setup-ssh.sh` script performs the following operations:

1. **Directory Setup:**
   ```bash
   mkdir -p "$HOME/.ssh"
   mkdir -p "$HOME/.ssh/keys"
   chmod 700 "$HOME/.ssh"
   chmod 700 "$HOME/.ssh/keys"
   ```

2. **GitHub Authentication:**
   - Checks if `gh` CLI is available
   - Runs `gh auth login --web --git-protocol ssh` if not authenticated
   - GitHub CLI automatically generates and uploads SSH keys

3. **Bitwarden Integration:**
   - Checks if `bw` CLI is installed
   - Prompts user to unlock Bitwarden vault
   - Finds the `ssh` folder ID using: `bw list folders`
   - For each configured key:
     - Searches for Secure Note by name in the `ssh` folder
     - Extracts content from the note's `.notes` field
     - Writes content to target file path
     - Sets file permissions to `600` (read/write for owner only)
     - Generates public key using `ssh-keygen -y -f <private-key>`
     - Skips public key generation for files containing "token" or "access" in name

4. **SSH Agent Integration:**
   - Starts `ssh-agent` if not running
   - Adds all retrieved keys to the agent using `ssh-add`

### Key Generation Logic

Public keys are automatically generated for SSH private keys:

```bash
ssh-keygen -y -f "$target_path" > "${target_path}.pub"
```

**Exceptions:** Files with "token" or "access" in their name do not get `.pub` files generated, as they are not SSH keys but access tokens.

### File Permissions

All private keys are set with restrictive permissions:
- `600` (rw-------): Read/write for owner only
- This prevents other users from reading your keys

### SSH Config File

The SSH config file (`~/.ssh/config`) is managed separately by Nix via `modules/home.nix`. It's sourced from `dotfiles/ssh/config` and is not affected by the setup script.

### Known Hosts

The `~/.ssh/known_hosts` file is also managed by Nix from `dotfiles/ssh/known_hosts`.

## Adding New Keys to Bitwarden

To add a new SSH key:

1. **Generate the key** (if you don't have one):
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/my-new-key
   ```

2. **Copy the private key:**
   ```bash
   cat ~/.ssh/my-new-key
   ```

3. **Add to Bitwarden:**
   - Open Bitwarden
   - Go to the `ssh` folder
   - Create a new Secure Note
   - Name it: `my-new-key` (or `keys/my-new-key` for subdirectory)
   - Paste the private key content in the Notes field
   - Save

4. **Update the script (if needed):**
   - The script has a hardcoded list of keys to retrieve
   - To add a new key, edit `scripts/setup-ssh.sh`
   - Add your key to the `KEYS` array:
     ```bash
     KEYS=(
         # ... existing keys ...
         "my-new-key:$HOME/.ssh/my-new-key"
     )
     ```

5. **Run the setup script again:**
   ```bash
   ./scripts/setup-ssh.sh
   ```

## Troubleshooting

### Bitwarden folder not found

**Error:** `Folder 'ssh' not found in Bitwarden, skipping`

**Solution:**
- Ensure the folder is named exactly `ssh` (lowercase, no spaces)
- Check folder name spelling in Bitwarden
- Run `bw list folders` to see all folders

### Key not found in Bitwarden

**Error:** `not found` or `no content in notes`

**Solution:**
- Verify the Secure Note name matches exactly (case-sensitive)
- Ensure the note is in the `ssh` folder
- Check that the Notes field contains the key content (not empty)
- Verify the note name doesn't include the file path, only the filename

### Public key generation fails

**Error:** No `.pub` file created

**Possible causes:**
- Invalid private key format
- Key is encrypted with a passphrase (script doesn't handle passphrases)
- File is a token (expected - tokens don't get `.pub` files)

**Solution:**
- Verify the private key format is correct
- If key has a passphrase, remove it or use `ssh-keygen -p` to set an empty passphrase
- For tokens, this is expected behavior

### Bitwarden authentication fails

**Error:** `Failed to unlock Bitwarden`

**Solution:**
- Ensure you're using the correct master password
- Check your Bitwarden account status
- Try logging in manually: `bw login your-email@example.com`
- Check if 2FA is enabled and provide the code when prompted

### GitHub authentication fails

**Error:** `GitHub CLI (gh) is not installed`

**Solution:**
- Ensure the Nix configuration has been applied: `sudo darwin-rebuild switch --flake ~/.config/nix`
- Restart your terminal to pick up the new environment
- Verify `gh` is installed: `command -v gh`

### SSH agent not loading keys

**Error:** Keys not available after setup

**Solution:**
- Check if ssh-agent is running: `eval "$(ssh-agent -s)"`
- Manually add keys: `ssh-add ~/.ssh/id_ed25519`
- Check keys in agent: `ssh-add -l`
- For persistent agent, add to your shell config:
  ```bash
  # ~/.zshrc or ~/.bashrc
  if [ -z "$SSH_AUTH_SOCK" ]; then
     eval "$(ssh-agent -s)"
  fi
  ```

## Security Best Practices

1. **Never commit private keys to Git** - They're stored in Bitwarden for a reason
2. **Use strong Bitwarden master password** - This protects all your stored keys
3. **Enable 2FA on Bitwarden** - Adds an extra layer of security
4. **Rotate keys periodically** - Especially if a key may have been compromised
5. **Use Ed25519 keys** - They're more secure and faster than RSA
6. **Set appropriate file permissions** - The script does this automatically (600)
7. **Don't share private keys** - Each system should have its own keys

## Related Documentation

- [Scripts Guide](./SCRIPTS.md) - More details on script execution
- [Main README](../README.md) - Overview of the configuration
