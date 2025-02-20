{
  nixVersion ? "23.11",
  nixHash ? "1f5d2g1p6nfwycpmrnnmc2xmcszp804adp16knjvdkj8nz36y1fg",
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-${nixVersion}.tar.gz";
    sha256 = nixHash;
  }) {}
}:

let
  imageName = "vnix-pure";
  imageTag = nixVersion;

  env = pkgs.buildEnv {
    name = "image-root";
    paths = [
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.nix
    ];
  };

  containerImage = pkgs.dockerTools.buildImage {
    name = "stelfox.net/containers/${imageName}";
    tag = imageTag;

    copyToRoot = env;

    config = {
      Cmd = [ "/bin/bash" ];
      WorkingDir = "/workspace";
    };
  };

  exportScript = pkgs.writeScriptBin "export-${imageName}" ''
    #!${pkgs.bash}/bin/bash

    set -o errexit
    set -o nounset
    set -o pipefail

    OUT_FILE="./${imageName}-${imageTag}.tar.gz"

    cp "${containerImage}" "$OUT_FILE"
    echo "image written to: $OUT_FILE"
  '';
in
  {
    inherit containerImage;
    exporter = exportScript;

    # Allow others to use this if they need it
    inherit imageName imageTag;
  }
