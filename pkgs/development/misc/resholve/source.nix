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
        rev = "e52b02ae6305851ffcf42590e337f0ad683939f1";
        hash = "sha256-VEVHJE4K1XUZ6HX4xXhNb8svXLkY3wCxAzA8pezCm5A=";
        # rev = "v${version}";
        # hash = "sha256-+9MjvO1H+A3Ol2to5tWqdpNR7osQsYcbkX9avAqyrKw=";
      };
}
