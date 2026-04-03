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
    randomizedDelaySec = "5min";
    allowReboot = true;
  };

  # Notify root on failure
  systemd.services.nixos-upgrade = {
    unitConfig.OnFailure = [ "notify-failure@%n.service" ];
  };
}
