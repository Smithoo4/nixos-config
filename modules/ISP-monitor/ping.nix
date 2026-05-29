{ ... }:
{
  # Ping test — connectivity, latency, packet loss
  services.telegraf.extraConfig.inputs.ping = {
    urls = [
      "192.168.0.1"
      "rogers.com"
      "1.1.1.1"
      "bing.com"
    ];
    method = "native";
    count = 5;
    ping_interval = 1.0;
    deadline = 10;
    percentiles = [
      50
      95
      99
    ];
  };

  # Grant CAP_NET_RAW for native ping
  systemd.services.telegraf.serviceConfig = {
    CapabilityBoundingSet = [ "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_RAW" ];
  };
}
