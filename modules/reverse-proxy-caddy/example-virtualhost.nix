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
  services.caddy.virtualHosts.${domain} = {
    extraConfig = ''
      import security
      reverse_proxy localhost:8080
    '';
  };
}
