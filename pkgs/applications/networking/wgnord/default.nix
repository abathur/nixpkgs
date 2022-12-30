{ coreutils
, curl
, fetchFromGitHub
, gnugrep
, gnused
, iproute2
, jq
, lib
, makeWrapper
, stdenv
, wireguard-tools
}:

stdenv.mkDerivation rec {
  pname = "wgnord";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "phirecc";
    repo = pname;
    rev = version;
    hash = "sha256-T7dAEgi4tGvrzBABGLzKHhpCx0bxSCtTVI5iJJqJGlE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace wgnord \
      --replace '$conf_dir/countries.txt' "$out/share/countries.txt" \
      --replace '$conf_dir/countries_iso31662.txt' "$out/share/countries_iso31662.txt"
  '';

  dontBuild = true;

  installPhase = ''
    install -Dm755 wgnord -t $out/bin/
    install -Dm 644 countries.txt -t $out/share/
    install -Dm 644 countries_iso31662.txt -t $out/share/
    wrapProgram $out/bin/${pname} --prefix PATH : ${lib.makeBinPath [
      coreutils
      curl
      gnugrep
      gnused
      iproute2
      jq
      wireguard-tools
    ]}
  '';

  meta = with lib; {
    description = "A NordVPN Wireguard (NordLynx) client in POSIX shell";
    homepage = "https://github.com/phirecc/wgnord";
    changelog = "https://github.com/phirecc/wgnord/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ urandom ];
    license = licenses.unfree; # https://github.com/phirecc/wgnord/issues/1
  };
}
