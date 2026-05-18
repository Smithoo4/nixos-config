# ┌─────────────────────────────────────────────────────────────────┐
# │  ABANDONED — Keeping for reference only.                       │
# │                                                                │
# │  Reasons for choosing Nginx over Caddy on NixOS:               │
# │                                                                │
# │  • Caddy requires compiling a custom build for DNS-01 ACME     │
# │    challenges (e.g. DuckDNS plugin), adding maintenance        │
# │    overhead compared to Nginx’s built-in ACME integration.     │
# │                                                                │
# │  • No pre-built fail2ban jails or filters for Caddy. The       │
# │    Nginx + fail2ban ecosystem on NixOS is mature, widely       │
# │    used, and well documented with working examples.            │
# │                                                                │
# │  • CrowdSec shows stronger native alignment with Caddy         │
# │    (e.g. bouncers and middleware approach), potentially        │
# │    making it a better long-term fit for Caddy than fail2ban.    │
# │    However, on NixOS the CrowdSec ecosystem (packages,         │
# │    modules, and integrations) is still immature and not        │
# │    considered production-ready in this setup.                   │
# │                                                                │
# │  • Given the above, Nginx provides a more stable,               │
# │    reproducible, and better-supported solution on NixOS today.  │
# │                                                                │
# │  The Nginx reverse-proxy module is the active implementation.  │
# │  See: modules/reverse-proxy-nginx                              │
# └─────────────────────────────────────────────────────────────────┘

{ ... }:
{
  imports = [
    ./caddy.nix
    ./testPage.nix
  ];
}
