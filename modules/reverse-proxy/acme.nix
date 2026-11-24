{ config, lib, ... }:

{
  # Sops secrets
  sops.secrets.duckdns-token = { };
  sops.templates."acme-duckdns-env" = {
    content = ''
      DUCKDNS_TOKEN=${config.sops.placeholder.duckdns-token}
    '';
  };

  # ACME — DNS-01 via DuckDNS (lego)
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "smith_oo4@shaw.ca";
      #Staging for testing — comment out for production
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      dnsProvider = "duckdns";
      dnsResolver = "8.8.8.8:53,1.1.1.1:53";
      environmentFile = config.sops.templates."acme-duckdns-env".path;
    };
  };

  # Email root if any certificate renewal fails
  systemd.services = lib.mapAttrs' (
    cert: _:
    lib.nameValuePair "acme-order-renew-${cert}" {
      unitConfig.OnFailure = [ "notify-failure@%n.service" ];
    }
  ) config.security.acme.certs;
}
