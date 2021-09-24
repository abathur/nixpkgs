{ lib
, stdenv
, resholvePackage
, fetchurl
, writeTextFile
, bash
, coreutils
, unzip
, ruby
, openssl
}:

resholvePackage rec {
  pname = "ec2-ami-tools";

  version = "1.5.7";

  nativeBuildInputs = [ unzip ];

  src = fetchurl {
    url = "https://s3.amazonaws.com/ec2-downloads/${pname}-${version}.zip";
    sha256 = "17xj7xmdbcwdbzalhfs6yyiwa64978mk3li39l949qfjjgrxjias";
  };

  # Amazon EC2 requires that disk images are writable.  If they're
  # not, the VM immediately terminates with a mysterious
  # "Server.InternalError" message.  Since disk images generated in
  # the Nix store are read-only, they must be made writable in the
  # tarball uploaded to Amazon S3.  So add a `--mode=0755' flag to the
  # tar invocation.
  patches = [ ./writable.patch ];

  installPhase =
    ''
      mkdir -p $out
      mv * $out
      rm $out/*.txt

      sed -i 's|/bin/bash|${stdenv.shell}|' $out/lib/ec2/platform/base/pipeline.rb
    '';  # */

  solutions = {
    scripts = {
      interpreter = "${bash}/bin/bash";
      scripts = [
        "bin/ec2-ami-tools-version"
        "bin/ec2-bundle-image"
        "bin/ec2-bundle-vol"
        "bin/ec2-delete-bundle"
        "bin/ec2-download-bundle"
        "bin/ec2-migrate-bundle"
        "bin/ec2-migrate-manifest"
        "bin/ec2-unbundle"
        "bin/ec2-upload-bundle"
      ];
      inputs = [ coreutils ruby openssl ];
      fix = {
        "$EC2_AMITOOL_HOME" = [ "${placeholder "out"}" ];
      };
    };
  };

  meta = {
    homepage = "https://aws.amazon.com/developertools/Amazon-EC2/368";
    description = "Command-line tools to create and manage Amazon EC2 virtual machine images";
    license = lib.licenses.amazonsl;
  };

}
