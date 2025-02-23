{
  nixVersion ? "23.11",
  nixHash ? "1f5d2g1p6nfwycpmrnnmc2xmcszp804adp16knjvdkj8nz36y1fg",
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-${nixVersion}.tar.gz";
    sha256 = nixHash;
  }) {}
}:

let
  inherit (pkgs) lib;
  imageName = "vnix-pure";
  imageTag = nixVersion;

  # Where I left this off... Claude can't figure this out, the correct answer is to look up the
  # definition of the package being called with a name like a tarball in the nixpkgs repo
  baseSystem = lib.nixosSystem {
    system = pkgs.system;
    modules = [({ config, pkgs, ... }: {
      imports = [
        "${pkgs.path}/nixos/modules/installer/cd-dvd/channel.nix"
        "${pkgs.path}/nixos/modules/profiles/minimal.nix"
        "${pkgs.path}/nixos/modules/profiles/clone-config.nix"
      ];

      boot.isContainer = true;

      environment.systemPackages = [
        config.nix.package
      ];

      boot.postBootCommands = ''
        if [ -f /nix-path-registration ]; then
          ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration &&
            rm /nix-path-registration
        fi

        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
      '';

      system.activationScripts.installInitScript = ''
        ln -sf $systemConfig/init /init
      '';
    })];
  };

  containerImage = pkgs.dockerTools.buildImage {
    name = "stelfox.net/containers/${imageName}";
    tag = imageTag;

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [
        baseSystem.config.system.build.toplevel
        pkgs.stdenv
      ];
    };

    extraCommands = ''
      mkdir -p proc sys dev etc
    '';

    config = {
      Cmd = [ "/init" ];
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

in {
  inherit containerImage;
  exporter = exportScript;

  # Allow others to use this if they need it
  inherit imageName imageTag;
}
