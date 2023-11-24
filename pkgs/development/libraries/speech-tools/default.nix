{ lib
, stdenv
, fetchFromGitHub
, ncurses
, alsa-lib
, CoreServices
, AudioUnit
, Cocoa
, meson
, ninja
, pkg-config
, cmake
, llvmPackages
, perl
}:

stdenv.mkDerivation rec {
  pname = "speech_tools";
  version = "2.5.1-unstable";

  src = fetchFromGitHub {
    owner = "festvox";
    repo = "speech_tools";
    rev = "63ff01938f81443f5a294bc5f9ea6ac6ab38f6b0";
    hash = "sha256-3r1EC6fDqTbf4w/bfkBeGxdHzK/Z710D3IaRL9U+4Mo=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    perl
  ];

  buildInputs = [
    ncurses
  ] ++ lib.optionals stdenv.isLinux [
    alsa-lib
  ] ++ lib.optionals stdenv.isDarwin [
    CoreServices
    AudioUnit
    Cocoa
  ] ++lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ];

  mesonFlags = [
    "-Daudio_nas=disabled"
    "-Daudio_esd=disabled"
  ] ++ lib.optionals (!stdenv.isLinux) [
    "-Daudio_alsa=disabled"
  ] ++ lib.optionals stdenv.isDarwin [
    "-Daudio_osx=enabled"
  ];

  preConfigure = ''
    sed -e s@/usr/bin/@@g -i $( grep -rl '/usr/bin/' . )
    sed -re 's@/bin/(rm|printf|uname)@\1@g' -i $( grep -rl '/bin/' . )

    # c99 makes isnan valid for float and double
    substituteInPlace include/EST_math.h \
      --replace '__isnanf(X)' 'isnan(X)'
  '';

  meta = with lib; {
    description = "Text-to-speech engine";
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.unix;
    license = licenses.free;
  };

  passthru = {
    updateInfo = {
      downloadPage = "http://www.festvox.org/packed/festival/";
    };
  };
}
