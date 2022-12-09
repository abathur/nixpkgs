{ lib, stdenv, fetchFromGitHub
, cmake, wrapGAppsHook
, libX11, libzip, glfw, libpng, xorg, gnome
, darwin, xcbuild
}:

stdenv.mkDerivation rec {
  pname = "tev";
  version = "1.23";

  src = fetchFromGitHub {
    owner = "Tom94";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-NtnnZV/+8aUm8BkUz8Xm3aeSbOI2gNUPNfvYlwUl01Y=";
  };

  prePatch = ''
    substituteInPlace dependencies/nanogui/ext/glfw/src/cocoa_joystick.m \
      --replace "Kernel/IOKit/hidsystem/IOHIDUsageTables.h" "IOKit/hid/IOHIDUsageTables.h"
    substituteInPlace dependencies/nanogui/CMakeLists.txt \
      --replace 'set(NANOGUI_BACKEND_DEFAULT "Metal")' 'set(NANOGUI_BACKEND_DEFAULT "OpenGL")'
  '';

  nativeBuildInputs = [ cmake wrapGAppsHook xcbuild ];
  buildInputs = [ libX11 libzip glfw libpng ]
    ++ (with xorg; [ libXrandr libXinerama libXcursor libXi libXxf86vm libXext ])
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ AppKit Cocoa Carbon Foundation IOKit OpenGL ]);

  dontWrapGApps = true; # We also need zenity (see below)

  cmakeFlags = [
    "-DTEV_DEPLOY=1" # Only relevant not to append "dev" to the version
  ];

  postInstall = ''
    wrapProgram $out/bin/tev \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH ":" "${gnome.zenity}/bin"
  '';

  meta = with lib; {
    description = "A high dynamic range (HDR) image comparison tool";
    longDescription = ''
      A high dynamic range (HDR) image comparison tool for graphics people. tev
      allows viewing images through various tonemapping operators and inspecting
      the values of individual pixels. Often, it is important to find exact
      differences between pairs of images. For this purpose, tev allows rapidly
      switching between opened images and visualizing various error metrics (L1,
      L2, and relative versions thereof). To avoid clutter, opened images and
      their layers can be filtered by keywords.
      While the predominantly supported file format is OpenEXR certain other
      types of images can also be loaded.
    '';
    inherit (src.meta) homepage;
    changelog = "https://github.com/Tom94/tev/releases/tag/v${version}";
    license = licenses.bsd3;
    platforms = platforms.unix;
    badPlatforms = [ "aarch64-linux" ]; # fails on Hydra since forever
    # broken = stdenv.isDarwin; # builds need work
    maintainers = with maintainers; [ ];
  };
}
