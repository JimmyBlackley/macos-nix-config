# ==============================================================================
# SERVICES CONFIGURATION
# ==============================================================================
# System services and launchd agents
# ==============================================================================

{ config, lib, pkgs, username, ... }:

{
  # ============================================================================
  # SERVICES
  # ============================================================================
  # services.sketchybar.enable = true;  # Disabled - need native menu bar for app menus
  services.tailscale.enable = true;

  # ============================================================================
  # LAUNCHD AGENTS
  # ============================================================================
  launchd.user.agents.betterdisplay-cleanup = {
    serviceConfig = {
      Label = "org.nixdarwin.betterdisplay.cleanup";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          mkdir -p "$HOME/Library/Logs"
          echo "$(date): Starting BetterDisplay cleanup" >> "$HOME/Library/Logs/betterdisplay_cleanup.log"

          rm -f "$HOME/Library/Application Support/BetterDisplay/762421.padl" 2>/dev/null && \
              echo "$(date): Deleted 762421.padl" >> "$HOME/Library/Logs/betterdisplay_cleanup.log"

          rm -f "$HOME/Library/Application Support/BetterDisplay/762421.spadl" 2>/dev/null && \
              echo "$(date): Deleted 762421.spadl" >> "$HOME/Library/Logs/betterdisplay_cleanup.log"

          if [ -d "$HOME/Library/Application Support/BetterDisplay" ]; then
              rm -rf "$HOME/Library/Application Support/BetterDisplay"/* 2>/dev/null && \
                  echo "$(date): Cleaned BetterDisplay directory" >> "$HOME/Library/Logs/betterdisplay_cleanup.log"
          fi

          /usr/bin/python3 -c "
import plistlib
from pathlib import Path
try:
    plist_path = Path.home() / 'Library' / 'Preferences' / 'pro.betterdisplay.BetterDisplay.plist'
    if plist_path.exists():
        with open(plist_path, 'rb') as f:
            data = plistlib.load(f)
        if 'Paddle-BetterDisplay-762421-SD' in data:
            del data['Paddle-BetterDisplay-762421-SD']
            with open(plist_path, 'wb') as f:
                plistlib.dump(data, f)
            print('Removed plist key')
        else:
            print('Plist key not found')
    else:
        print('Plist file not found')
except Exception as e:
    print(f'Error processing plist: {e}')
" >> "$HOME/Library/Logs/betterdisplay_cleanup.log" 2>&1

          echo "$(date): BetterDisplay cleanup completed" >> "$HOME/Library/Logs/betterdisplay_cleanup.log"
        ''
      ];
      RunAtLoad = true;
      ProcessType = "Background";
      Nice = -10;
      StandardOutPath = "/Users/${username}/Library/Logs/betterdisplay_cleanup.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/betterdisplay_cleanup_error.log";
    };
  };

  launchd.user.agents.capslock-to-escape = {
    serviceConfig = {
      Label = "org.nixdarwin.capslock-to-escape";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''/usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' || true''
      ];
      RunAtLoad = true;
      ProcessType = "Background";
    };
  };

  # Set JAVA_HOME for GUI applications (like Prism Launcher)
  launchd.user.agents.java-env = {
    serviceConfig = {
      Label = "org.nixdarwin.java-env";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          # Set JAVA_HOME and PATH for GUI applications
          launchctl setenv JAVA_HOME "${pkgs.jdk25}"
          launchctl setenv PATH "${pkgs.jdk25}/bin:$PATH"
        ''
      ];
      RunAtLoad = true;
      ProcessType = "Background";
    };
  };
}

