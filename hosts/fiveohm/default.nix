{ self, ... }:
{
  # Bootloader (UEFI — Oracle ARM A1)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # OCI: force predictable interface name (eth0) regardless of kernel enumeration order
  boot.kernelParams = [ "net.ifnames=0" ];

  # OCI: set nameservers explicitly — DHCP-provided DNS is unreliable on NixOS VPS installs
  networking.nameservers = [
    "149.112.121.10"
    "149.112.122.10"
  ];

  imports = [
    # Hardware
    ./hardware-configuration.nix
    ./disko.nix

    # Users
    # "${self}/users/…"

    # Services
    # "${self}/modules/…"
  ];

  # Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
