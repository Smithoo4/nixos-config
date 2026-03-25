{ pkgs, hostname, timezone, ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # zram
  zramSwap.enable = true;

  # Hostname & locale
  networking.hostName = hostname;
  time.timeZone = timezone;
  i18n.defaultLocale = "en_CA.UTF-8";

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  # Packages
  environment.systemPackages = with pkgs; [
    age
    git
    mkpasswd
    sops
  ];
}
