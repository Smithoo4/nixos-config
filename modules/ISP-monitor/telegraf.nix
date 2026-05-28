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

      # Router metrics via tplinkrouterc6u
      inputs.exec = {
        commands = [ "${./scripts/poll-router.py}" ];
        timeout = "30s";
        data_format = "influx";
        interval = "60s";
      };

    };
  };
}
