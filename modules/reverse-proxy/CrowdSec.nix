{ config, lib, pkgs, ... }:
{
  # nftables required for firewall bouncer
  #networking.nftables.enable = true;

  # CrowdSec
  services.crowdsec = {
    enable = true;
    localConfig.acquisitions = [
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
        labels = { type = "syslog"; };
      }
    ];
    hub.collections = [ "crowdsecurity/linux" ];
  };

  # Firewall bouncer
  services.crowdsec-firewall-bouncer = {
    enable = true;
  };

#  systemd.services.crowdsec-firewall-bouncer = {
#    after = [ "nftables.service" ];
#    partOf = [ "nftables.service" ];
#  };
}
