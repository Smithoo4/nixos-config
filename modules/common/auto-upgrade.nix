{ config, ... }:
{
  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:Smithoo4/nixos-config#${config.networking.hostName}";
    flags = [
      "--no-write-lock-file"
      "-L"
    ];
    dates = "Sun *-*-* 01:00:00";
    randomizedDelaySecs = 300;
    allowReboot = true;
  };
}
