# ==============================================================================
# JAMES' MACOS SYSTEM CONFIGURATION
# ==============================================================================
# A nix-darwin + home-manager configuration for macOS
#
# TABLE OF CONTENTS
# -----------------
# 1. INPUTS                    - Flake dependencies (nixpkgs, nix-darwin, etc.)
# 2. CONFIGURATION VARIABLES   - Hostname, username, and system architecture
# 3. NIX SETTINGS              - Experimental features and system state
# 4. SECURITY                  - PAM, Touch ID authentication
# 5. SYSTEM DEFAULTS           - macOS UI preferences (Dock, Finder, etc.)
# 6. PACKAGE OVERLAYS          - Custom package definitions
# 7. SYSTEM PACKAGES           - Nix-installed command-line tools and apps
# 8. FONTS                     - System fonts installed via Nix
# 9. HOMEBREW                  - GUI apps and casks that require Homebrew
# 10. ACTIVATION SCRIPTS       - Post-activation setup tasks
# 11. USER CONFIGURATION       - User account settings
# 12. HOME MANAGER             - Per-user configuration (Git, ZSH, etc.)
#
# CUSTOMIZATION GUIDE
# -------------------
# - Sections marked [SAFE TO MODIFY] can be freely customized
# - Sections marked [MODIFY WITH CAUTION] affect core system behavior
# - Look for TODO and PLACEHOLDER comments for items needing attention
# ==============================================================================

{
  description = "James' MacOS System Configuration";

  # ============================================================================
  # 1. INPUTS - Flake Dependencies
  # ============================================================================
  # [MODIFY WITH CAUTION] These define the sources for all packages and modules
  # Changing these URLs can affect system stability and package availability
  # ============================================================================
  inputs = {
    # Main package repository - using unstable for latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # nix-darwin - macOS system configuration management
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # home-manager - per-user configuration management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # Ghostty terminal emulator - installed from source
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ghostty, ... }:
  let
    # ==========================================================================
    # 2. CONFIGURATION VARIABLES
    # ==========================================================================
    # [SAFE TO MODIFY] Update these values to match your system
    # These variables are referenced throughout the configuration
    # ==========================================================================
    
    # Your Mac's hostname (used for the darwin configuration name)
    hostname = "macbook-pro";
    
    # Your macOS username (must match your actual user account)
    username = "james";
    
    # System architecture: "aarch64-darwin" for Apple Silicon, "x86_64-darwin" for Intel
    system = "aarch64-darwin";
    
    # Convenience variable for user's home directory
    homeDirectory = "/Users/${username}";
  in
  {
    darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        home-manager.darwinModules.home-manager
        {
          # ====================================================================
          # 3. NIX SETTINGS
          # ====================================================================
          # [MODIFY WITH CAUTION] Core Nix configuration
          # ====================================================================
          
          # Enable flakes and the new nix command interface
          nix.settings.experimental-features = "nix-command flakes";
          
          # nix-darwin state version - increment when upgrading nix-darwin
          # See: https://daiderd.com/nix-darwin/manual/index.html
          system.stateVersion = 5;

          # ====================================================================
          # 4. SECURITY
          # ====================================================================
          # [MODIFY WITH CAUTION] Security-related settings
          # ====================================================================
          
          # Allow using Touch ID for sudo authentication
          security.pam.enableSudoTouchIdAuth = true;

          # ====================================================================
          # 5. SYSTEM DEFAULTS - macOS UI Preferences
          # ====================================================================
          # [SAFE TO MODIFY] These configure macOS system preferences
          # Changes take effect after running darwin-rebuild switch
          # Some changes may require logout/restart to fully apply
          # ====================================================================
          system.defaults = {
            
            # ------------------------------------------------------------------
            # DOCK SETTINGS
            # ------------------------------------------------------------------
            dock = {
              # Auto-hide the dock when not in use
              autohide = true;
              
              # Don't show recently opened apps in a separate dock section
              show-recents = false;
              
              # Don't automatically rearrange Spaces based on most recent use
              mru-spaces = false;
              
              # Dock icon size in pixels (default is 64)
              tilesize = 48;
              
              # Hot Corners Configuration
              # Values: 1 = Disabled, 2 = Mission Control, 3 = App Windows,
              #         4 = Desktop, 5 = Start Screen Saver, 6 = Disable Screen Saver,
              #         10 = Put Display to Sleep, 11 = Launchpad, 12 = Notification Center
              wvous-tl-corner = 1;  # Top-left corner: Disabled
              wvous-tr-corner = 1;  # Top-right corner: Disabled
              wvous-bl-corner = 1;  # Bottom-left corner: Disabled
              wvous-br-corner = 1;  # Bottom-right corner: Disabled
              
              # Persistent Dock Apps
              # IMPORTANT: This only runs ONCE during initial setup.
              # If apps aren't installed yet when this runs, they will be skipped.
              # To reset: delete ~/Library/Preferences/com.apple.dock.plist and rebuild
              # TODO: Ensure these apps are installed before first darwin-rebuild
              persistent-apps = [
                "/Applications/Zen Browser.app"
                "/Applications/Obsidian.app"
                "/Applications/Ghostty.app"
              ];
            };

            # ------------------------------------------------------------------
            # FINDER SETTINGS
            # ------------------------------------------------------------------
            finder = {
              # Show all file extensions
              AppleShowAllExtensions = true;
              
              # Show the path bar at the bottom of Finder windows
              ShowPathbar = true;
              
              # Default view style
              # Values: "Nlsv" = List, "icnv" = Icon, "clmv" = Column, "Flwv" = Gallery
              FXPreferredViewStyle = "clmv";
              
              # Show full POSIX path in Finder window title bar
              _FXShowPosixPathInTitle = true;
              
              # Default search scope
              # Values: "SCcf" = Current Folder, "SCsp" = Previous Scope, "SCev" = This Mac
              FXDefaultSearchScope = "SCcf";
              
              # Default location for new Finder windows
              # Values: "PfHm" = Home, "PfDe" = Desktop, "PfLo" = Other (specify path)
              NewWindowTarget = "PfHm"; 
            };

            # ------------------------------------------------------------------
            # TRACKPAD SETTINGS
            # ------------------------------------------------------------------
            trackpad = {
              # Enable tap-to-click
              Clicking = true;
              
              # Disable three-finger drag (set to true if you prefer it)
              TrackpadThreeFingerDrag = false;
            };
            
            # ------------------------------------------------------------------
            # GLOBAL MACOS SETTINGS
            # ------------------------------------------------------------------
            NSGlobalDomain = {
              # Show all file extensions in Finder
              AppleShowAllExtensions = true;
              
              # Key repeat rate (lower = faster, default is 6)
              KeyRepeat = 2;
              
              # Delay before key repeat starts (lower = shorter delay, default is 25)
              InitialKeyRepeat = 15;
              
              # Enable tap-to-click for the mouse
              "com.apple.mouse.tapBehavior" = 1;
              
              # Disable Force Click and haptic feedback for "Look up & data detectors"
              # This prevents the three-finger tap dictionary lookup
              "com.apple.trackpad.forceClick" = false;
            };
          };

          # ====================================================================
          # 6. PACKAGE OVERLAYS
          # ====================================================================
          # [MODIFY WITH CAUTION] Custom package definitions and overrides
          # ====================================================================
          nixpkgs.overlays = [
            # ------------------------------------------------------------------
            # ntsc-rs Overlay
            # ------------------------------------------------------------------
            # PLACEHOLDER: This overlay defines ntsc-rs but uses placeholder SHA256 hashes.
            # To fix this overlay:
            # 1. Run: nix-prefetch-url --unpack https://github.com/valerio-forty/ntsc-rs/archive/main.tar.gz
            # 2. Replace the sha256 value below with the output
            # 3. Try to build and get the cargoHash from the error message
            # 4. Update cargoHash with the correct value
            # TODO: Replace placeholder SHA256 values with actual hashes
            # ------------------------------------------------------------------
            (final: prev: {
              ntsc-rs = final.rustPlatform.buildRustPackage rec {
                pname = "ntsc-rs";
                version = "git-latest";
                src = final.fetchFromGitHub {
                  owner = "valerio-forty";
                  repo = "ntsc-rs";
                  rev = "main";
                  # PLACEHOLDER: Replace with actual SHA256 hash
                  # Run: nix-prefetch-url --unpack https://github.com/valerio-forty/ntsc-rs/archive/main.tar.gz
                  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
                };
                # PLACEHOLDER: Replace with actual cargo hash
                # Build will fail and provide the correct hash in the error message
                cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
                # Skip tests during build
                doCheck = false;
              };
            })
          ];

          # ====================================================================
          # 7. SYSTEM PACKAGES - Installed via Nix
          # ====================================================================
          # [SAFE TO MODIFY] Command-line tools and applications
          # These are installed system-wide via Nix package manager
          # ====================================================================
          environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
            
            # -- Core Utilities --
            git                    # Version control
            curl                   # HTTP client
            wget                   # File downloader
            openssh                # SSH client/server
            openssl                # Cryptography toolkit
            
            # -- Build Tools --
            cmake                  # Cross-platform build system
            gcc                    # GNU Compiler Collection
            gnumake                # GNU Make build tool
            pkg-config             # Compiler/linker flags helper
            
            # -- Programming Languages & Runtimes --
            nodejs_23              # Node.js JavaScript runtime
            bun                    # Fast JavaScript runtime/bundler
            jdk                    # Java Development Kit
            maven                  # Java build tool
            rustup                 # Rust toolchain installer
            python3                # Python interpreter
            
            # -- Databases --
            postgresql_17          # PostgreSQL database server
            sqlite                 # Embedded SQL database
            
            # -- Graphics & Multimedia Libraries --
            assimp                 # 3D model import library
            glew                   # OpenGL extension wrangler
            glfw                   # OpenGL window/input library
            freetype               # Font rendering library
            ffmpeg                 # Multimedia framework
            
            # -- Developer Utilities --
            lazygit                # Terminal UI for git
            direnv                 # Directory-based env management
            btop                   # Resource monitor
            fzf                    # Fuzzy finder
            ripgrep-all            # Search tool (grep alternative)
            hexyl                  # Hex viewer
            tmux                   # Terminal multiplexer
            neovim                 # Text editor
            mitmproxy              # HTTP/HTTPS proxy for debugging
            
            # -- Applications --
            cursor                 # AI-powered code editor
            bitwarden-cli          # Password manager CLI
            mas                    # Mac App Store CLI
            texlive.combined.scheme-medium  # LaTeX distribution
            
            # -- Custom Packages --
            # TODO: Fix ntsc-rs overlay SHA256 hashes before using
            ntsc-rs                # NTSC video effect tool (see overlay above)
            
            # -- External Flake Packages --
            inputs.ghostty.packages.${system}.default  # Ghostty terminal
          ];

          # ====================================================================
          # 8. FONTS
          # ====================================================================
          # [SAFE TO MODIFY] System fonts installed via Nix
          # ====================================================================
          fonts.packages = with nixpkgs.legacyPackages.${system}; [
            nerd-fonts.agave       # Agave Nerd Font (for terminal/editor)
            nerd-fonts.ubuntu-mono # Ubuntu Mono Nerd Font
          ];

          # ====================================================================
          # 9. HOMEBREW - GUI Apps & Casks
          # ====================================================================
          # [SAFE TO MODIFY] Applications installed via Homebrew
          #
          # WHY HOMEBREW FOR THESE?
          # - GUI applications often require macOS-specific installation
          # - Many are proprietary and only distributed via Homebrew casks
          # - Homebrew handles code signing and Gatekeeper properly
          # - Some apps auto-update themselves and conflict with Nix management
          # ====================================================================
          homebrew = {
            enable = true;
            
            # "zap" removes all casks not listed here on activation
            # This keeps your system clean but be careful adding casks!
            onActivation.cleanup = "zap";
            
            # Automatically update Homebrew and upgrade packages on activation
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
            
            # Additional Homebrew taps
            taps = [ "homebrew/services" ];
            
            casks = [
              # -- Web Browsers --
              "ungoogled-chromium"   # Privacy-focused Chromium
              "zen-browser"          # Minimalist browser
              
              # -- Code Editors & IDEs --
              "visual-studio-code"   # Microsoft VS Code
              "zed"                  # GPU-accelerated editor
              
              # -- Development Tools --
              "docker"               # Container platform
              "beekeeper-studio"     # SQL database client
              "arduino-ide"          # Arduino development
              "utm"                  # Virtual machine manager
              "jprofiler"            # Java profiler
              
              # -- 3D & Design Tools --
              "blender"              # 3D creation suite
              "inkscape"             # Vector graphics editor
              "autodesk-fusion"      # CAD/CAM software (proprietary)
              "ultimaker-cura"       # 3D printing slicer
              "figma"                # UI/UX design tool (proprietary)
              
              # -- Media Players --
              "vlc"                  # Universal media player
              "mpv"                  # Minimalist media player
              "spotify"              # Music streaming (proprietary)
              
              # -- Creative & Production --
              "reaper"               # Digital audio workstation
              "davinci-resolve"      # Video editing (proprietary)
              
              # -- Productivity & Notes --
              "obsidian"             # Markdown knowledge base
              "calibre"              # E-book manager
              
              # -- System Utilities --
              "raycast"              # Spotlight replacement/launcher
              "aldente"              # Battery management
              "balenaetcher"         # USB/SD card flasher
              "stats"                # System monitor menu bar
              "rectangle"            # Window management
              "ice"                  # Menu bar manager
              "keka"                 # File archiver
              "pdfsam-basic"         # PDF split/merge tool
              
              # -- Communication --
              "bitwarden"            # Password manager GUI
              "slack"                # Team communication
              
              # -- Entertainment --
              "steam"                # Gaming platform (proprietary)
            ];
          };

          # ====================================================================
          # 10. ACTIVATION SCRIPTS
          # ====================================================================
          # [MODIFY WITH CAUTION] Scripts run during system activation
          # These run every time you execute darwin-rebuild switch
          # ====================================================================
          system.activationScripts.postActivation.text = ''
            # Clone CameraController if not already present
            # This is a macOS camera control utility that must be built from source
            echo "Checking CameraController..."
            SRC_DIR="${homeDirectory}/Developer/CameraController"
            if [ ! -d "$SRC_DIR" ]; then
              mkdir -p "${homeDirectory}/Developer"
              ${nixpkgs.legacyPackages.${system}.git}/bin/git clone https://github.com/Itaybre/CameraController.git "$SRC_DIR"
            fi
          '';

          # ====================================================================
          # 11. USER CONFIGURATION
          # ====================================================================
          # [MODIFY WITH CAUTION] User account settings
          # The username must match your actual macOS user account
          # ====================================================================
          users.users.${username} = {
            name = username;
            home = homeDirectory;
          };

          # Enable zsh as the system shell
          programs.zsh.enable = true;

          # ====================================================================
          # 12. HOME MANAGER - Per-User Configuration
          # ====================================================================
          # [SAFE TO MODIFY] User-specific settings managed by home-manager
          # These only affect the specified user, not the whole system
          # ====================================================================
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = { pkgs, ... }: {
            # home-manager state version - update when upgrading home-manager
            home.stateVersion = "24.05";
            
            # ------------------------------------------------------------------
            # GIT CONFIGURATION
            # ------------------------------------------------------------------
            # [SAFE TO MODIFY] Update with your own git credentials
            # ------------------------------------------------------------------
            programs.git = {
              enable = true;
              # TODO: Update with your GitHub username
              userName = "JimmyBlackley";
              # TODO: Update with your email address
              userEmail = "jblackley97@gmail.com";
              extraConfig = {
                # Default branch name for new repositories
                init.defaultBranch = "main";
                # Use neovim as the default git editor
                core.editor = "nvim";
                # Rebase by default when pulling (keeps history cleaner)
                pull.rebase = true; 
              };
              # Global gitignore patterns
              ignores = [ ".DS_Store" ];
            };

            # ------------------------------------------------------------------
            # ZSH SHELL CONFIGURATION
            # ------------------------------------------------------------------
            # [SAFE TO MODIFY] Shell customization
            # ------------------------------------------------------------------
            programs.zsh = {
              enable = true;
              enableCompletion = true;
              # Enable fish-like autosuggestions
              autosuggestion.enable = true;
              # Enable syntax highlighting in the terminal
              syntaxHighlighting.enable = true;
              oh-my-zsh = {
                enable = true;
                # Oh-My-Zsh plugins to load
                plugins = [ "git" "docker" "fzf" ];
                # Theme: Powerlevel10k (ensure it's installed)
                theme = "powerlevel10k/powerlevel10k";
              };
            };

            # ------------------------------------------------------------------
            # DIRENV CONFIGURATION
            # ------------------------------------------------------------------
            # Enables automatic environment loading when entering directories
            # Works with .envrc files for project-specific environments
            # ------------------------------------------------------------------
            programs.direnv = {
              enable = true;
              enableZshIntegration = true;
              # nix-direnv provides faster and cached nix shell activation
              nix-direnv.enable = true;
            };
          };
        }
      ];
    };
  };
}
