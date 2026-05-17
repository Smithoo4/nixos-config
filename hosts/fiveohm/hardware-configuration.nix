# Placeholder derived from the existing OCI ARM VM hardware.
# nixos-anywhere will overwrite this with a freshly generated version during install.
{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Kernel modules from the existing OCI A1 instance — should carry over accurately
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Filesystem mounts omitted — managed by disko

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
