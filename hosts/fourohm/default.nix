{ self, ... }:
{
  # Bootloader (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

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
