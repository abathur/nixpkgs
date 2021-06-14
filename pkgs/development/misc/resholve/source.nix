{ fetchFromGitHub
, ...
}:

rec {
  version = "0.6.0-pre";
  rSrc =
    # local build -> `make ci`; `make clean` to restore
    # return to remote source
    # if builtins.pathExists ./.local
    # then ./.
    # else
      fetchFromGitHub {
        owner = "abathur";
        repo = "resholve";
        rev = "4985b76c9c88622da0f85d5584f49bdb4e136a03";
        hash = "sha256-GyTB8VB1ajMw9G2DoISo0lNynvO/LVLFiV9EZoaan2E=";
        # rev = "v${version}";
        # hash = "sha256-+9MjvO1H+A3Ol2to5tWqdpNR7osQsYcbkX9avAqyrKw=";
      };
}
