# ISP Internet Monitoring

## Problem

Home internet connection (Rogers together with Shaw) intermittently stops working.
The ISP has not been able to identify or resolve the issue.

## Goal

- Capture objective performance data over time
- Identify patterns (latency spikes, packet loss, throughput drops)
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

### 1. Router Metrics (Archer AXE75)

- **Tool:** [`tplinkrouterc6u`](https://github.com/AlexandrErohin/TP-Link-Archer-C6U)
  - **AXE75 V1:** Confirmed supported
  - **SNMP:** Not available on this model
- **Purpose:** Trend metrics such as `down_speed`, `up_speed`, `tx_rate`, `rx_rate`, etc. to see if there is any correlation with data usage and if network congestion is an issue.


### 2. Ping Test

- **Tool:** Ping command to `rogers.com`
- **Purpose:** Connectivity validation, latency trending, packet loss detection

### 3. Speed Test

- **Tool:** [OOKLA Speedtest CLI](https://www.speedtest.net/apps/cli) or [fast-cli](https://github.com/sindresorhus/fast-cli#readme)
  - OOKLA Speedtest is recommended as Rogers suggests their [SPEEDTEST](https://speedtest.shaw.ca/) which is just a rebranding of the OOKLA tool
- **Purpose:** Measure actual throughput vs plan speeds (300 / 200 Mbps)

---

## Builds Monitoring with [NixOS](https://nixos.org/)

- Currently learning NixOS and this gives an opportunity to apply knowledge
- Public GitHub repository of my [nixos-config](https://github.com/Smithoo4/nixos-config) and a summary of all the configuration: [nixos_config.txt](https://raw.githubusercontent.com/Smithoo4/nixos-config/refs/heads/main/nixos_config.txt)
- Place the configuration for the monitoring at `modules/ISP-monitor`
- Deploy to host `oneohm` with `fourohm` being a backup to test alternate options if needed
- No new ports are to be opened in the firewall; any webUI or dashboard is to be reverse proxied with TLS

---

## Roadmap & Implementation

### Phase 1: Infrastructure — Telegraf + VictoriaMetrics

Stand up the core data collection and storage infrastructure.

- [ ] Enable and configure Telegraf
- [ ] Enable and configure VictoriaMetrics
- [ ] Confirm Telegraf can write to VictoriaMetrics
- [ ] Validate data is being stored and queryable

### Phase 2: Router Metrics (End-to-End Validation)

Use router metrics as the first data source to prove the full pipeline from collection through to storage.

- [ ] Configure router metrics collection via `tplinkrouterc6u`
- [ ] Identify key metrics to track (e.g. `down_speed`, `up_speed`, `tx_rate`, `rx_rate`)
- [ ] Validate data flows end-to-end: collection → storage → queryable
- [ ] Confirm data quality (timestamps, field types, no gaps)

### Phase 3: Ping Test + Speed Test

Add the remaining data sources to a known-good pipeline.

- [ ] Configure Ping Test and identify key metrics
- [ ] Configure Speed Test and identify key metrics
- [ ] Validate both data sources flow end-to-end
- [ ] Confirm all three measurement types are collecting reliably

### Phase 4: Visualization — Grafana

Introduce visualization to validate data quality and begin trending before adding comparison complexity.

- [ ] Enable Grafana
- [ ] Add VictoriaMetrics as a data source
- [ ] Build an ISP Health Overview dashboard covering all three measurements
- [ ] Visually confirm data completeness and correctness

### Phase 5: TSDB Comparison — InfluxDB v2 + Prometheus

With all metrics stable and validated, introduce the additional TSDBs for side-by-side comparison.

- [ ] Enable and configure InfluxDB v2
- [ ] Enable and configure Prometheus
- [ ] Connect both to Telegraf alongside VictoriaMetrics
- [ ] Add InfluxDB v2 and Prometheus as Grafana data sources
- [ ] Build identical ISP Health Overview dashboards for each TSDB
- [ ] Confirm all three TSDBs are ingesting the same complete dataset

### Phase 6: Evaluation & Decision

Run all three TSDBs in parallel for a defined evaluation period and select one for long-term use.

#### Evaluation Period

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

### Phase 7: Optional Enhancements

- [ ] Evaluate [vmagent](https://docs.victoriametrics.com/victoriametrics/vmagent/) for advanced ingestion scenarios
- [ ] Add email/webhook alert notifications
- [ ] Extend monitoring to additional hosts or services
- [ ] Build detailed per-client throughput dashboards
- [ ] Export dashboard JSON for version control in `dashboards/`

---

## Fallback: Alternative Data Collection

If Telegraf proves unsuitable for any of the data collection tasks, an alternative approach using **systemd timers and custom scripts** can be considered. This would require revisiting Phase 1 and may impact TSDB output configurations in subsequent phases. Evaluate on a per-measurement basis — it is possible to use Telegraf for some inputs and scripts for others.

---

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
