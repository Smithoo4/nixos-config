{ lib, ... }:
{
  ## Networking
  networking.useDHCP = lib.mkDefault true;

  ## Platform
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
