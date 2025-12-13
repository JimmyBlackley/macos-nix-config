# ==============================================================================
# MACOS SYSTEM CONFIGURATION
# ==============================================================================
# A modular nix-darwin + home-manager configuration for macOS
#
# FIRST TIME SETUP:
#   1. Update the "User Configuration" section below with your details
#   2. Run: nix run nix-darwin -- switch --flake .
#   3. Run: ./scripts/post-install.sh
#
# FILE STRUCTURE:
#   flake.nix           - This file (inputs + module imports)
#   modules/
#     ├── system.nix    - macOS system preferences, keyboard, security
#     ├── packages.nix  - Nix packages, overlays, fonts
#     ├── homebrew.nix  - Homebrew casks and brews
#     ├── services.nix  - System services and launchd agents
#     └── home.nix      - Home-manager user configuration
#   packages/
#     ├── ntsc-rs.nix   - NTSC video effects
#     └── sol.nix       - Sol launcher
# ==============================================================================

{
  description = "Declarative macOS configuration with nix-darwin";

  # ============================================================================
  # INPUTS - Flake Dependencies
  # ============================================================================
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  # ============================================================================
  # OUTPUTS
  # ============================================================================
  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, zen-browser, ... }:
  let
    # ==========================================================================
    # USER CONFIGURATION - Update these values for your system
    # ==========================================================================
    
    # Your Mac's hostname (System Settings → General → About → Name)
    # This is used as the configuration name for nix-darwin
    hostname = "Jamess-MacBook-Pro";
    
    # Your macOS username (the name of your home folder)
    username = "james";
    
    # Your git identity (for commits)
    gitName = "James Blackley";
    gitEmail = "jblackley97@gmail.com";
    
    # System architecture: "aarch64-darwin" for Apple Silicon, "x86_64-darwin" for Intel
    system = "aarch64-darwin";
    
    # ==========================================================================
    # END USER CONFIGURATION
    # ==========================================================================
    
    homeDirectory = "/Users/${username}";

    # Pass configuration to all modules
    specialArgs = {
      inherit inputs system username homeDirectory gitName gitEmail hostname;
    };
  in
  {
    darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        home-manager.darwinModules.home-manager
        ./modules/system.nix
        ./modules/packages.nix
        ./modules/homebrew.nix
        ./modules/services.nix
        ./modules/home.nix
      ];
    };
  };
}
