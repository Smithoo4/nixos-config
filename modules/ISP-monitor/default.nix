{ pkgs, ... }:
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
    ./router-metrics.nix
    ./ping.nix
    # ./speed-test.nix      # Phase 3 — coming soon
  ];

  environment.systemPackages = [
    pkgs.jq
  ];
}
