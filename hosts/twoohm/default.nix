{ self, ... }:
{

  ## Bootloader (RPi4 — extlinux)
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Reduce write bursts to the SD card
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 5;
    "vm.dirty_background_ratio" = 2;
  };

  ## F2FS support in initrd
  boot.initrd.supportedFilesystems = [ "f2fs" ];

  imports = [

    # Hardware
    ./disko.nix
    ./hardware-configuration.nix

    # Users

    # Services
    # "${self}/modules/reverse-proxy"

  ];

  ## Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
