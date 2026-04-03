{ config, pkgs, lib, ... }:

let
  # Plugins
  customCaddy = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/duckdns" ];
    hash = lib.fakeSha256;   # ← replace with the real hash after first build
  };
in
{
  # Secrets
  sops.secrets.duckdns-token = {};
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
    acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";  # staging for testing

    # Reusable snippet for every virtual host
    globalConfig = ''
      tls {
        dns duckdns {env.DUCKDNS_TOKEN}
      }
    '';

    # Firewall
    # openFirewall = true; #Unstable option look into in the future
  };

   #FireWall
   networking.firewall.allowedTCPPorts = [ 80 443 ];
   networking.firewall.allowedUDPPorts = [ 443 ];
}
