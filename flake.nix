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
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    mkHost = { system, hostname, timezone ? "America/Edmonton" }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self hostname timezone; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          ./modules/nixos/common.nix
          ./modules/nixos/openssh.nix
          ./hosts/${hostname}
        ];
      };
  in {
    nixosConfigurations = {
      oneohm = mkHost {
        system = "x86_64-linux";
        hostname = "oneohm";
        timezone = "America/Edmonton";
      };

      # auir = mkHost {
      #   system = "aarch64-linux";
      #   hostname = "auir";
      #   timezone = "TODO";
      # };
      # artimoose = mkHost { system = "x86_64-linux"; hostname = "artimoose"; };
      # gypsystudio = mkHost { system = "x86_64-linux"; hostname = "gypsystudio"; };
    };
  };
}
