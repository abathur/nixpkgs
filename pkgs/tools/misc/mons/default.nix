{ resholve
, lib
, fetchFromGitHub
, fetchpatch
, help2man
, bash
, coreutils
, gnused
, xrandr
, gnugrep
, gawk
}:

resholve.mkDerivation rec {
  pname = "mons";
  version = "20200320";

  src = fetchFromGitHub {
    owner = "Ventto";
    repo = pname;
    rev = "375bbba3aa700c8b3b33645a7fb70605c8b0ff0c";
    sha256 = "19r5y721yrxhd9jp99s29jjvm0p87vl6xfjlcj38bljq903f21cl";
    fetchSubmodules = true;
  };

  /*
    Patching out this check; it's bad on multiple levels:
    1. The check literally breaks if it fails.
       See https://github.com/Ventto/mons/pull/49
    2. It doesn't need to do this; source would fail with a
       sensible message if the script was missing.
    3. resholve can't wrestle with test/[] (at least until
       https://github.com/abathur/resholve/issues/78)
  */
  postPatch = ''
    substituteInPlace mons.sh --replace '[ ! -r "$lib" ] && { "$lib: library not found."; exit 1; }' ""
  '';

  nativeBuildInputs = [ help2man ];
  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  solutions = {
    mons = {
      scripts = [ "bin/mons" "lib/libshlist/liblist.sh" ];
      interpreter = "${bash}/bin/sh";
      inputs = [
        coreutils
        gnused
        xrandr
        gnugrep
        gawk
        bash
      ];
      fix = {
        "$lib" = [ "lib/libshlist/liblist.sh" ];
        "$XRANDR" = [ "xrandr" ];
      };
      keep = {
        /*
        has a whole slate of *flag variables that it sets to either
        the true or false builtin and then executes...
        */
        "$aFlag" = true;
        "$dFlag" = true;
        "$eFlag" = true;
        "$mFlag" = true;
        "$nFlag" = true;
        "$oFlag" = true;
        "$sFlag" = true;
        "$OFlag" = true;
        "$SFlag" = true;
        "$pFlag" = true;
        "$iFlag" = true;
        "$xFlag" = true;
        "$is_flag" = true;
      };
    };
  };

  meta = with lib; {
    description = "POSIX Shell script to quickly manage 2-monitors display";
    homepage = "https://github.com/Ventto/mons.git";
    license = licenses.mit;
    maintainers = with maintainers; [ mschneider thiagokokada ];
  };
}
