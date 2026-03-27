{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../users/smithoo4
  ];

  # Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
