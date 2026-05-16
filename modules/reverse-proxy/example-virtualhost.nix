# ┌─────────────────────────────────────────────────────────────────┐
# │  REFERENCE ONLY — This file is NOT imported in default.nix.    │
# │  Copy and adapt for new services.                              │
# └─────────────────────────────────────────────────────────────────┘

{ config, ... }:

let
  domain = "blog.${config.networking.hostName}.duckdns.org";
in
{
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    http3 = true;
    quic = true;

    extraConfig = ''
      add_header Alt-Svc 'h3=":443"; ma=86400' always;
    '';

    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      extraConfig = ''
        limit_req zone=general burst=20 nodelay;
      '';
    };

    # Override clientMaxBodySize for file-heavy services
    # locations."/upload".extraConfig = ''
    #   client_max_body_size 2g;
    # '';
  };
}
