{ config, ... }:

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
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      dnsProvider = "duckdns";
      environmentFile = config.sops.templates."acme-duckdns-env".path;
    };
  };
}
