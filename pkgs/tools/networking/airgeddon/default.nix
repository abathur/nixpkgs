{ lib
, resholve
, fetchFromGitHub
  # Required
, aircrack-ng
, bash
, coreutils-full
, gawk
, gnugrep
, gnused
, iproute2
, iw
, pciutils
, procps
, tmux
  # X11 Front
, xterm
, xorg
  # what the author calls "Internals"
, usbutils
, wget
, ethtool
, util-linux
, ccze
  # Optionals
  # Missing in nixpkgs: beef, hostapd-wpe, asleap
, bettercap
, bully
, crunch
, dhcp
, dnsmasq
, ettercap
, hashcat
, hcxdumptool
, hcxtools
, hostapd
, john
, lighttpd
, mdk4
, nftables
, openssl
, pixiewps
, reaverwps-t6x # Could be the upstream version too
, wireshark-cli
  # Undocumented requirements (there is also ping)
, apparmor-bin-utils
, curl
, glibc
, ncurses
, networkmanager
, systemd
  # Support groups
, supportWpaWps ? true # Most common use-case
, supportHashCracking ? false
, supportEvilTwin ? false
, supportX11 ? false # Allow using xterm instead of tmux, hard to test
}:
let
  deps = [
    aircrack-ng
    bash
    coreutils-full
    curl
    gawk
    glibc
    gnugrep
    gnused
    iproute2
    iw
    networkmanager
    ncurses
    pciutils
    procps
    tmux
    usbutils
    wget
    ethtool
    util-linux
    ccze
    systemd
  ] ++ (lib.optionals supportWpaWps [
    bully
    pixiewps
    reaverwps-t6x
  ]) ++ (lib.optionals supportHashCracking [
    crunch
    hashcat
    hcxdumptool
    hcxtools
    john
    wireshark-cli
  ]) ++ (lib.optionals supportEvilTwin [
    bettercap
    dhcp
    dnsmasq
    ettercap
    hostapd
    lighttpd
    openssl
    mdk4
    nftables
    apparmor-bin-utils
  ]) ++ (lib.optionals supportX11 [
    xterm
    xorg.xset
    xorg.xdpyinfo
  ]);
  disabledOptionalsCommands =
    (lib.optionals (supportWpaWps != true) [
      "bully"
      "reaver"
      "wash"
    ]) ++ (lib.optionals (supportHashCracking != true) [
      "hashcat"
      "hcxdumptool"
      "hcxpcapngtool"
      "john"
      "tshark"
    ]) ++ (lib.optionals (supportEvilTwin != true) [
      "bettercap"
      "openssl"
      "apparmor_status"
      "etterlog"
    ]) ++ (lib.optionals (supportX11 != true) [
      "xdpyinfo"
      "xset"
      "xterm"
    ]);
in
resholve.mkDerivation rec {
  pname = "airgeddon";
  version = "11.01";

  src = fetchFromGitHub {
    owner = "v1s1t0r1sh3r3";
    repo = "airgeddon";
    rev = "v${version}";
    sha256 = "3TjaLEcerRk69Ys4kj7vOMCRUd0ifFJzL4MB5ifoK68=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  # What these replacings do?
  # - Disable the auto-updates (we'll run from a read-only directory);
  # - Silence the checks (NixOS will enforce the PATH, it will only see the tools as we listed);
  # - Use "tmux", we're not patching XTerm commands;
  # - Remove PWD and $0 references, forcing it to use the paths from store;
  # - Force our PATH to all tmux sessions.
  postPatch = ''
    patchShebangs airgeddon.sh
    sed -i '
      s|AIRGEDDON_AUTO_UPDATE=true|AIRGEDDON_AUTO_UPDATE=false|
      s|AIRGEDDON_SILENT_CHECKS=false|AIRGEDDON_SILENT_CHECKS=true|
      s|AIRGEDDON_WINDOWS_HANDLING=xterm|AIRGEDDON_WINDOWS_HANDLING=tmux|
      ' .airgeddonrc

    sed -Ei '
      s|\$\(pwd\)|${placeholder "out"}/share/airgeddon;scriptfolder=${placeholder "out"}/lib/airgeddon/|
      s|\$\{0\}|${placeholder "out"}/bin/airgeddon|
      s|^(.+) =~ ([^\$].+) ]]|regexp='\2'; \1 =~ $regexp ]]|
      s|\$\{scriptfolder}\$\{rc_file_name}|${placeholder "out"}/share/airgeddon/.airgeddonrc|
      ' airgeddon.sh
  '';


  solutions = {
    airgeddon = {
      interpreter = "${bash}/bin/bash";
      scripts = [
        "bin/airgeddon"
        "lib/airgeddon/known_pins.db"
        "lib/airgeddon/language_strings.sh"
        "lib/airgeddon/plugins/*"
      ];
      inputs = deps;
      keep = {
        "$option_var_value" = true;
        "$iptables_cmd" = true;
        "$hccapx_converter_path" = true;
        "$prehook_funcion_name" = true;
        "$funtion_call" = true;
        "$posthook_funcion_name" = true;

        # Configurable stuff
        "$AIRGEDDON_DEBUG_MODE" = true;
        "$AIRGEDDON_DEVELOPMENT_MODE" = true;
        "$AIRGEDDON_5GHZ_ENABLED" = true;
        "$AIRGEDDON_SKIP_INTRO" = true;
        "$AIRGEDDON_BASIC_COLORS" = true;
        "$AIRGEDDON_EXTENDED_COLORS" = true;
        "$AIRGEDDON_AUTO_CHANGE_LANGUAGE" = true;
        "$AIRGEDDON_SILENT_CHECKS" = true;
        "$AIRGEDDON_PRINT_HINTS" = true;
        "$AIRGEDDON_FORCE_IPTABLES" = true;
        "$AIRGEDDON_FORCE_NETWORK_MANAGER_KILLING" = true;
        "$AIRGEDDON_WINDOWS_HANDLING" = true;

        # source = [ "${placeholder "out"}/lib/airgeddon/plugins/missing_dependencies.sh" ];
      };
      fix = {
        source = [ "${placeholder "out"}" ];
        "$airmon" = [ "airmon-ng" ];
        "$AIRGEDDON_AUTO_UPDATE" = [ "false" ];
        "$AIRGEDDON_MDK_VERSION" = [ "mdk4" ];
        "$AIRGEDDON_PLUGINS_ENABLED" = [ "true" ];

        "$scriptfolder" = [ "${placeholder "out"}/lib/airgeddon/" ];
        "$language_strings_file" = [ "language_strings.sh" ];
        "$known_pins_dbfile" = [ "known_pins.db" ];

        # Thank god there is only one plugin
        # "$file" = [ "${placeholder "out"}/lib/airgeddon/plugins/missing_dependencies.sh" ];
      };
      fake.external = [ "apt" "pacman" ] # platform-specific external commands in cross-platform conditionals
        ++ [
        "service" # This seems to be used to manage the "beef" service, we don't have beef.
        "ping" # There is not yet a good way to resolve 'ping' in Nix builds.
      ]
        ++ disabledOptionalsCommands;
      execer = [
        "cannot:${bully}/bin/bully"
        "cannot:${reaverwps-t6x}/bin/reaver"
        "cannot:${iproute2}/bin/ss"
        "cannot:${reaverwps-t6x}/bin/wash"
        "cannot:${iproute2}/bin/ip"
        "cannot:${aircrack-ng}/bin/airmon-ng"
        "cannot:${systemd}/bin/systemctl"
        "cannot:${ettercap}/bin/etterlog"
        "cannot:${networkmanager}/bin/NetworkManager"
        "cannot:${hcxdumptool}/bin/hcxdumptool"
        "cannot:${bettercap}/bin/bettercap"
        "cannot:${wireshark-cli}/bin/tshark"

        # These can run their arguments, but their lore is broken
        "cannot:${tmux}/bin/tmux"
        "cannot:${coreutils-full}/bin/timeout"
      ];
    };
  };

  # Install only the interesting files
  installPhase = ''
    runHook preInstall
    install -Dm 755 airgeddon.sh "$out/bin/airgeddon"
    install -dm 755 "$out/share/airgeddon"
    install -Dm 644 language_strings.sh "$out/lib/airgeddon/language_strings.sh"
    install -m 644 known_pins.db "$out/lib/airgeddon/known_pins.db"
    install -Dm 644 plugins/missing_dependencies.sh "$out/lib/airgeddon/plugins/missing_dependencies.sh"
    cp -dr --no-preserve='ownership' .airgeddonrc "$out/share/airgeddon/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Multi-use TUI to audit wireless networks. ";
    homepage = "https://github.com/v1s1t0r1sh3r3/airgeddon";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ pedrohlc ];
    platforms = platforms.linux;
  };
}
