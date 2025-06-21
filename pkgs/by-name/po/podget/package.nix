{
  lib,
  fetchFromGitHub,
  resholve,
  coreutils,
  findutils,
  gawk,
  iconv,
  wget,
  runtimeShell,
}:

resholve.mkDerivation {
  pname = "podget";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "dvehrs";
    repo = "podget";
    rev = "18892c6e3d8654fc3332256a564b6dc800e6506c";
    hash = "sha256-0I42UPWTdSzfRJodB1v3BNI5vwt8GRGpHR7eACoR9YQ=";
  };

  patches = [ ./extract_regexes_with_spaces.patch ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -m755 -D podget $out/bin/podget

    runHook postInstall
  '';

  solutions.default = {
    scripts = [ "bin/podget" ];
    interpreter = runtimeShell;
    inputs = [
      coreutils
      findutils
      gawk
      iconv
      wget
    ];
  };

  meta = with lib; {
    description = "Podcast aggregator optimized for running as a scheduled job (i.e. cron) on Linux";
    homepage = "https://github.com/dvehrs/podget";
    changelog = "https://github.com/dvehrs/podget/blob/dev/Changelog";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ _9R ];
    mainProgram = "podget";
  };
}
