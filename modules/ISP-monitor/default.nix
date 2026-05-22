{ pkgs, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
  ];

  # CLI tools for testing and validation
  environment.systemPackages = [ pkgs.jq ];
}
