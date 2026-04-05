{ config, lib, ... }:

{
  services.caddy.virtualHosts."oneohm.duckdns.org".extraConfig = ''
    import security
  '';
}
