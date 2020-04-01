{ stdenv, resholved, fetchFromGitHub, bash, shellcheck, doCheck ? true}:

let
  common = { variant, version, branch, rev, sha256, allow }: resholved.buildResholvedPackage rec {
    # bashup.events doesn't version yet but it has two variants with differing
    # features/performance characteristics:
    # - branch master: a variant for bash 3.2+
    # - branch bash44: a variant for bash 4.4+
    pname = "bashup-events${variant}-unstable";
    inherit version; # should be YYYY-MM-DD

    src = fetchFromGitHub {
      owner = "bashup";
      repo = "events";
      inherit rev sha256;
    };

    scripts = [ "bashup.events" ];
    inherit allow;

    installPhase = ''
      mkdir -p $out/bin
      install ./bashup.events $out/bin/
    '';

    inherit doCheck;
    checkInputs = [ shellcheck bash ];

    # check based on https://github.com/bashup/events/blob/master/.dkrc
    checkPhase = ''
      set -x
      SHELLCHECK_OPTS='-e SC2016,SC2145' shellcheck ./bashup.events
      bash --debug ./bashup.events
      bash ./bashup.events
      set +x
    '';

    meta = with stdenv.lib; {
      inherit branch;
      description = "An event listener/callback API for creating extensible bash programs";
      homepage = https://github.com/bashup/events;
      license = licenses.cc0;
      maintainers = with maintainers; [ abathur ];
      platforms = platforms.all;
    };
  };

in {
  bashup-events32 = common {
    variant = "3.2";
    version = "2019-07-27";
    branch = "master";
    rev = "83744c21bf720afb8325343674c62ab46a8f3d94";
    sha256 = "1cl1cbvvab27v6vh35zdvjc1kibririvva1i91k91m2kxmvy6l6i";
    allow = {
      eval = [ "e" "f" "q" "r" ];
      # Note: __ev.encode is actually defined, but it happens in
      # a quoted arg to eval, which resholved currently doesn't
      # parse into. See abathur/resholved/issues/2.
      function = [ "__ev.encode" ];
    };
  };
  bashup-events44 = common {
    variant = "4.4";
    version = "2019-07-27";
    branch = "bash44";
    rev = "9b4226b906915de7bf882ff807976551aac12a43";
    sha256 = "1mm5l4jbvvr0sjawfsmaw20lzlnm6r42gzyck3m4k4g4f76hvkw1";
    allow = {
      eval = [ "e" "bashup_ev" "n" ];
    };
  };
}

