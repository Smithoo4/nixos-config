{ config, ... }:
{
  # Secrets
  sops.secrets.smithoo4-password = {
    neededForUsers = true;
  };
  sops.secrets.smithoo4-ssh-key = {
    owner = "smithoo4";
    mode = "0600";
  };

  # User
  users.users.smithoo4 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.smithoo4-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpbgg2fUmjFNcQ/ByytJKnYZYpl8kOcocbK8vAl/8Yq smithoo4@fedora"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKlUTJNftUHaXItYUtlCawEHUd5HA9uUYhRW8LaFknW5 huiyi@ultramarine"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGcNh5n0Fc/bJ9SaYSMyrw4EoJ98Of7iGJDIJ6K+Csb+ 13087392+Smithoo4@users.noreply.github.com"
    ];
  };
  services.openssh.settings.AllowUsers = [ "smithoo4" ];

  # Home-manager
  home-manager.users.smithoo4 = import ./home-manager.nix;
}
