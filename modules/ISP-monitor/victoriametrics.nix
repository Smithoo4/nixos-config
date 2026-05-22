{ ... }:
{
  # VictoriaMetrics — time-series database (single-node)
  # UI available at: http://127.0.0.1:8428/vmui
  services.victoriametrics = {
    enable = true;
    listenAddress = "127.0.0.1:8428";
    retentionPeriod = "6";
  };
}
