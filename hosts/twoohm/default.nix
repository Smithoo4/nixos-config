{ self, inputs, ... }:
{

  ## Bootloader (RPi4 — extlinux)
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  ## F2FS support in initrd
  boot.initrd.supportedFilesystems = [ "f2fs" ];

  imports = [

    # Hardware
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./disko.nix
    ./hardware-configuration.nix

    # Users

    # Services
    # "${self}/modules/reverse-proxy-nginx"

  ];

  ## Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
