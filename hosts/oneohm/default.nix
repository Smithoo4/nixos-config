{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
