{ config, lib, pkgs, ... }:

{
  # CrowdSec
  services.crowdsec = {
    enable = true;

    # Official collections from CrowdSec Hub 
    hub.collections = [ "crowdsecurity/linux" ];
    
    # Acquisition sources → goes into /etc/crowdsec/acquis.yaml
    #localConfig.acquisitions = [
    #  {
    #    source = "journalctl";
    #    journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
    #    labels = { type = "syslog"; };
    #  }
    #];

  };

  # Firewall → Recommended to work with crowdsec
  networking.nftables.enable = true;
  
  # Automatic IP blocking bouncer
  services.crowdsec-firewall-bouncer = {
    enable = true;
  };
  
  # Ensure it starts after the firewall is ready
    systemd.services.crowdsec-firewall-bouncer = {
      after = [ "nftables.service" ];
      partOf = [ "nftables.service" ];
  };
}
