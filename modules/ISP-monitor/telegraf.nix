{ ... }:
{
  # Telegraf — data collection agent
  services.telegraf = {
    enable = true;
    extraConfig = {

      # Global agent settings
      agent = {
        interval = "60s";
        flush_interval = "60s";
      };

      # Output: VictoriaMetrics via InfluxDB line protocol
      outputs.influxdb = {
        urls = [ "http://127.0.0.1:8428" ];
        database = "victoriametrics";
        skip_database_creation = true;
        exclude_retention_policy_tag = true;
        content_encoding = "gzip";
      };

      # Smoke test: Telegraf's own internal metrics
      inputs.internal = {
        collect_memstats = true;
      };

      # Ping test — connectivity, latency, packet loss
      inputs.ping = {
        urls = [
          "192.168.0.1"
          "rogers.com"
          "1.1.1.1"
          "google.com"
        ];
        method = "native";
        count = 5;
        ping_interval = "1s";
        deadline = "10s";
        percentiles = [
          50
          95
          99
        ];
      };
    };
  };

  # Grant CAP_NET_RAW for native ping
  systemd.services.telegraf.serviceConfig = {
    CapabilityBoundingSet = [ "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_RAW" ];
  };
}
