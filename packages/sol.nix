{ lib, stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "sol";
  version = "2.1.288";

  src = fetchurl {
    url = "https://github.com/ospfranco/sol/releases/download/${version}/${version}.zip";
    sha256 = "1dy17i3dhgp9wxdhdmh0fm8gvj25rl8a1q4dz5jwbsabfikajx3p";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/Applications
    cp -r Sol.app $out/Applications/
  '';

  meta = with lib; {
    description = "A macOS launcher with focus on speed and simplicity";
    homepage = "https://github.com/ospfranco/sol";
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}

