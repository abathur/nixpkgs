{ lib
, resholvePackage
, fetchFromGitHub
, makeWrapper
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

resholvePackage rec {
  pname = "kodi-cli";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "nawar";
    repo = pname;
    rev = version;
    sha256 = "0f9wdq2fg8hlpk3qbjfkb3imprxkvdrhxfkcvr3dwfma0j2yfwam";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a kodi-cli $out/bin
    cp -a playlist_to_kodi $out/bin
  '';

  # wrapProgram $out/bin/playlist_to_kodi --prefix PATH : ${lib.makeBinPath [ curl bash  jq youtube-dl ]}
  solutions = {
    # cli = {
    #   scripts = [ "bin/kodi-cli" ];
    #   interpreter = "${bash}/bin/bash";
    #   inputs = [
    #     curl
    #     gawk
    #     coreutils
    #     mps-youtube
    #     gnugrep
    #   ];
    #   execer = [
    #     /* TODO: I haven't really validated this yet; just seeing how far we get */
    #     "cannot:${mps-youtube}/bin/mpsyt"
    #   ];
    # };
    # playlists = {
    #   scripts = [ "bin/playlist_to_kodi" ];
    #   interpreter = "${bash}/bin/bash";
    #   inputs = [
    #     coreutils
    #     gnome.zenity
    #     youtube-dl # staying faithful to existing package, but it seems like everyone's moved on
    #     jq
    #     gawk
    #   ];
    #   execer = [
    #     /* TODO: I haven't really validated this yet; just seeing how far we get */
    #     "cannot:${youtube-dl}/bin/youtube-dl"
    #   ];
    # };
    combined = {
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
      ];
      execer = [
        /* TODO: I haven't really validated these yet; just seeing how far we get */
        "cannot:${youtube-dl}/bin/youtube-dl"
        "cannot:${mps-youtube}/bin/mpsyt"
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
