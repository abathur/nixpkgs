{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, coreutils
, bashInteractive
}:

stdenv.mkDerivation rec {
  version = "0.1.0";
  pname = "yallback";
  src = fetchFromGitHub {
    owner = "abathur";
    repo = "yallback";
    rev = "540a36b30a29747d10fdc745b1d1bbfb3b32396f";
    hash = "sha256-HgIu54Te++dAiwX4mKhjpIL+miZdw6tjOljtfUJ+0zw=";
  };

  buildInputs = [ coreutils bashInteractive ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dv yallback $out/bin/yallback
    wrapProgram $out/bin/yallback --prefix PATH : ${lib.makeBinPath [ coreutils ]}
  '';

  meta = with lib; {
    description = "Callbacks for YARA rule matches";
    homepage = "https://github.com/abathur/yallback";
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
