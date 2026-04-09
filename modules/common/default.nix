{ pkgs, self, hostname, timezone, ... }:
{
  imports = [
    ./openssh.nix
    ./msmtp.nix
    ./notify-failure.nix
    ./auto-upgrade.nix
    ./nix-maintenance.nix
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

  # Home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Nix experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Nix Download Buffer
  nix.settings.download-buffer-size = 268435456; # 256 MB

  # Packages
  environment.systemPackages = with pkgs; [
    git
  ];

}
