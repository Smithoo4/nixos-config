{ self, ... }:
{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ./disko.nix

    # Users
    "${self}/users/smithoo4"

    # Services
    "${self}/modules/smartd.nix"
    # "${self}/modules/caddy"
  ];

  # Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
