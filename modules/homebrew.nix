# ==============================================================================
# HOMEBREW CONFIGURATION
# ==============================================================================
# GUI applications and casks installed via Homebrew
#
# WHY HOMEBREW FOR THESE?
# - GUI applications often require macOS-specific installation
# - Many are proprietary and only distributed via Homebrew casks
# - Homebrew handles code signing and Gatekeeper properly
# - Some apps auto-update themselves and conflict with Nix management
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  homebrew = {
    enable = true;

    # "zap" removes all casks not listed here on activation
    # Using "none" for first run to avoid removing existing apps
    # Change to "zap" once you've added all your apps to the list
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

    # Additional Homebrew taps
    taps = [
      "mhaeuser/mhaeuser"
    ];

    casks = [
      # -- Web Browsers --
      "ungoogled-chromium"

      # -- Code Editors & IDEs --
      "visual-studio-code"
      "zed"
      "cursor"

      # -- Terminals --
      # Note: Use "ghostty" for stable or "ghostty@tip" for nightly (can't have both)
      "ghostty"

      # -- Development Tools --
      "docker-desktop"
      "beekeeper-studio"
      "arduino-ide"
      "utm"
      "jprofiler"

      # -- Networking --
      "tailscale-app"

      # -- 3D & Design Tools --
      "blender"
      "inkscape"
      "autodesk-fusion"
      "ultimaker-cura"
      "figma"

      # -- Media Players --
      "vlc"
      "stolendata-mpv"
      "spotify"
      "tidal"

      # -- Creative & Production --
      "reaper"

      # -- Productivity & Notes --
      "obsidian"
      "calibre"

      # -- System Utilities --
      # Sol launcher installed via Nix (packages/sol.nix)
      "hiddenbar"            # Hide menu bar icons
      "battery-toolkit"
      "balenaetcher"
      "betterdisplay"
      "stats"
      "rectangle"
      "keka"
      "pdfsam-basic"

      # -- Communication --
      "bitwarden"
      "slack"

      # -- Entertainment --
      "steam"
    ];
  };
}

