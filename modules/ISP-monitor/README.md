# ISP Internet Monitoring

## Problem

Home internet connection (Rogers together with Shaw) intermittently stops working.
The ISP has not been able to identify or resolve the issue.

## Goal

- Capture objective performance data over time
- Identify patterns (latency spikes, packet loss, throughput drops)
- Provide evidence to support escalation with ISP
- Learn and evaluate modern monitoring stacks on NixOS

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

## Measurement (Planned)

### 1. Ping Test

- **Tool:** Ping command to `rogers.com`
- **Purpose:** Connectivity validation, latency trending, packet loss detection

### 2. Speed Test

- **Tool:** [OOKLA Speedtest CLI](https://www.speedtest.net/apps/cli) or [fast-cli](https://github.com/sindresorhus/fast-cli#readme)
  - OOKLA Speedtest is recommended as Roger suggests there [SPEEDTEST](https://speedtest.shaw.ca/) which is just a rebranding of OOKLA tool
- **Purpose:** Measure actual throughput vs plan speeds (300 / 200 Mbps)

### 3. Router Metrics (Archer AXE75)

- **Tool:** [`tplinkrouterc6u`](https://github.com/AlexandrErohin/TP-Link-Archer-C6U)
  - **AXE75 V1:** Confirmed supported
  - **SNMP:** Not available on this model
  - **Purpose:** Trend metrics such as `down_speed`, `up_speed`, `tx_rate`, `rx_rate`, etc. so see if there is any correlation with data usages and if network congestion is an issue.

## Builds Monitoring with [NixOS](https://nixos.org/)
- Currently learning Nixos and this give an opportunity to apply knowledge
- Public GitHub repository of my [nixos-confg](https://github.com/Smithoo4/nixos-config) and a summary of the all the configuration: [nixos_config.txt](https://raw.githubusercontent.com/Smithoo4/nixos-config/refs/heads/main/nixos_config.txt)
- Place the configuration for the monitoring at `modules/ISP-monitor`
- Deploy to host `oneohm` with `fourohm` being a backup to test alternate options if needed.
- No new port are to be open in the firewall, any webUI or dashboard are to be reverse proxy with tls

## Roadmap & Implementation

### Phase 1: Data Collection

- [ ] Set up [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) – preferred
  - [ ] Enable Telegraf
  - [ ] Configure **Ping Test** and identify Key Metrics
  - [ ] Configure **Speed Test** and identify Key Metrics
  - [ ] Configure **Router Metrics** and identify Key Metrics
- [ ] Set up Systemd Unit and scripts for date collection – backup if issues arise with Telegraf
  - [ ] Configure **Ping Test** and identify Key Metrics
  - [ ] Configure **Speed Test** and identify Key Metrics
  - [ ] Configure **Router Metrics** and identify Key Metrics

### Phase 2: Data Storage (TSDB)

*There are three interesting options for this, if time permits all three will be run in parallels to learn each*

- [ ] [VictoriaMetrics](https://github.com/victoriametrics/VictoriaMetrics)
    - [ ] Enable
    - [ ] Connect to Data Collection (telegraf or systemd units and scripts)
- [ ] [InfluxDB v2](https://docs.influxdata.com/influxdb/v2/)
    - [ ] Enable
    - [ ] Connect to Data Collection (telegraf or systemd units and scripts)
- [ ] [Prometheus](https://prometheus.io/docs/introduction/overview/)
    - [ ] Enable
    - [ ] Connect to Data Collection (telegraf or systemd units and scripts)

### Phase 4: Visualization & Access (Grafana)

- [ ] Enable [Grafana](https://github.com/grafana/grafana)
- [ ] Add data sources
  - [ ] VictoriaMetrics
  - [ ] InfluxDB V2
  - [ ] Prometheus
- [ ] Build ISP Health Overview dashboard (one per TSDB, identical layout)

### Phase 5: Evaluation & Decision

#### Data Collection Period

- [ ] Run all three TSDBs for at least **2–4 weeks** with identical data

#### Evaluation Criteria

| Criteria | How to Measure |
|---|---|
| **RAM usage** | `systemctl status` or `ps aux` per component |
| **Disk usage** | `du -sh /var/lib/{victoriametrics,prometheus,influxdb2}` |
| **Query speed** | Time a full dashboard load (browser dev tools → network tab) |
| **Config complexity** | Lines of Nix code per stack |
| **Data completeness** | Count data points per TSDB over the same time period |
| **Query language UX** | Subjective — which feels most natural to write and debug? |
| **Operational friction** | Subjective — setup effort, maintenance, and debugging experience |

#### Final Decision

- [ ] Select TSDB for long-term use
- [ ] Decommission non-selected TSDBs
- [ ] Document rationale

### Phase 6: Optional Enhancements

- [ ] Evaluate [vmagent](https://docs.victoriametrics.com/victoriametrics/vmagent/) for advanced ingestion scenarios
- [ ] Add email/webhook alert notifications
- [ ] Extend monitoring to additional hosts or services
- [ ] Build detailed per-client throughput dashboards
- [ ] Export dashboard JSON for version control in `dashboards/`

## References

| Resource | Link |
|---|---|
| VictoriaMetrics docs | https://docs.victoriametrics.com/ |
| VictoriaMetrics NixOS options | `services.victoriametrics` in nixpkgs |
| InfluxDB v2 docs | https://docs.influxdata.com/influxdb/v2/ |
| InfluxDB v2 NixOS options | `services.influxdb2` in nixpkgs |
| Prometheus docs | https://prometheus.io/docs/ |
| Prometheus NixOS options | `services.prometheus` in nixpkgs |
| Telegraf docs | https://docs.influxdata.com/telegraf/ |
| Telegraf `inputs.ping` | https://github.com/influxdata/telegraf/tree/master/plugins/inputs/ping |
| Telegraf `inputs.internet_speed` | https://github.com/influxdata/telegraf/tree/master/plugins/inputs/internet_speed |
| Telegraf `inputs.exec` | https://github.com/influxdata/telegraf/tree/master/plugins/inputs/exec |
| Telegraf `outputs.influxdb` | https://github.com/influxdata/telegraf/tree/master/plugins/outputs/influxdb |
| Telegraf `outputs.influxdb_v2` | https://github.com/influxdata/telegraf/tree/master/plugins/outputs/influxdb_v2 |
| Telegraf `outputs.prometheus_client` | https://github.com/influxdata/telegraf/tree/master/plugins/outputs/prometheus_client |
| tplinkrouterc6u | https://github.com/AlexandrErohin/TP-Link-Archer-C6U |
| Grafana docs | https://grafana.com/docs/grafana/latest/ |
| Grafana NixOS options | `services.grafana` in nixpkgs |
| sops-nix | https://github.com/Mic92/sops-nix |
| Rogers Internet Plans | https://www.rogers.com/internet/plans |
| Archer AXE75 | https://www.tp-link.com/us/home-networking/wifi-router/archer-axe75/ |
