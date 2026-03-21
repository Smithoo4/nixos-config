{ pkgs, ... }:
{
  home-manager = {

    useGlobalPkgs = true;
    useUserPackages = true;

    users.smithoo4 = {

      # Packages installed to the user profile.
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
          init = {
            defaultBranch = "main";
          };
        };
      };

      # SSH client — GitHub identity
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = "/run/secrets/smithoo4-ssh-key";
          };
        };
      };

      # GitHub SSH public key — placed at ~/.ssh/ for easy reference
      home.file.".ssh/smithoo4_github_ed25519.pub" = {
        source = ../../secrets/smithoo4_github_ed25519.pub;
      };

      # Required
      home.stateVersion = "25.11";
    };
  };
}
