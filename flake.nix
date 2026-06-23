{
  description = "NixOS system — Robotics workstation with Niri + Noctalia v5";

  outputs = inputs@{ self, nixpkgs, home-manager, noctalia, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        ./noctalia.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs      = true;
          home-manager.useUserPackages    = true;
          home-manager.extraSpecialArgs   = { inherit inputs; };
          home-manager.users.obiwan       = import ./home.nix;
        }
      ];
    };
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # v5: default branch IS v5 — no branch suffix needed.
    # NOTE: nixpkgs.follows is intentionally OMITTED here so the
    # Cachix binary cache is accepted. Without this omission Nix
    # rejects the substituter and you compile Noctalia from source.
    noctalia.url = "github:noctalia-dev/noctalia";
  };
}
