# ┌─────────────────────────────────────────────────────────────────┐
# │  REFERENCE ONLY — This file is NOT imported in default.nix.    │
# │  Copy and adapt for new services.                              │
# └─────────────────────────────────────────────────────────────────┘

{ config, ... }:

let
  domain = "blog.${config.networking.hostName}.duckdns.org";
in
{
  services.caddy.virtualHosts.${domain} = {
    extraConfig = ''
      import security
      reverse_proxy localhost:8080
    '';
  };
}
