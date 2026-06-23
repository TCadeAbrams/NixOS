# noctalia.nix — NixOS system-level prerequisites for Noctalia v5
{ config, pkgs, inputs, ... }:

{
  # Cachix binary cache for Noctalia — avoids compiling Noctalia from source.
  # The noctalia flake input intentionally omits nixpkgs.follows (see flake.nix)
  # which is required for this substituter to be accepted by Nix.
  nix.settings = {
    extra-substituters      = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  # Noctalia wifi widget
  networking.networkmanager.enable = true;

  # Noctalia bluetooth widget
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Noctalia power-profile widget
  services.power-profiles-daemon.enable = true;

  # Noctalia battery widget
  services.upower.enable = true;
}
