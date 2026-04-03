{ config, lib, ... }:

{
  services.caddy.virtualHosts."oneohm.duckdns.org".extraConfig = ''
    respond <<EOF
    Hello from Caddy on oneohm!

    If you are seeing this:
    - Caddy is running
    - DuckDNS DNS challenge is working
    - TLS certificates are being issued
    EOF 200
  '';
}
