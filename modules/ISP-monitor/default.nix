{ pkgs, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
    ./router-metrics.nix
    ./ping.nix
    ./speed-test.nix
  ];

  environment.systemPackages = [
    pkgs.jq
  ];
}
