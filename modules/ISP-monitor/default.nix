{ pkgs, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
    ./router-metrics.nix
    ./ping.nix
    #./speed-test.nix # Disabled — revisit later
  ];

  environment.systemPackages = [
    pkgs.jq
  ];
}
