# ┌─────────────────────────────────────────────────────────────────┐
# │  REFERENCE ONLY — This file is NOT imported in default.nix.    │
# │  Copy and adapt for new services.                              │
# └─────────────────────────────────────────────────────────────────┘
#
# To use:
#   1. Copy this file or use it as a template for your service module
#   2. Import the new file in the appropriate host's default.nix
#   3. Create a DuckDNS DNS record for the new subdomain
#   4. Rebuild: sudo nixos-rebuild switch --flake .#<hostname>

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
    };

    # Override clientMaxBodySize for file-heavy services
    # locations."/upload".extraConfig = ''
    #   client_max_body_size 2g;
    # '';
  };
}
