{ config, self, ... }:
{
  # Secrets
  sops.secrets.smithoo4-password = {
    neededForUsers = true;
  };
  sops.secrets.smithoo4-ssh-key = {
    owner = "smithoo4";
    mode = "0600";
  };

  # Users
  users.users.smithoo4 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.smithoo4-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpbgg2fUmjFNcQ/ByytJKnYZYpl8kOcocbK8vAl/8Yq smithoo4@fedora"
    ];
  };

  # Home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit self; };
  home-manager.users.smithoo4 = import ./home-manager.nix;
}
