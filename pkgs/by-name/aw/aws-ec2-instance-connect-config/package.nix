{ stdenv
, lib
, fetchFromGitHub
, resholve
, coreutils
, curl
, openssh
, cacert
, gnugrep
, util-linux
, openssl
, gawk
, gnused
, bash
, findutils
}:
# TODO: This currently fails with exit code 1 and no helpful error message.
let
  src = fetchFromGitHub {
    # https://github.com/aws/aws-ec2-instance-connect-config
    owner = "aws";
    repo = "aws-ec2-instance-connect-config";
    rev = "1.1.17";
    hash = "sha256-XXrVcmgsYFOj/1cD45ulFry5gY7XOkyhmDV7yXvgNhI=";
  };
in
resholve.mkDerivation {
  pname = "aws-ec2-instance-connect-config";
  version = "unstable";
  inherit src;
  solutions.default = {
    interpreter = "${bash}/bin/bash";
    scripts = [ "bin/*" ];
    inputs = [
      coreutils
      curl
      openssh
      cacert
      gnugrep
      util-linux
      openssl
      gawk
      gnused
      findutils
    ];
    fix = {
      "/usr/bin/timeout" = true;
      "$DIR" = [ "${placeholder "out"}/bin" ];
      "$OPENSSL" = [ "openssl" ];
      "/usr/bin/curl" = true;
      "/usr/bin/logger" = true;
      "/bin/echo" = true;
      "/usr/bin/head" = true;
      "/bin/grep" = true;
      "/bin/cat" = true;
      "/usr/bin/cut" = true;
      "/usr/bin/id" = true;
      "/bin/sed" = true;
      "/usr/bin/printf" = true;
      "/bin/mktemp" = true;
      "/usr/bin/base64" = true;
      "/bin/chmod" = true;
      "/usr/bin/sha256sum" = true;
      "/usr/bin/openssl" = true;
      "/usr/bin/od" = true;
      "/usr/bin/test" = true;
      "/usr/bin/awk" = true;
      "/bin/date" = true;
      "/usr/bin/find" = true;
      "/usr/bin/seq" = true;
      "/usr/bin/tr" = true;
      "/bin/cp" = true;
      "/bin/rm" = true;
      "/usr/bin/cp" = true;
      "/bin/mv" = true;
      "/bin/touch" = true;
      "/usr/bin/ssh-keygen" = true;
    };
    # TODO: smells like there's some kind of bug here WRT to a few of the below; I think
    # resholve may be failing to look up the parser correctly for at least sed/awk/find
    execer = [
      "cannot:${coreutils}/bin/timeout"
      "cannot:${gnused}/bin/sed"
      "cannot:${gawk}/bin/awk"
      "cannot:${findutils}/bin/find"
      "cannot:${openssh}/bin/ssh-keygen"
    ];
    keep = {
      "${placeholder "out"}/bin/eic_curl_authorized_keys" = true;
      "${placeholder "out"}/bin/eic_parse_authorized_keys" = true;
    };
  };
  installPhase = ''
    mkdir -p $out/bin
    find .
    cp src/bin/* $out/bin/
  '';
}
