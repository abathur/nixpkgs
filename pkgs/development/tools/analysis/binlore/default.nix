{ lib
, fetchFromGitHub
, runCommand
, pkgsBuildBuild
}:

/* TODO/CAUTION:

I don't want to discourage use, but I'm not sure how stable
the API is. Have fun, but be prepared to track changes! :)

For _now_, binlore is basically a thin wrapper around
`<invoke yara> | <postprocess with yallback>` with support
for running it on a derivation, saving the result in the
store, and aggregating results from a set of packages.

In the longer term, I suspect there are more uses for this
general pattern (i.e., run some analysis tool that produces
a deterministic output and cache the result per package...).

I'm not sure how that'll look and if it'll be the case that
binlore automatically collects all of them, or if you'll be
configuring which "kind(s)" of lore it generates. Nailing
that down will almost certainly mean reworking the API.

*/

let
  src = fetchFromGitHub {
    owner = "abathur";
    repo = "binlore";
    rev = "v0.2.0";
    hash = "sha256-bBJky7Km+mieHTqoMz3mda3KaKxr9ipYpfQqn/4w8J0=";
  };
  /*
  binlore has one one more yallbacks responsible for
  routing the appropriate lore to a named file in the
  appropriate format. At some point I might try to do
  something fancy with this, but for now the answer to
  *all* questions about the lore are: the bare minimum
  to get resholve over the next feature hump in time to
  hopefully slip this feature in before the branch-off.
  */
  # TODO: feeling really uninspired on the API
  loreDef = {
    # YARA rule file
    rules = (src + "/execers.yar");
    # output filenames; "types" of lore
    types = [ "execers" "wrappers" ];
    # shell rule callbacks; see github.com/abathur/yallback
    yallback = (src + "/execers.yall");
    # TODO:
    # - echo for debug, can be removed at some point
    # - I really just wanted to put the bit after the pipe
    #   in here, but I'm erring on the side of flexibility
    #   since this form will make it easier to pilot other
    #   uses of binlore.
    callback = lore: drv: ''
      if [[ -d "${drv}/bin" ]] || [[ -d "${drv}/lib" ]] || [[ -d "${drv}/libexec" ]]; then
        echo generating binlore for $drv by running:
        echo "${pkgsBuildBuild.yara}/bin/yara --scan-list --recursive ${lore.rules} <(printf '%s\n' ${drv}/{bin,lib,libexec}) | ${pkgsBuildBuild.yallback}/bin/yallback ${lore.yallback}"
      else
        echo "failed to generate binlore for $drv (none of ${drv}/{bin,lib,libexec} exist)"
      fi

      if [[ -d "${drv}/bin" ]] || [[ -d "${drv}/lib" ]] || [[ -d "${drv}/libexec" ]]; then
        ${pkgsBuildBuild.yara}/bin/yara --scan-list --recursive ${lore.rules} <(printf '%s\n' ${drv}/{bin,lib,libexec}) | ${pkgsBuildBuild.yallback}/bin/yallback ${lore.yallback}
      fi
    '';
  };

in rec {
  collect = { lore ? loreDef, drvs, strip ? [ ] }: (runCommand "more-binlore" { } ''
    mkdir $out
    for lorefile in ${toString lore.types}; do
      cat ${lib.concatMapStrings (x: x + "/$lorefile ") (map (make lore) (map lib.getBin (builtins.filter lib.isDerivation drvs)))} > $out/$lorefile
      substituteInPlace $out/$lorefile ${lib.concatMapStrings (x: "--replace '${x}/' '' ") strip}
    done
  '');
  # TODO: echo for debug, can be removed at some point
  make = lore: drv: runCommand "${drv.name}-binlore" {
      drv = drv;
    } (''
    mkdir $out
    touch $out/{${builtins.concatStringsSep "," lore.types}}

    ${lore.callback lore drv}
    '' + lib.optionalString (builtins.hasAttr "lore" drv)
    # Append lore passed in the package's $out and drv.lore (last entry wins)
    ''

    if [[ -f "${drv}/nix-support/execers" ]]; then
      cat "${drv}/nix-support/execers" >> "$out/execers"
    fi
    if [[ -f "${drv.lore}/execers" ]]; then
      cat "${drv.lore}/execers" >> "$out/execers"
    fi

    if [[ -f "${drv}/nix-support/wrappers" ]]; then
      cat "${drv}/nix-support/wrappers" >> "$out/wrappers"
    fi
    if [[ -f "${drv.lore}/wrappers" ]]; then
      cat "${drv.lore}/wrappers" >> "$out/wrappers"
    fi
  '' + ''
    echo binlore for $drv written to $out
  '');
  synthesize = drv: lore: runCommand "${drv.name}-lore-override" {
    drv = drv;
  } (''
    execer(){
      local verdict="$1"

      shift

      for path in "$@"; do
        if [[ -e "$path" ]]; then
          echo "$verdict:$path"
        else
          echo "error: Tried to synthesize execer lore for missing file: $path (pwd: $PWD)" >&2
          exit 2
        fi
      done
    } >> $out/execers

    wrapper(){
      local wrapper="$1"
      local original="$2"

      if [[ ! -e "$wrapper" ]]; then
        echo "error: Tried to synthesize wrapper lore for missing wrapper: $wrapper (pwd: $PWD)" >&2
        exit 2
      fi

      if [[ ! -e "$original" ]]; then
        echo "error: Tried to synthesize wrapper lore for missing original: $original (pwd: $PWD)" >&2
        exit 2
      fi

      echo "$wrapper:$original"

    } >> $out/wrappers

    mkdir $out

    # lore override commands are relative to the drv root
    cd $drv

  '' + lore);
}
