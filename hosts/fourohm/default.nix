{ self, ... }:
{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ./disko.nix

    # Users

    # Services

  ];

  # Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
