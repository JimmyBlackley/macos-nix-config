{
  description = "James' MacOS System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ghostty, ... }:
  let
    hostname = "macbook-pro";
    username = "james";
    system = "aarch64-darwin";
  in
  {
    darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        home-manager.darwinModules.home-manager
        {
          nix.settings.experimental-features = "nix-command flakes";
          system.stateVersion = 5;
          security.pam.enableSudoTouchIdAuth = true;

          # ====================================================
          # SYSTEM DEFAULTS (The "James" Config)
          # ====================================================
          system.defaults = {
            # --- DOCK ---
            dock = {
              autohide = true;
              show-recents = false; # Disable "Recent Apps" section
              mru-spaces = false;   # Don't rearrange spaces
              tilesize = 48;        # Slightly smaller dock icons
              
              # Hot Corners (1 = Disabled)
              wvous-tl-corner = 1;
              wvous-tr-corner = 1;
              wvous-bl-corner = 1;
              wvous-br-corner = 1;
              
              # The Apps you want pinned
              # Note: This only runs once. If apps aren't installed yet, it might skip them.
              persistent-apps = [
                "/Applications/Zen Browser.app"
                "/Applications/Obsidian.app"
                "/Applications/Ghostty.app"
              ];
            };

            # --- FINDER ---
            finder = {
              AppleShowAllExtensions = true;
              ShowPathbar = true;
              FXPreferredViewStyle = "clmv"; # Column View (best for devs)
              _FXShowPosixPathInTitle = true; # Show full path in window title
              
              # Search Scope: "SCcf" = Search Current Folder
              FXDefaultSearchScope = "SCcf";
              
              # Default new window target: Home Directory ("PfHm")
              NewWindowTarget = "PfHm"; 
            };

            # --- TRACKPAD & MOUSE ---
            trackpad = {
              Clicking = true;  # Tap to click
              TrackpadThreeFingerDrag = false; # Disable 3-finger drag if you don't like it
            };
            
            # --- GLOBAL SETTINGS ---
            NSGlobalDomain = {
              AppleShowAllExtensions = true;
              KeyRepeat = 2;
              InitialKeyRepeat = 15;
              "com.apple.mouse.tapBehavior" = 1;
              
              # Disable "Look up & data detectors" (The 3-finger tap dictionary)
              "com.apple.trackpad.forceClick" = false;
            };
          };

          # ====================================================
          # PACKAGES
          # ====================================================
          nixpkgs.overlays = [
            (final: prev: {
              ntsc-rs = final.rustPlatform.buildRustPackage rec {
                pname = "ntsc-rs";
                version = "git-latest";
                src = final.fetchFromGitHub {
                  owner = "valerio-forty";
                  repo = "ntsc-rs";
                  rev = "main";
                  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
                };
                cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
                doCheck = false;
              };
            })
          ];

          environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
            git
            curl
            wget
            openssh
            openssl
            cmake
            gcc
            gnumake
            pkg-config
            nodejs_23
            bun
            postgresql_17
            sqlite
            maven
            jdk
            rustup
            python3
            assimp
            glew
            glfw
            freetype
            ffmpeg
            lazygit
            direnv
            bitwarden-cli
            btop
            fzf
            ripgrep-all
            hexyl
            tmux
            neovim
            cursor
            mitmproxy
            texlive.combined.scheme-medium
            mas
            ntsc-rs
            inputs.ghostty.packages.${system}.default
          ];

          fonts.packages = with nixpkgs.legacyPackages.${system}; [
            nerd-fonts.agave
            nerd-fonts.ubuntu-mono
          ];

          homebrew = {
            enable = true;
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
            taps = [ "homebrew/services" ];
            
            casks = [
              "ungoogled-chromium"
              "zen-browser"
              "visual-studio-code"
              "zed" 
              "docker"
              "beekeeper-studio"
              "arduino-ide"
              "utm"
              "blender"
              "inkscape"
              "autodesk-fusion"
              "ultimaker-cura"
              "figma" 
              "vlc"
              "mpv"
              "spotify"
              "reaper"
              "obsidian"
              "calibre"
              "davinci-resolve"
              "raycast"
              "aldente"
              "balenaetcher"
              "stats"
              "rectangle"
              "ice"
              "keka"
              "pdfsam-basic"
              "bitwarden"
              "slack"
              "steam"
              "jprofiler"
            ];
          };

          system.activationScripts.postActivation.text = ''
            echo "Checking CameraController..."
            SRC_DIR="/Users/${username}/Developer/CameraController"
            if [ ! -d "$SRC_DIR" ]; then
              mkdir -p "/Users/${username}/Developer"
              ${nixpkgs.legacyPackages.${system}.git}/bin/git clone https://github.com/Itaybre/CameraController.git "$SRC_DIR"
            fi
          '';

          users.users.${username} = {
            name = username;
            home = "/Users/${username}";
          };

          programs.zsh.enable = true;

          # ====================================================
          # USER CONFIG (Home Manager)
          # ====================================================
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = { pkgs, ... }: {
            home.stateVersion = "24.05";
            
            # --- GIT CONFIG ---
            programs.git = {
              enable = true;
              userName = "JimmyBlackley";
              userEmail = "jblackley97@gmail.com";
              extraConfig = {
                init.defaultBranch = "main";
                core.editor = "nvim";
                # Helpful for large repos
                pull.rebase = true; 
              };
              ignores = [ ".DS_Store" ];
            };

            # --- ZSH ---
            programs.zsh = {
              enable = true;
              enableCompletion = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;
              oh-my-zsh = {
                enable = true;
                plugins = [ "git" "docker" "fzf" ];
                theme = "powerlevel10k/powerlevel10k";
              };
            };

            programs.direnv = {
              enable = true;
              enableZshIntegration = true;
              nix-direnv.enable = true;
            };
          };
        }
      ];
    };
  };
}
