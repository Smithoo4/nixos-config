{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Plugins
  customCaddy = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
    hash = "sha256-oRlMRutaZEZqmB4FuV+01ZOaTLJTWGEQ4bHKbY5eeaI=";
  };
in
{
  # Secrets
  sops.secrets.duckdns-token = { };
  sops.templates."caddy-env" = {
    content = ''
      DUCKDNS_TOKEN=${config.sops.placeholder.duckdns-token}
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-env".path;

  services.caddy = {
    enable = true;
    package = customCaddy;

    email = "smith_oo4@shaw.ca";
    # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory"; # staging for testing

    globalConfig = ''
      # ACME using DuckDNS DNS-01 challenge
      acme_dns duckdns {env.DUCKDNS_TOKEN}
      # SNI enforcement
      servers {
        strict_sni_host on
      }
    '';

    #openFirewall = true;  # not available in 25.11 - enable when stable on your channel
  };

  # Catch-all Blocks
  services.caddy.virtualHosts.":443".extraConfig = "abort";
  services.caddy.virtualHosts.":80".extraConfig = "abort";

  # FireWall
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}
