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
| **Connection** | Fibre |
| **Modem** | ISP-supplied (Rogers Xfinity Gateway), bridge mode |
| **Router** | TP-Link Archer AXE75 V1.0 (personal) |

---

## Network Topology

```
Internet
   │
   ▼
ISP Modem (Bridge Mode)
   │
   ▼
TP-Link Archer AXE75 V1.0
   │
   ├── LAN Clients
   │
   ├── oneohm (NixOS VM) → Primary test host
   │
   └── fourohm (NixOS VM) → Optional / future testing
```

---

## Stack Architecture (4 Layers)

| # | Layer | Purpose | Options | Decision? |
|---|---|---|---|---|
| **1** | **Data Sources** | What you measure | Ping · Speedtest · Router (AXE75) | Fixed |
| **2** | **Collection** | How data is gathered and delivered to storage | Telegraf · (fallback: systemd + scripts) | 🔥 Key decision |
| **3** | **Storage (TSDB)** | Where time-series data lives | VictoriaMetrics · InfluxDB v2 · Prometheus | 🔥 Key decision |
| **4** | **Presentation & Access** | How you view, alert, and securely access | Grafana + Nginx (TLS) | Fixed |

---

## Data Sources (Layer 1)

### 1. Ping Test

- **Target:** `rogers.com`
- **Purpose:** Connectivity validation, latency trending, packet loss detection
- **Key Metrics:** `average_response_ms`, `minimum_response_ms`, `maximum_response_ms`,
  `percent_packet_loss`, `result_code`

### 2. Speed Test

- **Purpose:** Measure actual throughput vs plan speeds (300 / 200 Mbps)
- **Key Metrics:** `download` (Mbps), `upload` (Mbps), `latency` (ms), `jitter`, `packet_loss`
- **Note:** Each test consumes ~300–600 MB — schedule conservatively (~45 min)

### 3. Router Metrics (Archer AXE75)

- **Tool:** [`tplinkrouterc6u`](https://github.com/AlexandrErohin/TP-Link-Archer-C6U)
- **AXE75 V1:** Confirmed supported
- **SNMP:** Not available on this model
- **Key Metrics (Status):** `cpu_usage`, `mem_usage`, `wan_ipv4_uptime`, `clients_total`,
  `wired_total`, `wifi_clients_total`
- **Key Metrics (Device):** `down_speed`, `up_speed`, `tx_rate`, `rx_rate` (per client)

---

## Module File Structure

```
modules/ISP-monitor/
├── README.md                        # This file
│
├── victoriametrics/
│   ├── default.nix                  # VictoriaMetrics TSDB config
│   ├── telegraf-output.nix          # outputs.influxdb → VM
│   └── grafana-datasource.nix       # Prometheus-type datasource → :8428
│
├── influxdb/
│   ├── default.nix                  # InfluxDB v2 TSDB config
│   ├── telegraf-output.nix          # outputs.influxdb_v2 → InfluxDB
│   └── grafana-datasource.nix       # InfluxDB datasource
│
├── prometheus/
│   ├── default.nix                  # Prometheus TSDB config
│   ├── telegraf-output.nix          # outputs.prometheus_client
│   └── grafana-datasource.nix       # Prometheus datasource
│
└── shared/
    ├── telegraf.nix                  # Telegraf agent + all inputs
    ├── grafana.nix                   # Grafana base config
    ├── nginx.nix                     # Reverse proxy virtual hosts
    ├── secrets.nix                   # sops-nix integration
    ├── scripts/
    └── dashboards/
        └── isp-health-overview.json # Provisioned Grafana dashboard
```

---

## Roadmap

---

### Phase 1: Data Sources (Layer 1) ✅

- [x] Identify data sources (ping, speedtest, router)
- [x] Confirm Archer AXE75 V1 supported by `tplinkrouterc6u`
- [x] Define key metrics for each source
- [x] Evaluate monitoring stacks
- [x] Select testing order: VictoriaMetrics → InfluxDB v2 → Prometheus

---

### Phase 2: Collection (Layer 2)

Build and validate the collection layer independently — no TSDB required.

#### Prerequisites

- [ ] Set up `sops-nix` for router credentials (AXE75 admin password)
- [ ] Verify manual authentication to AXE75 API

> ⚠️ **Issue:** Router credentials are required to fully test all inputs.
> Set up `sops-nix` before starting Phase 2, not in Phase 3.

#### Telegraf Setup

- [ ] Enable Telegraf (`services.telegraf`)
- [ ] Configure `inputs.ping`
  - Target: `rogers.com`
  - Interval: `10s`
  - Count: `3`
  - Method: `native`
- [ ] Configure `inputs.internet_speed`
  - Interval: `45m` (avoid `:00`/`:30` marks)
  - `memory_saving_mode = false`
- [ ] Configure `inputs.exec` (router polling script)
  - Command: `router-poll.py`
  - Interval: `30s`
  - `data_format = "influx"`
  - Timeout: `15s`

> ⚠️ **Issue: `inputs.ping` requires `CAP_NET_RAW`**
>
> Telegraf runs as the `telegraf` user. Native ICMP requires the `CAP_NET_RAW`
> Linux capability. Without it, ping will fail with a permissions error.
>
> **Fix:** Add to NixOS config:
> ```nix
> systemd.services.telegraf.serviceConfig.AmbientCapabilities = [
>   "CAP_NET_RAW"
> ];
> ```

> ⚠️ **Issue: `tplinkrouterc6u` is NOT in nixpkgs**
>
> You'll need to package it as a Nix derivation (`buildPythonPackage` from PyPI)
> or use a Python venv wrapper. Dependencies include `requests` and `pycryptodome`.

> ℹ️ **Note: `inputs.internet_speed` accuracy**
>
> Uses `speedtest-go` (FOSS), not the Ookla CLI. May select different servers and
> produce slightly different results vs `speedtest.shaw.ca`. During testing, compare
> a few runs against a manual browser test. Use `server_id_include` to pin a specific
> server if results are consistently >20% off.

> ℹ️ **Note:** `telegraf --test --input-filter internet_speed` runs a REAL speedtest
> (30–60 seconds, 300–600 MB of bandwidth). Don't run it in a loop.

#### Validation (No TSDB Needed)

- [ ] Test each input independently:
  ```bash
  telegraf --test --input-filter ping
  telegraf --test --input-filter internet_speed
  telegraf --test --input-filter exec
  ```
- [ ] Verify metric names, tags, and values are correct
- [ ] Confirm all three inputs collect successfully in a single run:
  ```bash
  telegraf --test
  ```

#### Decision Gate

> **If all inputs work cleanly → proceed to Phase 3 with Telegraf.**
>
> Only investigate systemd + scripts if:
> - [ ] Telegraf config becomes messy/unreadable in Nix
> - [ ] Plugins don't behave reliably
> - [ ] Router integration via `inputs.exec` is clunky
> - [ ] Debugging becomes painful
>
> Otherwise: **do not spend time on systemd + scripts.**

---

### Phase 3: Storage (Layer 3)

Deploy all three TSDBs on oneohm. Connect Telegraf fan-out outputs.

> ⚠️ **Resource Check:** Running all 3 TSDBs + Telegraf + Grafana simultaneously
> requires ~1–1.5 GB RAM. Verify oneohm has **≥2 GB RAM** before proceeding.
> If constrained, stagger the experiments (deploy one at a time).

#### Phase 3a: VictoriaMetrics (Primary Candidate)

- [ ] Enable VictoriaMetrics (`services.victoriametrics`)
  - `-retentionPeriod=12` (12 months)
- [ ] Test manually with curl:
  ```bash
  # Insert test metric
  curl -d 'test_metric value=42' http://localhost:8428/write

  # Query it back
  curl 'http://localhost:8428/api/v1/query?query=test_metric'
  ```
- [ ] Configure Telegraf output:
  ```toml
  [[outputs.influxdb]]
    urls = ["http://localhost:8428"]
    database = "isp"
    skip_database_creation = true
  ```
- [ ] Verify Telegraf → VictoriaMetrics data flow

#### Phase 3b: InfluxDB v2 (Experimental)

- [ ] Enable InfluxDB v2 (`services.influxdb2`)
- [ ] Run initial setup (org, bucket, API token):
  ```bash
  influx setup \
    --org isp-monitor \
    --bucket isp \
    --username admin \
    --password <secure-password> \
    --force
  ```
- [ ] Store API token via `sops-nix`
- [ ] Test manually with curl:
  ```bash
  curl --header "Authorization: Token $INFLUX_TOKEN" \
    --data-raw 'test_metric value=42' \
    "http://localhost:8086/api/v2/write?org=isp-monitor&bucket=isp"
  ```
- [ ] Configure Telegraf output:
  ```toml
  [[outputs.influxdb_v2]]
    urls = ["http://localhost:8086"]
    token = "${INFLUX_TOKEN}"
    organization = "isp-monitor"
    bucket = "isp"
  ```
- [ ] Verify Telegraf → InfluxDB v2 data flow

> ℹ️ **Note:** InfluxDB v2 uses the **Flux** query language, which is deprecated
> and will not be carried forward to v3. This is acceptable for a learning
> exercise but reinforces that InfluxDB v2 is not a long-term choice.

#### Phase 3c: Prometheus (Industry Baseline)

- [ ] Enable Prometheus (`services.prometheus`)
  - `--storage.tsdb.retention.time=365d`
- [ ] Configure Telegraf output:
  ```toml
  [[outputs.prometheus_client]]
    listen = ":9273"
    expiration_interval = "50m"
    export_timestamp = true
  ```
- [ ] Configure Prometheus scrape target:
  ```yaml
  scrape_configs:
    - job_name: 'telegraf'
      scrape_interval: 10s
      static_configs:
        - targets: ['localhost:9273']
  ```
- [ ] Verify Telegraf → Prometheus data flow

> 🔴 **CRITICAL: Prometheus scrape timing**
>
> Without `export_timestamp = true`, Prometheus applies its own timestamp at scrape
> time. This creates timing mismatches vs VictoriaMetrics/InfluxDB, making your
> comparison invalid.

> 🔴 **CRITICAL: Prometheus metric expiration**
>
> The `outputs.prometheus_client` default `expiration_interval` is `60s`. Your
> speedtest runs every 45 minutes. Without increasing this to `50m`, speedtest
> metrics will expire before Prometheus scrapes them — **Prometheus will never
> capture speedtest data.**

#### Phase 3 Verification

- [ ] All three TSDBs receiving identical data
- [ ] Query the same metric from each TSDB and compare values/timestamps
- [ ] No data gaps in any TSDB

---

### Phase 4: Visualization & Access (Layer 4)

#### Grafana

- [ ] Enable Grafana (`services.grafana`)
- [ ] Add data sources:
  - VictoriaMetrics (type: Prometheus, URL: `http://localhost:8428`)
  - InfluxDB v2 (type: InfluxDB, URL: `http://localhost:8086`, Flux query language)
  - Prometheus (type: Prometheus, URL: `http://localhost:9090`)
- [ ] Build **ISP Health Overview** dashboard (one per TSDB, identical layout):

| Panel | Type | Metric |
|---|---|---|
| Ping Latency | Time Series | `average_response_ms` |
| Packet Loss | Stat / Bar | `percent_packet_loss` |
| Download Speed vs Plan | Time Series | `download` + 300 Mbps threshold |
| Upload Speed vs Plan | Time Series | `upload` + 200 Mbps threshold |
| Router CPU | Gauge | `cpu_usage` |
| Router Memory | Gauge | `mem_usage` |
| WAN Uptime | Stat | `wan_ipv4_uptime` |
| Connected Clients | Stat | `clients_total` |
| Per-Device Throughput | Table / Time Series | `down_speed`, `up_speed` |

> ⚠️ **Note: Dashboard queries differ per TSDB**
>
> VictoriaMetrics and Prometheus share **identical PromQL/MetricsQL queries**.
> InfluxDB v2 requires completely **rewritten Flux queries**. This is expected
> additional effort for the InfluxDB experiment.

#### Alerting

- [ ] Configure Grafana alert rules:
  - Packet loss > 50% for 2 consecutive checks
  - Ping average > 200 ms for 5 minutes
  - Download speed < 150 Mbps (50% of plan) on 2 consecutive tests
  - WAN uptime resets (modem/ISP reconnect)
- [ ] Optional: notification channel (email, webhook, Discord)

#### Nginx Reverse Proxy (TLS)

- [ ] Add Grafana virtual host to nginx reverse proxy
  - Proxy to `http://127.0.0.1:3000`
  - TLS via existing cert
- [ ] Optional: proxy VictoriaMetrics UI (`http://127.0.0.1:8428`)
- [ ] Ensure `:3000`, `:8086`, `:8428`, `:9090` are **NOT** exposed directly
- [ ] No new firewall ports opened — all traffic through existing HTTPS `:443`

> ⚠️ **Issue: Grafana behind Nginx requires WebSocket support**
>
> Grafana Live uses WebSockets. Your nginx config needs:
> ```nix
> locations."/" = {
>   proxyPass = "http://127.0.0.1:3000";
>   proxyWebsockets = true;
> };
> ```
>
> Also set in Grafana config:
> ```nix
> services.grafana.settings.server = {
>   domain = "grafana.yourdomain.com";
>   root_url = "https://grafana.yourdomain.com/";
> };
> ```

---

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

#### InfluxDB Experiment Exit Criteria

If **any** of the following are true → drop InfluxDB:
- [ ] Significantly higher resource usage vs VictoriaMetrics
- [ ] Flux query language is painful to use
- [ ] Setup/auth complexity not justified
- [ ] No clear advantage over VictoriaMetrics or Prometheus

#### Final Decision

- [ ] Select TSDB for long-term use
- [ ] Decommission non-selected TSDBs
- [ ] Document rationale

---

### Phase 6: Optional Enhancements

- [ ] Evaluate `vmagent` for advanced ingestion scenarios
- [ ] Add email/webhook alert notifications
- [ ] Extend monitoring to additional hosts or services
- [ ] Build detailed per-client throughput dashboards
- [ ] Export dashboard JSON for version control in `dashboards/`

---

## fourohm

Not currently planned for active use. Reserved for:
- Future testing of alternative collection approaches (systemd + scripts)
- Testing configuration changes before applying to oneohm
- Expanding monitoring scope later

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
