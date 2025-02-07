{ pkgs ? import <nixpkgs> {} }:

let
  imageName = "test-container";
  imageTag = "latest";

  env = pkgs.buildEnv {
    name = "image-root";
    paths = [
      pkgs.bashInteractive
      pkgs.coreutils
    ];
  };

  containerImage = pkgs.dockerTools.buildImage {
    name = imageName;
    tag = imageTag;

    copyToRoot = env;

    config = {
      Cmd = [ "/bin/bash" ];
      WorkingDir = "/";
    };
  };

  exportScript = pkgs.writeScriptBin "export-${imageName}" ''
    #!${pkgs.bash}/bin/bash

    cp ${containerImage} ./${imageName}-${imageTag}.tar.gz
    echo "image written to: ./${imageName}-${imageTag}.tar.gz"
  '';
in
  {
    inherit containerImage;
    exporter = exportScript;

    # Allow others to use this if they need it
    inherit imageName imageTag;
  }
