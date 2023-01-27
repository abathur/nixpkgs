{ stdenv, lib, fetchurl, symlinkJoin, withReadline ? true, readline }:

let
  readline-all = symlinkJoin {
    name = "readline-all"; paths = [ readline readline.dev ];
  };
in
stdenv.mkDerivation rec {
  pname = "oil";
  version = "0.14.0";

  src = fetchurl {
    url = "https://www.oilshell.org/download/oils-for-unix-${version}.tar.xz";
    hash = "sha256-whDePPsRsWasKotbmC6XViz4t2VNRwM8vNUbjTkvogc=";
  };

  postPatch = ''
    patchShebangs build _build
    # TODO: workaround for https://github.com/oilshell/oil/issues/1467
    #       check for removability on updates :)
    substituteInPlace configure --replace "echo '#define HAVE_READLINE 1'" "echo '#define HAVE_READLINE 1' && return 0"
  '';

  buildPhase = ''
    runHook preBuild

    _build/oils.sh "" "" SKIP_REBUILD

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ./install

    runHook postInstall
  '';

  strictDeps = true;
  buildInputs = lib.optional withReadline readline;
  configureFlags = [
    "--datarootdir=${placeholder "out"}"
  ] ++ lib.optionals withReadline [
    "--with-readline"
    "--readline=${readline-all}"
  ];

  # Stripping breaks the bundles by removing the zip file from the end.
  dontStrip = true;

  meta = {
    description = "A new unix shell";
    homepage = "https://www.oilshell.org/";

    license = with lib.licenses; [
      psfl # Includes a portion of the python interpreter and standard library
      asl20 # Licence for Oil itself
    ];

    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ lheckemann alva ];
    changelog = "https://www.oilshell.org/release/${version}/changelog.html";
  };

  passthru = {
    shellPath = "/bin/osh";
  };
}
