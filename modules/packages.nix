# ==============================================================================
# PACKAGES CONFIGURATION
# ==============================================================================
# System packages, overlays, and fonts installed via Nix
# ==============================================================================

{ config, lib, pkgs, inputs, system, ... }:

let
  # Import custom packages
  ntsc-rs = pkgs.callPackage ../packages/ntsc-rs.nix { };
  sol = pkgs.callPackage ../packages/sol.nix { };
in
{
  # ============================================================================
  # PACKAGE OVERLAYS
  # ============================================================================
  nixpkgs.overlays = [
    # Override nodejs_25 to skip tests (fixes build timeout issues when building from source)
    (final: prev: {
      nodejs_25 = prev.nodejs_25.overrideAttrs (oldAttrs: {
        doCheck = false;
        checkPhase = "";
      });
    })
  ];

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # -- Core Utilities --
    git
    curl
    wget
    openssh
    openssl

    # -- Build Tools --
    cmake
    gcc
    gnumake
    pkg-config

    # -- Programming Languages & Runtimes --
    nodejs_25
    bun
    go
    jdk8
    jdk25
    maven
    rustup
    python3
    zig
    odin

    # -- Databases --
    postgresql_17
    sqlite

    # -- Graphics & Multimedia Libraries --
    assimp
    glew
    glfw
    freetype
    ffmpeg

    # -- Developer Utilities --
    lazygit
    direnv
    btop
    fzf
    ripgrep-all
    hexyl
    tmux
    neovim
    mitmproxy

    # -- Applications --
    bitwarden-cli
    gh  # GitHub CLI
    mas
    texlive.combined.scheme-medium

    # -- Custom Packages --
    ntsc-rs
    sol  # macOS launcher (native Swift)

    # -- External Flake Packages --
    inputs.zen-browser.packages.${system}.default
  ];

  # ============================================================================
  # JAVA CONFIGURATION
  # ============================================================================
  # Set Java 25 as the default and configure JAVA_HOME
  environment.variables = {
    JAVA_HOME = "${pkgs.jdk25}";
  };

  # Ensure Java 25 is in PATH before Java 8
  environment.shellInit = ''
    export JAVA_HOME="${pkgs.jdk25}"
    export PATH="$JAVA_HOME/bin:$PATH"
  '';

  # ============================================================================
  # FONTS
  # ============================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.agave
    nerd-fonts.ubuntu-mono
  ];
}

