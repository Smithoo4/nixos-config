{ config, pkgs, ... }:

{
  # Reusable failure notifier for any systemd service
  systemd.services."notify-failure@" = {
    description = "Email notification when a systemd service fails";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = let
        notifier = pkgs.writeShellScript "notify-failure" ''
          #!/bin/sh
          UNIT="$1"
          HOSTNAME="${config.networking.hostName}"

          ${pkgs.msmtp}/bin/msmtp root <<EOF
          To: root
          Subject: [NixOS] Service $UNIT failed on $HOSTNAME

          Service: $UNIT
          Host: $HOSTNAME
          Time: $(date)

          === Full status (last 1000 lines) ===
          $(systemctl status -n 1000 "$UNIT")

          EOF
        '';
      in "${notifier} %i";
    };
  };
}
