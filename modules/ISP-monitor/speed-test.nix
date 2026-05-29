{ ... }:
{
  # Speed test — throughput, latency, jitter, packet loss (via speedtest.net)
  services.telegraf.extraConfig.inputs.internet_speed = {
    interval = "30m";
    memory_saving_mode = true;
    cache = false;
    test_mode = "single";
  };
}
