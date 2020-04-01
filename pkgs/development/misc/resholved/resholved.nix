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
    rev = "453f4db2452356aa2d49a9e90e46a034861fcd0d";
    sha256 = "16d4805cpbv6nq8k67c0m1kiqhcgcgahdf8k9lg7n0nn2k3ymmrh";
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
