{ config, ... }:
{
  # VictoriaMetrics — time-series database (single-node)

  services.victoriametrics = {
    enable = true;
    listenAddress = "127.0.0.1:8428";
    retentionPeriod = "6";
  };

  # Reverse proxy for VictoriaMetrics UI
  services.nginx.virtualHosts."vmui.${config.networking.hostName}.duckdns.org" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    http3 = true;
    quic = true;

    extraConfig = ''
      add_header Alt-Svc 'h3=":443"; ma=86400' always;
    '';

    locations."/" = {
      proxyPass = "http://127.0.0.1:8428";
      extraConfig = ''
        limit_req zone=general burst=20 nodelay;
      '';
    };
  };
}
