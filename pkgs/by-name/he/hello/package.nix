{ callPackage
, lib
, stdenv
, fetchurl
, nixos
, testers
, hello
, binlore
, makeWrapper
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "2.12.1";

  src = fetchurl {
    url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
  };

  doCheck = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    makeWrapper $out/bin/hello $out/bin/jello --set FOOBAR baz
    mkdir -p $out/nix-support
    echo "fakelore:bin/hello" > $out/nix-support/execers
  '';

  passthru.tests = {
    version = testers.testVersion { package = hello; };

    invariant-under-noXlibs =
      testers.testEqualDerivation
        "hello must not be rebuilt when environment.noXlibs is set."
        hello
        (nixos { environment.noXlibs = true; }).pkgs.hello;
  };

  passthru.tests.run = callPackage ./test.nix { hello = finalAttrs.finalPackage; };

  # passthru.lore = (binlore.synthesize finalAttrs.finalPackage {
  #   execer = [
  #     "can:bin/*"
  #     "cannot:bin/jello"
  #   ];
  #   wrapper = [
  #     "bin/hello:bin/jello"
  #   ];
  # });
  passthru.lore = (binlore.synthesize finalAttrs.finalPackage ''
    execer can bin/*
    execer can bin/hello
    wrapper bin/hello bin/jello
  '');
  passthru.hehe = (binlore.collect { drvs = [ finalAttrs.finalPackage ]; });

  meta = with lib; {
    description = "A program that produces a familiar, friendly greeting";
    longDescription = ''
      GNU Hello is a program that prints "Hello, world!" when you run it.
      It is fully customizable.
    '';
    homepage = "https://www.gnu.org/software/hello/manual/";
    changelog = "https://git.savannah.gnu.org/cgit/hello.git/plain/NEWS?h=v${finalAttrs.version}";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.eelco ];
    mainProgram = "hello";
    platforms = platforms.all;
  };
})
