{ stdenv
, lib
, fetchFromGitHub
, fetchurl
, perl
, perlPackages
, writeScript
, callPackage
, sharness
}:

stdenv.mkDerivation rec {
  pname = "sharness";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "chriscool";
    repo = pname;
    rev = "3f238a740156dd2082f4bd60ced205e05894d367"; # 2020-12-09
    sha256 = "FCYskpIqkrpNaWCi2LkhEkiow4/rXLe+lfEWNUthLUg=";
  };

  # Used for testing
  nativeBuildInputs = [ perl perlPackages.IOTty ];

  outputs = [ "out" "doc" ];

  makeFlags = [ "prefix=$(out)" ];

  doCheck = true;

  passthru = {
    tests = callPackage ./test.nix { };
    withPlugins =
      sharnessExtensions:
        /*
        temporarily set SHARNESS_TEST_SRCDIR because I think this might make
        it possible for "users" to set this to a location in their code and
        used unpackaged extensions? But I don't really know.
        */
        writeScript "sharness-with-plugins" ''
          # source the core; srcdir only for load
          export SHARNESS_TEST_SRCDIR="${sharness}/share/sharness"
          source ${sharness}/share/sharness/sharness.sh
          unset SHARNESS_TEST_SRCDIR

          # source the plugins
          ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "source ${v}") sharnessExtensions)}
        '';
  };

  meta = with lib; {
    description = "Portable shell library to write, run and analyze automated tests adhering to Test Anything Protocol (TAP)";
    homepage = "https://github.com/chriscool/sharness";
    license = licenses.gpl2Only;
    maintainers = [ maintainers.spacefrogg ];
    platforms = platforms.unix;
  };
}
