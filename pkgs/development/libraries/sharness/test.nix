{ lib
, stdenv
, callPackage
, resholve
, writeScript
, resholveScript
, sharness
, runCommandNoCC
, ripgrep
}:

let
  extended = sharness.withPlugins {
    ext1 = writeScript "ext1.sh" ''
      great(){
        return 0
      }
      terrible(){
        return 1
      }
      rewrite_test_done(){
        local rewritten="_$(declare -f test_done)"
        eval "''${rewritten//exit/return}"
        test_done(){
          if _test_done ; then
            # create a nix output if no errors
            touch $out
            exit 0
          else
            exit $?
          fi
        }
      }
      rewrite_test_done
    '';
    ext2 = writeScript "ext2.sh" ''
      look_ma_no_hands(){
        test_expect_success "Ensure core API is available in extension" "
          true
        "
      }
    '';
  };
in {
  pass_present = runCommandNoCC "extension_smoke_test_present" {
    } ''
    test_description="ensure extension APIs are available"
    source ${extended}

    test_expect_success "One thing is awesome!" "
      test_expect_code 0 great
    "

    look_ma_no_hands

    test_done
  '';

  fail_build = runCommandNoCC "test_failure_breaks_build" {
    } ''
    test_description="ensure test failures break build"
    source ${extended}

    test_expect_success "One thing is bad :(" "
      test_expect_code 0 terrible
    "

    test_done
  '';
}
