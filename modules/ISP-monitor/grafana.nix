{ config, ... }:
{
  # Grafana admin password
  sops.secrets.grafana-admin-password = {
    owner = "grafana";
    mode = "0400";
  };

  # Grafana Secret key
  sops.secrets.grafana-secret-key = {
    owner = "grafana";
    mode = "0400";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.${config.networking.hostName}.duckdns.org";
        root_url = "https://grafana.${config.networking.hostName}.duckdns.org/";
        enable_gzip = true;
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{${config.sops.secrets.grafana-admin-password.path}}";
        secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
      };
      analytics.reporting_enabled = false;
    };

    # Provision VictoriaMetrics as a Prometheus-compatible datasource
    provision = {
      datasources.settings.datasources = [
        {
          name = "VictoriaMetrics";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:8428";
          isDefault = true;
        }
      ];

      # Provision dashboards from repo
      dashboards.settings.providers = [
        {
          name = "ISP Monitor";
          options.path = "${./dashboards}";
          disableDeletion = true;
        }
      ];
    };
  };

  # Reverse proxy for Grafana
  services.nginx.virtualHosts."grafana.${config.networking.hostName}.duckdns.org" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    http3 = true;
    quic = true;

    extraConfig = ''
      add_header Alt-Svc 'h3=":443"; ma=86400' always;
    '';

    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
      extraConfig = ''
        limit_req zone=general burst=20 nodelay;
      '';
    };
  };
}
