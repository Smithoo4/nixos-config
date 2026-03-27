{ pkgs, self, hostname, timezone, ... }:
{
  imports = [
    ./openssh.nix
  ];

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

  # Sops-nix
  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Users
  users.mutableUsers = false;

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
    git
  ];

  # Home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
