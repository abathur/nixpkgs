{ lib
, resholve
, fetchFromGitHub
, bash
, curl
, gawk
, coreutils
, mps-youtube
, gnugrep
, gnome
, youtube-dl
, jq
}:

resholve.mkDerivation rec {
  pname = "kodi-cli";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "nawar";
    repo = pname;
    rev = version;
    sha256 = "0f9wdq2fg8hlpk3qbjfkb3imprxkvdrhxfkcvr3dwfma0j2yfwam";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -a kodi-cli $out/bin
    cp -a playlist_to_kodi $out/bin
  '';

  solutions = {
    default = {
      scripts = [ "bin/kodi-cli" "bin/playlist_to_kodi" ];
      interpreter = "${bash}/bin/bash";
      inputs = [
        curl
        gawk
        coreutils
        mps-youtube
        gnugrep
        gnome.zenity
        youtube-dl # staying faithful to existing package, but it seems like everyone's moved on
        jq
        "bin" # our own internal executables
      ];
      execer = [
        /*
        youtube-dl has args that may exec, but playlist_to_kodi
        doesn't use them. Need to override lore (until/unless
        resholve handles it: TODO issue link)
        */
        "cannot:${youtube-dl}/bin/youtube-dl"
        /*
        mpsyt has at least two subcommands for supplying
        a downloader and player executable, but I don't see either
        in use here.
        */
        "cannot:${mps-youtube}/bin/mpsyt"
        "cannot:bin/kodi-cli" # don't see any obvious root arg exec
      ];
    };
  };

  meta = with lib; {
    homepage = "https://github.com/nawar/kodi-cli";
    description = "Kodi/XBMC bash script to send Kodi commands using JSON RPC. It also allows sending YouTube videos to Kodi";
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = [ maintainers.pstn ];
 };
}
