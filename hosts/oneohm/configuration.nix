{ pkgs, config, ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # zram
  zramSwap.enable = true;

  # Hostname
  networking.hostName = "oneohm";

  # Locale & time
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # sops-nix
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Secrets
  sops.secrets.smithoo4-password = {
    neededForUsers = true;
  };

  sops.secrets.smithoo4-ssh-key = {
    owner = "smithoo4";
    mode = "0600";
  };

  # Users
  users.mutableUsers = false;
  users.users.smithoo4 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.smithoo4-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpbgg2fUmjFNcQ/ByytJKnYZYpl8kOcocbK8vAl/8Yq smithoo4@fedora"
    ];
  };

  # Secure OpenSSH (key-only, no root login)
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Packages
  environment.systemPackages = with pkgs; [
    age
    git
    mkpasswd
    sops
  ];

  # Perform garbage collection weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Optimize storage
  nix.settings.auto-optimise-store = true;

  # Set once at install time. Do NOT change it after the first boot.
  system.stateVersion = "25.11";
}
