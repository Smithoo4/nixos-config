{ pkgs, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
    ./router-metrics.nix
    ./ping.nix
    ./grafana.nix
    #./speed-test.nix # Disabled — revisit later
  ];

  environment.systemPackages = [
    pkgs.jq
  ];
}
