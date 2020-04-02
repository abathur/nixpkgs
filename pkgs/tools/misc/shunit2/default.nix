{ stdenv, fetchFromGitHub, resholved, coreutils, gnused, gnugrep, findutils }:

resholved.buildResholvedPackage {
  pname = "shunit2";
  version = "2019-08-10";

  src = fetchFromGitHub {
    owner = "kward";
    repo = "shunit2";
    rev = "ba130d69bbff304c0c6a9c5e8ab549ae140d6225";
    sha256 = "1bsn8dhxbjfmh01lq80yhnld3w3fw1flh7nwx12csrp58zsvlmgk";
  };

  scripts = [ "shunit2" ];
  inputs = [ coreutils gnused gnugrep findutils ];

  # patching a hardcoded reference to od to make it relative so resholved can resolve it
  # Resholved blocks most absolute paths, but I guess it could be aware of some fixed
  # path prefixes (i.e., notice common binary locations and search for a match in inputs
  # ) but almost anything it did with that would be a little magical/surprising.
  #
  # I suspect it should either be patched like this, or there could be a new resholver
  # argument that explicitly tells the resholver to re-resolve the basename of an exact
  # absolute path match?
  patchPhase = ''
    substituteInPlace shunit2 --replace "/usr/bin/od" "od"
  '';
  allow = {
    eval = [ "shunit_condition_" "_shunit_test_" ];
    # dynamically defined in shunit2:_shunit_mktempFunc
    function = [
      "oneTimeSetUp"
      "oneTimeTearDown"
      "setUp"
      "tearDown"
      "suite"
      "noexec"
    ];
    builtin = [ "setopt" ]; # zsh has it, not sure
  };

  installPhase = ''
    mkdir -p $out/bin/
    cp ./shunit2 $out/bin/shunit2
    chmod +x $out/bin/shunit2
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/shunit2
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/kward/shunit2;
    description = "A xUnit based unit test framework for Bourne based shell scripts.";
    maintainers = with maintainers; [ cdepillabout utdemir ];
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
