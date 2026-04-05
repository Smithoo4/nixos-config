{ config, ... }:
{
  services.caddy.virtualHosts."${config.networking.hostName}.duckdns.org" = {
    extraConfig = ''
      import security
    '';
  };
}
