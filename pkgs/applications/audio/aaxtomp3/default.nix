{ bash
, bc
, coreutils
, fetchFromGitHub
, ffmpeg
, findutils
, gawk
, gnugrep
, gnused
, jq
, lame
, lib
, mediainfo
, mp4v2
, ncurses
, resholve
}:

resholve.mkDerivation rec {
  pname = "aaxtomp3";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "krumpetpirate";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-7a9ZVvobWH/gPxa3cFiPL+vlu8h1Dxtcq0trm3HzlQg=";
  };

  # use whitespace to show osh arithmetic is not file redirection
  patches = [./osh.patch];

  installPhase = ''
    install -Dm 755 AAXtoMP3 $out/bin/aaxtomp3
    install -Dm 755 interactiveAAXtoMP3 $out/bin/interactiveaaxtomp3
  '';

  solutions.default = {
    scripts = [
      "bin/aaxtomp3"
      "bin/interactiveaaxtomp3"
    ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      bc
      coreutils
      ffmpeg
      findutils
      gawk
      gnugrep
      gnused
      jq
      lame
      mediainfo
      mp4v2
      ncurses
    ];
    fix = {
      "$FIND" = [ "find" ];
      "$GREP" = [ "grep" ];
      "$SED" = [ "sed" ];
      "$call" = [ "${placeholder "out"}/bin/aaxtomp3" ];
    };
    keep = {
      "${placeholder "out"}/bin/aaxtomp3" = true;
    };
  };

  meta = with lib; {
    description = "Convert Audible's .aax filetype to MP3, FLAC, M4A, or OPUS";
    homepage = "https://krumpetpirate.github.io/AAXtoMP3";
    license = licenses.wtfpl;
    maintainers = with maintainers; [ urandom ];
  };
}
