# ==============================================================================
# SYSTEM CONFIGURATION
# ==============================================================================
# macOS system preferences, keyboard, security, and activation scripts
# ==============================================================================

{ config, lib, pkgs, username, homeDirectory, hostname, ... }:

{
  # ============================================================================
  # NIX SETTINGS
  # ============================================================================
  nix.enable = false;
  system.stateVersion = 5;

  # ============================================================================
  # SECURITY
  # ============================================================================
  security.pam.services.sudo_local.touchIdAuth = true;

  # ============================================================================
  # APPLICATION FIREWALL
  # ============================================================================
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = false;  # Respond to pings
  };

  # ============================================================================
  # SYSTEM DEFAULTS - macOS UI Preferences
  # ============================================================================
  system.defaults = {
    # --------------------------------------------------------------------------
    # DOCK SETTINGS
    # --------------------------------------------------------------------------
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
      tilesize = 48;
      orientation = "right";

      # Hot Corners (1 = Disabled)
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;

      # Persistent Dock Apps
      persistent-apps = [
        "/Applications/Nix Apps/Zen Browser (Beta).app"
        "/Applications/Obsidian.app"
        "/Applications/Ghostty.app"
      ];

      expose-animation-duration = 0.1;
      show-process-indicators = true;
      showhidden = true;
    };

    # --------------------------------------------------------------------------
    # FINDER SETTINGS
    # --------------------------------------------------------------------------
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "clmv";
      _FXShowPosixPathInTitle = true;
      FXDefaultSearchScope = "SCcf";
      NewWindowTarget = "Home";
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXRemoveOldTrashItems = true;
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
    };

    # --------------------------------------------------------------------------
    # TRACKPAD SETTINGS
    # --------------------------------------------------------------------------
    trackpad = {
      Clicking = false;
      TrackpadThreeFingerDrag = false;
    };

    # --------------------------------------------------------------------------
    # WINDOW MANAGER
    # --------------------------------------------------------------------------
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
    };

    # --------------------------------------------------------------------------
    # SPACES
    # --------------------------------------------------------------------------
    spaces.spans-displays = false;

    # NOTE: Universal Access settings (reduceMotion, reduceTransparency, zoom)
    # must be set manually in System Settings → Accessibility

    # --------------------------------------------------------------------------
    # GLOBAL MACOS SETTINGS
    # --------------------------------------------------------------------------
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.trackpad.forceClick" = false;
      "com.apple.keyboard.fnState" = true;

      # Disable "smart" typing features
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Speed up animations
      NSAutomaticWindowAnimationsEnabled = false;

      # Expand save panels
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Appearance
      AppleInterfaceStyle = "Dark";
      AppleShowScrollBars = "WhenScrolling";

      # Windows & Dialogs
      NSWindowShouldDragOnGesture = false;
      NSDocumentSaveNewDocumentsToCloud = false;

      # Sound
      "com.apple.sound.beep.feedback" = 0;
    };

    # --------------------------------------------------------------------------
    # SCREENSHOTS
    # --------------------------------------------------------------------------
    screencapture = {
      location = "/Users/${username}/Downloads";
      disable-shadow = true;
    };

    # --------------------------------------------------------------------------
    # LOGIN WINDOW
    # --------------------------------------------------------------------------
    loginwindow = {
      GuestEnabled = false;
      LoginwindowText = hostname;
    };

    # --------------------------------------------------------------------------
    # MENU BAR CLOCK
    # --------------------------------------------------------------------------
    menuExtraClock = {
      IsAnalog = true;      # Analog clock display
      ShowSeconds = false;
      ShowDate = 2;         # Never show date
    };

    # --------------------------------------------------------------------------
    # CONTROL CENTER - Menu bar items
    # --------------------------------------------------------------------------
    controlcenter = {
      BatteryShowPercentage = false;
      Bluetooth = false;
      Sound = true;         # Show volume in menu bar
      NowPlaying = false;
    };

    # --------------------------------------------------------------------------
    # AUTO-HIDE MENU BAR (sketchybar becomes primary)
    # --------------------------------------------------------------------------
    # Menu bar always visible (not auto-hide)
    NSGlobalDomain."_HIHideMenuBar" = false;


    # --------------------------------------------------------------------------
    # CUSTOM USER PREFERENCES
    # --------------------------------------------------------------------------
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      # Locale settings (Australia)
      NSGlobalDomain = {
        AppleLocale = "en_AU";
        AppleLanguages = [ "en-AU" ];
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleActionOnDoubleClick = "None";  # Disable double-click title bar zoom
      };
      # Disable Spotlight keyboard shortcuts (using Sol instead)
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Disable "Show Spotlight search" (Cmd+Space)
          "64" = { enabled = false; };
          # Disable "Show Finder search window" (Cmd+Alt+Space)
          "65" = { enabled = false; };
        };
      };
      # Disable two-finger swipe from right edge to show Notification Center
      "com.apple.AppleMultitouchTrackpad" = {
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 0;
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 0;
      };
      # Hide input sources (keyboard layouts) from menu bar
      "com.apple.TextInputMenu" = {
        visible = false;
      };
    };
  };

  # ============================================================================
  # KEYBOARD REMAPPING
  # ============================================================================
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # ============================================================================
  # ACTIVATION SCRIPTS
  # ============================================================================
  system.activationScripts.postActivation.text = ''
    # Clone CameraController if not already present
    echo "Checking CameraController..."
    SRC_DIR="${homeDirectory}/Developer/CameraController"
    if [ ! -d "$SRC_DIR" ]; then
      mkdir -p "${homeDirectory}/Developer"
      ${pkgs.git}/bin/git clone https://github.com/Itaybre/CameraController.git "$SRC_DIR"
    fi

    # Power management: Disable display sleep when connected to power
    echo "Setting power management (display never sleeps on AC power)..."
    /usr/bin/pmset -c displaysleep 0
  '';

  # ============================================================================
  # USER CONFIGURATION
  # ============================================================================
  users.users.${username} = {
    name = username;
    home = homeDirectory;
  };

  system.primaryUser = username;

  # Enable zsh as the system shell
  programs.zsh.enable = true;
}

