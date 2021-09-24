{ stdenv
, lib
, resholvePackage
, fetchFromGitHub
, bash
, curl
, openssl_1_1
, socat
, iproute2
, unixtools
, dnsutils
, coreutils
, gnugrep
, gnused
, apacheHttpd
}:
resholvePackage rec {
  pname = "acme.sh";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "Neilpang";
    repo = "acme.sh";
    rev = version;
    sha256 = "sha256-BSKqfj8idpE4OV8/EJkCFo5i1vq/aEde/moqJcwuDvk=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out $out/bin $out/libexec
    cp -R $src/* $_
    cp $out/libexec/acme.sh $out/bin/acme.sh

    runHook postInstall
  '';
  solutions = {
    acme = {
      interpreter = "${bash}/bin/sh";
      scripts = [ "bin/acme.sh" ];
      inputs = [
        coreutils
        gnugrep
        gnused
        socat
        openssl_1_1
        curl
        dnsutils
        (if stdenv.isLinux then iproute2 else unixtools.netstat)
        apacheHttpd
      ];
      fix = {
        "$ACME_OPENSSL_BIN" = [ "openssl" ];
        "$_APACHECTL" = [ "apachectl" ];
      };
      keep = {
        # TODO: unsure about this; it's trying to detect
        # the use of this flag; I think at least darwin
        # will have to fall back on system logger.
        # darwin does support -i, but IDK who doesn't...
        "$__logger_i" = true;
      };
    };
  };

  meta = with lib; {
    description = "A pure Unix shell script implementing ACME client protocol";
    homepage = "https://acme.sh/";
    license = licenses.gpl3;
    maintainers = teams.serokell.members;
  };
}
