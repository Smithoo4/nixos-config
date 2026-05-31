# ISP Internet Monitoring

## Problem

Home internet connection (Rogers together with Shaw) intermittently stops working.
The ISP has not been able to identify or resolve the issue.

## Goal

- Capture objective performance data over time
- Identify patterns (latency spikes, packet loss, throughput drops)

---

## Outcome

Rogers identified and replaced damaged coaxial cable running to the house, which resolved the intermittent connectivity issues.

This monitoring module will remain active on `oneohm` for now to confirm the fix holds. It may be decommissioned in the future if monitoring is no longer needed or if `oneohm` is repurposed for another use.

---

## ISP Service Details

| Detail | Value |
|---|---|
| **ISP** | Rogers together with Shaw |
| **Plan** | Rogers Xfinity Internet Essentials 300 |
| **Download** | Up to 300 Mbps |
| **Upload** | Up to 200 Mbps |
| **Data Cap** | Unlimited |
| **Modem** | ISP-supplied (Rogers Xfinity Gateway), bridge mode |
| **Router** | TP-Link Archer AXE75 V1.0 (personal), SNMP not available on this model |

---

## Measurement

### 1. Router Metrics

- **Tool:** [`tplinkrouterc6u`](https://github.com/AlexandrErohin/TP-Link-Archer-C6U) Python library, called via a custom polling script
- **Telegraf Input:** `inputs.exec` — script outputs InfluxDB line protocol to stdout
- **Polling Interval:** 60 seconds
- **Note:** SNMP is not available on the Archer AXE75, so the router's web API is used instead. Each poll performs a full HTTP login/logout cycle. 60s was chosen to balance data resolution against session overhead (the router only supports one admin session at a time).

#### Router-Level Metrics (`router_status`)

| Metric | Type | Description |
|---|---|---|
| `router_status_cpu_usage` | float (0–1) | Router CPU utilization |
| `router_status_mem_usage` | float (0–1) | Router memory utilization |
| `router_status_wan_uptime` | integer (seconds) | WAN connection uptime — resets indicate ISP dropouts |
| `router_status_clients_total` | integer | Total connected clients |
| `router_status_wired_total` | integer | Wired clients |
| `router_status_wifi_clients_total` | integer | WiFi clients |
| `router_status_guest_clients_total` | integer | Guest network clients |
| `router_status_total_traffic` | integer (bytes) | Summed `traffic_usage` across all devices |

**Tags:** `host`

#### Per-Device Metrics (`router_device`)

| Metric | Type | Availability | Description |
|---|---|---|---|
| `router_device_traffic_usage` | integer (bytes) | All devices | Cumulative bytes — use `rate()` in Grafana for throughput |
| `router_device_signal` | integer (dBm) | WiFi only | RSSI signal strength |
| `router_device_packets_sent` | integer | WiFi only | Cumulative packets sent |
| `router_device_packets_received` | integer | WiFi only | Cumulative packets received |

**Tags:** `host`, `mac`, `hostname`, `type`

> **Note:** Devices with an empty hostname are tagged with their MAC address as a fallback. Three devices on the network report as `network device` — the `mac` tag ensures unique series.

---

### 2. Ping Test

- **Tool:** Telegraf built-in [`inputs.ping`](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/ping) plugin
- **Method:** `native` (Go-native ICMP, requires `CAP_NET_RAW`)
- **Polling Interval:** 60 seconds
- **Pings Per Cycle:** 5
- **Targets:**

| Target | Purpose |
|---|---|
| `192.168.0.1` | Router — rules out local network issues |
| `rogers.com` | ISP — first hop that matters |
| `1.1.1.1` | Cloudflare DNS — low-latency external baseline |
| `bing.com` | External baseline — DNS + routing |

#### Ping Metrics

| Metric | Type | Description |
|---|---|---|
| `ping_average_response_ms` | float | Mean round-trip time |
| `ping_minimum_response_ms` | float | Minimum RTT |
| `ping_maximum_response_ms` | float | Maximum RTT |
| `ping_percentile50_ms` | float | 50th percentile RTT |
| `ping_percentile95_ms` | float | 95th percentile RTT |
| `ping_percentile99_ms` | float | 99th percentile RTT |
| `ping_standard_deviation_ms` | float | RTT standard deviation |
| `ping_packets_transmitted` | integer | Pings sent |
| `ping_packets_received` | integer | Pings returned |
| `ping_percent_packet_loss` | float | Packet loss percentage |
| `ping_result_code` | integer | 0 = success, 1 = no host, 2 = error |
| `ping_ttl` | integer | Time to live |

**Tags:** `host`, `url`

---

### 3. Speed Test (Disabled)

- **Tool:** Telegraf built-in [`inputs.internet_speed`](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/internet_speed) plugin
- **Status:** Disabled — config kept at `speed-test.nix` but not imported

#### Why It Was Disabled

1. **Cached dead server:** With `cache = true`, the plugin locked onto a defunct Shaw Calgary server (`speedtest.cg.shawcable.net`) and never re-evaluated, causing every test to fail
2. **VM instability:** The speed test transfers hundreds of MB per run, which correlated with VM crashes on the Incus hypervisor (though not conclusively proven)
3. **DNS resolution failures:** During actual connectivity outages, the plugin couldn't resolve `speedtest.net` to discover servers, compounding the failure

The ping test and `router_status_wan_uptime` provide sufficient outage detection for the current use case. Speed testing can be revisited if throughput trending becomes a priority.

---

## Implementation Stack

| Component | Role | Config File |
|---|---|---|
| **NixOS** | Host OS (deployed to `oneohm` VM on Incus) | `hosts/oneohm/default.nix` |
| **Telegraf** | Data collection agent | `telegraf.nix` |
| **VictoriaMetrics** | Time-series database (single-node, 6-month retention) | `victoriametrics.nix` |
| **Grafana** | Visualization and dashboards | `grafana.nix` |
| **sops-nix** | Secrets management (router credentials, Grafana admin password) | Referenced in `router-metrics.nix`, `grafana.nix` |
| **Nginx (Angie)** | Reverse proxy with TLS (ACME/DuckDNS) | `modules/reverse-proxy/` |

### Module Structure

```
modules/ISP-monitor/
├── dashboards/
│   └── isp-health-overview.json    # Exported from Grafana
├── default.nix                     # Imports — toggle features here
├── grafana.nix                     # Grafana + datasource + dashboard provisioning
├── ping.nix                        # Ping test (inputs.ping + CAP_NET_RAW)
├── router-metrics.nix              # Router polling (tplinkrouterc6u + sops + inputs.exec)
├── speed-test.nix                  # Speed test (disabled — not imported)
├── telegraf.nix                    # Base Telegraf config (agent, output, internal)
└── victoriametrics.nix             # VictoriaMetrics + reverse proxy vhost
```

### Access

| Service | URL |
|---|---|
| Grafana | `https://grafana.oneohm.duckdns.org/` |
| VictoriaMetrics UI | `https://vmui.oneohm.duckdns.org/vmui/` |

---

## Grafana Dashboard Workflow

Dashboards are provisioned declaratively from JSON files in the `dashboards/` directory. To update a dashboard:

1. **Edit** the dashboard in the Grafana UI
2. **Save** changes in Grafana (this saves to the Grafana database, not your repo)
3. **Export:** Dashboard → Share → Export → toggle **Export for sharing externally** → **Save to file**
4. **Replace** the JSON file in `modules/ISP-monitor/dashboards/`
5. **Commit and push** to the repo
6. **Rebuild:** `nixos-rebuild switch` — Grafana picks up the updated JSON on restart

> **Note:** Provisioned dashboards appear as read-only in the Grafana UI. To edit, make changes and re-export — the source of truth is always the JSON in the repo.

---

## Future Considerations

- [ ] **TSDB comparison:** Evaluate InfluxDB (v2 or v3) and/or Prometheus as alternatives to VictoriaMetrics
- [ ] **Alerting:** Add email or webhook notifications for sustained packet loss or WAN uptime resets
- [ ] **SNMP-capable router:** If the Archer AXE75 is replaced, look for a router with SNMP support for direct Telegraf integration via `inputs.snmp` — eliminating the custom polling script
- [ ] **Speed test revisit:** Re-enable with a lighter approach (e.g. Ookla CLI via `inputs.exec` with reduced thread count) if throughput trending becomes a priority
- [ ] **Per-client throughput dashboards:** Use `rate(router_device_traffic_usage[5m])` derivatives for detailed per-device bandwidth analysis
- [ ] **Dashboard version control:** Export dashboard JSON after significant changes to keep the repo in sync

---

## References

| Resource | Link |
|---|---|
| VictoriaMetrics docs | https://docs.victoriametrics.com/ |
| VictoriaMetrics NixOS options | `services.victoriametrics` in nixpkgs |
| Telegraf docs | https://docs.influxdata.com/telegraf/ |
| Telegraf `inputs.ping` | https://github.com/influxdata/telegraf/tree/master/plugins/inputs/ping |
| Telegraf `inputs.internet_speed` | https://github.com/influxdata/telegraf/tree/master/plugins/inputs/internet_speed |
| Telegraf `inputs.exec` | https://github.com/influxdata/telegraf/tree/master/plugins/inputs/exec |
| Telegraf `outputs.influxdb` | https://github.com/influxdata/telegraf/tree/master/plugins/outputs/influxdb |
| tplinkrouterc6u | https://github.com/AlexandrErohin/TP-Link-Archer-C6U |
| Grafana docs | https://grafana.com/docs/grafana/latest/ |
| Grafana NixOS options | `services.grafana` in nixpkgs |
| sops-nix | https://github.com/Mic92/sops-nix |
| Archer AXE75 | https://www.tp-link.com/us/home-networking/wifi-router/archer-axe75/ |
| nixos-config repo | https://github.com/Smithoo4/nixos-config |
