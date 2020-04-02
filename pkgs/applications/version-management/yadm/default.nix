{ stdenv, fetchFromGitHub, resholved, coreutils, bash, hostname, git, gnupg, gnutar }:

let version = "2.4.0"; in
resholved.buildResholvedPackage {
  pname = "yadm";
  inherit version;

  # I patched a (valid) syntax in yadm that is tripping the oil parser up
  # so that I can try to just upstream that fix soon.
  src = fetchFromGitHub {
    owner  = "abathur";
    repo   = "yadm";
    rev    = "0f19917be4b4c62367e4b719959aa90590efea09";
    sha256 = "11b6dw6fpjgmpz86yi0vasbbkiak5k2mlmn8jmwzx8vm9997vacs";
  };

  scripts = [ "yadm" ];
  inputs = [ coreutils bash hostname git gnupg gnutar ];
  allow = {
    unresholved_inputs = [
      # resholved doesn't really understand parameters at the moment
      # it's assuming parameter 2 to "command" is always <commandname>
      # I haven't quite decided how to handle this; but for demo
      # I'm just exempting the flag
      "-v"

      # This is some windows/cygwin thing. I didn't really anticipate this.
      # It doesn't look like it's available in Nix, so I added the concept of
      # "unresholved_inputs" for allowing some unresolved command-names.
      "cygpath"
    ];
    exec = [ "YADM_BOOTSTRAP" ];
  };

  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    install -Dt $out/bin yadm
    install -Dt $out/share/man/man1 yadm.1
    install -D completion/yadm.zsh_completion $out/share/zsh/site-functions/_yadm
    install -D completion/yadm.bash_completion $out/share/bash-completion/completions/yadm.bash
    runHook postInstall
  '';


  meta = {
    homepage = https://github.com/TheLocehiliosan/yadm;
    description = "Yet Another Dotfiles Manager";
    longDescription = ''
      yadm is a dotfile management tool with 3 main features:
      * Manages files across systems using a single Git repository.
      * Provides a way to use alternate files on a specific OS or host.
      * Supplies a method of encrypting confidential data so it can safely be stored in your repository.
    '';
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.unix;
  };
}
