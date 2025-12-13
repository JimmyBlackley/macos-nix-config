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
    # Add custom overlays here if needed
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
    nodejs_22
    bun
    go
    jdk
    maven
    rustup
    python3

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
  # FONTS
  # ============================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.agave
    nerd-fonts.ubuntu-mono
  ];
}

