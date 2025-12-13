# ==============================================================================
# NTSC-RS PACKAGE
# ==============================================================================
# NTSC video effect emulator - fetched from GitHub releases
# https://github.com/valadaptive/ntsc-rs
# ==============================================================================

{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "ntsc-rs";
  version = "0.9.3";

  src = fetchurl {
    url = "https://github.com/valadaptive/ntsc-rs/releases/download/v${version}/ntsc-rs-macos-standalone.pkg";
    sha256 = "1mnx87gcqjjkdbdc9lsahys0xdmzqg6zmb39pngbhd8vmrf4dv7d";
  };

  # Don't try to unpack automatically
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    # Use pkgutil to expand the pkg (handles pbzx compression natively)
    # The --expand-full option extracts Payload contents directly
    /usr/sbin/pkgutil --expand-full $src $TMPDIR/ntsc-pkg

    # Create output directory
    mkdir -p $out/Applications

    # Copy the app from the expanded Payload
    if [ -d "$TMPDIR/ntsc-pkg/Payload/ntsc-rs.app" ]; then
      cp -r $TMPDIR/ntsc-pkg/Payload/ntsc-rs.app $out/Applications/
    else
      # Fallback: find any .app in the payload
      find $TMPDIR/ntsc-pkg -name "*.app" -type d -exec cp -r {} $out/Applications/ \;
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free, open-source analog TV + VHS effect";
    homepage = "https://github.com/valadaptive/ntsc-rs";
    license = licenses.gpl3;
    platforms = platforms.darwin;
    maintainers = [];
  };
}
