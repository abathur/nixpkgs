{ stdenv, callPackage, fetchFromGitHub, file, gettext, python27, bats }:
let
  deps = callPackage ./deps.nix { };
  resolveTimeDeps = [ file gettext ];
in python27.pkgs.buildPythonApplication {
  pname = "resholved";
  version = "unreleased";
  src = fetchFromGitHub {
    owner = "abathur";
    repo = "resholved";
    rev = "9ffb63697502ae3c9f5991f23a38004a7d9d8958";
    sha256 = "1317y56zsiq1s3vvmnpv0kfccd1xnq7zhasrn2kr16jb2x35y479";
  };

  format = "other";

  propagatedBuildInputs = [ deps.oildev ];

  installPhase = ''
    mkdir -p $out/bin
    install resholver $out/bin/
  '';
  doCheck = true;
  checkInputs = [ bats ];
  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";
  checkPhase = ''
    PATH=$out/bin:$PATH
    bats tests
  '';
}
