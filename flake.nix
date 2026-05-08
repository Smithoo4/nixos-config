{
  description = "NixOS home servers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      mkHost =
        {
          system,
          hostname,
          timezone ? "America/Edmonton",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              self
              hostname
              timezone
              ;
          };
          modules = [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            ./hosts/${hostname}
            ./modules/common
            ./users/smithoo4
          ];
        };
    in
    {
      nixosConfigurations = {

        oneohm = mkHost {
          system = "x86_64-linux";
          hostname = "oneohm";
          timezone = "America/Edmonton";
        };

        twoohm = mkHost {
          system = "aarch64-linux";
          hostname = "twoohm";
          timezone = "America/Edmonton";
        };

        fourohm = mkHost {
          system = "x86_64-linux";
          hostname = "fourohm";
          timezone = "America/Edmonton";
        };
      };
    };
}
