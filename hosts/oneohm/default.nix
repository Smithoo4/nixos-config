{ self, ... }:
{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ./disko.nix

    # Users
    "${self}/users/smithoo4"

    # Services
    "${self}/modules/caddy"
    ./testPage.nix
  ];

  # Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
