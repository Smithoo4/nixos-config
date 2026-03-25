{ pkgs, self, ... }:
{
  home.packages = with pkgs; [
    htop
    tree
    wget
  ];

  # Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "smithoo4";
        email = "13087392+Smithoo4@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };

  # SSH client
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/run/secrets/smithoo4-ssh-key";
      };
    };
  };

  home.file.".ssh/smithoo4_github_ed25519.pub" = {
    source = "${self}/secrets/smithoo4_github_ed25519.pub";
  };

  home.stateVersion = "25.11";
}
