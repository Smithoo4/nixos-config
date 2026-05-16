# NixOS Home Server Configuration

This repository contains a personal NixOS configuration for building and managing home servers using flakes.

## Status

Active Development — currently being refined, expanded, and tested.

---

## Hosts

| Host | Status | Hardware | Purpose |
| :--- | :--- | :--- | :--- |
| **oneohm** | Active Development | VM | Testing and development |
| **twoohm** | Planned | Raspberry Pi 4 | Testing and development |
| **threeohm** | Planned | TBD | TBD |
| **fourohm** | Active Development | VM | Testing and development |
| **fiveohm** | Planned | TBD | TBD |

---

## Roadmap & Implementation

### Phase 1: Core System & Infrastructure
- [x] Initial installation guide [here](https://github.com/Smithoo4/one-day-i-should-start-a-blog/blob/main/2026%2003%2028%20-%20nixos-homeserver-install-guide.md)
    - [x] Install NixOS from scratch (Flakes + [Disko](https://github.com/nix-community/disko))
    - [x] Home Manager and Git integration
    - [x] Secrets Management via [SOPS-Nix](https://github.com/mic92/sops-nix)
- [x] Refactor configuration for modular, multi-host support
- [x] msmtp setup
- [x] S.M.A.R.T disk monitoring with email notifications via `smartd`
- [X] Automatic updates
    - [X] Central `flake.lock` update for all hosts vis [update-flake-lock](https://github.com/DeterminateSystems/update-flake-lock)
    - [X] Schedule auto updates
    - [X] Email notifications of failed update or warnings

### Phase 2: Reverse Proxy
*Goal: Evaluate Caddy and Nginx.*
- [X] Set up [Caddy](https://caddyserver.com/)
    - [X] ACME DNS challenge using [DuckDNS](https://www.duckdns.org/domains)
    - [X] Enable HTTP/3
    - [X] Hardened proxy connections
    - [X] Strict host matching and drop unmatched requests (e.g. no connecting unless it matches an FQDN)
    - [X]  Rate limiting (plugin-based)
    - [X] Serve a test page
    - [X] Template for proxying future services
- [X] Set up [Nginx](https://nginx.org/)
    - [X] ACME DNS challenge using [DuckDNS](https://www.duckdns.org/domains)
    - [X] Enable HTTP/3
    - [X] Hardened proxy connections
    - [X] Strict host matching and drop unmatched requests (e.g. no connecting unless it matches an FQDN)
    - [X] Rate limiting
    - [X] Serve a test page
    - [X] Template for proxying future services
    - [X] Test [Angie](https://github.com/webserver-llc/angie) (e.g. `services.nginx.package = pkgs.angie`)

### Decision: Standardize on Nginx (Angie). Caddy evaluation discontinued.

Caddy was evaluated as a modern alternative reverse proxy and shows strong design advantages, particularly around simplicity and native integrations (e.g., ACME and middleware-based security models like CrowdSec). However, it introduces additional complexity in this environment:

- Requires compiling a custom build for DNS-01 ACME challenges (DuckDNS plugin)
- Rate limiting also requires a plugin build, increasing maintenance overhead  
  - This may be unnecessary if relying fully on CrowdSec, which provides higher-level behavioural protection instead of per-request limiting
- Fail2Ban support for Caddy is limited, with no widely adopted or maintained filters/jails compared to the mature ecosystem available for Nginx

CrowdSec appears to align well with Caddy’s architecture (middleware and external decision engines), potentially making it a strong long-term pairing. However, the NixOS ecosystem (modules, packaging, and integrations) is not yet production-ready for this approach.

In contrast, Nginx offers:

- Fully declarative ACME DNS-01 via `lego` (no custom builds)
- Native rate limiting without additional modules
- Mature and well-documented Fail2Ban integration
- Strong NixOS module support and reproducibility

Caddy has been **retained in the repository for reference only** but is no longer being actively developed or deployed.

There were no significant differences observed between Nginx mainline and Angie during testing. Angie will continue to be used, with potential future exploration of its built-in metrics and statistics capabilities (e.g. status endpoints and monitoring integration), which may support observability improvements.

## Phase 3: Security

- [ ] Set up [CrowdSec](https://www.crowdsec.net/) — *on hold, NixOS module has known issues ([nixpkgs#446307](https://github.com/NixOS/nixpkgs/pull/446307))*
    - [ ] SSH protection
    - [ ] Nginx protection
        - [ ] Block repeated requests that don't match an FQDN (IP-only / unknown SNI)
    - [ ] Evaluate [CrowdSec Console](https://app.crowdsec.net/) — cloud monitoring & automation dashboard
    - [ ] Evaluate [Metabase](https://www.metabase.com/) — local self-hosted dashboard (`cscli dashboard setup`)

- [ ] Set up [Fail2Ban](https://github.com/fail2ban/fail2ban) — *selected as the primary protection mechanism due to CrowdSec limitations on NixOS*
    - [X] SSH protection
    - [X] Nginx protection
        - [X] Block repeated requests that don't match an FQDN (IP-only / unknown SNI)
        - [X] Block on rate limiting
        - [ ] Block web traffic (including HTTP/3 / QUIC) via firewall *(not yet implemented)*

### Decision: Adopt Fail2Ban as Primary Control; CrowdSec Deferred

CrowdSec was evaluated as a modern, collaborative security platform with strong architectural advantages over Fail2Ban, particularly in its ability to make behaviour-based decisions and share threat intelligence across instances.

However, it is currently not suitable for production use in this NixOS environment due to several limitations:

- The NixOS module and packaging are still immature and have known issues ([nixpkgs#446307](https://github.com/NixOS/nixpkgs/pull/446307))
- Integration patterns (bouncers, firewall hooks, service bindings) are not well-defined or documented for NixOS
- Reverse proxy integrations (Nginx/Caddy) require additional manual work and lack clear, reproducible configurations
- Operational complexity is significantly higher compared to Fail2Ban, especially in a declarative setup

While CrowdSec appears to align better with modern reverse proxies (particularly Caddy), the surrounding ecosystem on NixOS is not yet at a level that supports reliable, low-maintenance deployment.

As a result, **Fail2Ban has been selected as the primary security control** for this environment:

- Well-supported on NixOS with stable modules
- Simple, transparent, and fully declarative
- Tight integration with Nginx logs and systemd journald
- Sufficient for current threat model (bots, scanners, opportunistic abuse)

CrowdSec development and NixOS integration progress will continue to be monitored.  
Thanks to everyone contributing to upstream development and NixOS support — this is an area with strong potential, and future re-evaluation is planned once the ecosystem matures.
  
### Phase 4: Deployment & Documentation
- [X] Store configuration exclusively in GitHub (no local persistence)
- [ ] Comprehensive deployment tutorial
    - [X] Install second host (`fourohm`) pulling config from GitHub
    - [X] Evaluate [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
    - [X] Cover installing on raspberry pi 4
    - [ ] Cover installing on an oracle arm VPS

### Phase 5: Ideas & Modular Exploration (Optional)
 - [ ] Evaluate Dynamic DNS using another provider
        - [DYNU](https://www.dynu.com/en-US): I've used it before, and it has lots of nice features plus a wider selection of domain names.
- [ ] Evaluate [flake-parts](https://github.com/hercules-ci/flake-parts)
- [ ] Refactor configuration layout based on lessons learned
- [ ] Static ip address on local network
    - [ ] IPv4
    - [ ] IPv6
- [ ] Dynamic dns Using DuckDNS/DYNU on Public Network
     - [ ] IP address Update script vs [ddns-updater](https://github.com/qdm12/ddns-updater) vs [ddclirnt](https://ddclient.net/) 
     - [ ] IPv4 with NAT Port Forwarding
     - [ ] IPv6

### Phase 6: Authentication & SSO
*Goal: Evaluate alternatives to Authelia + lldap.*
- [ ] Evaluate and deploy SSO
    - [ ] Options: Kanidm, Keycloak, Rauthy, Authentik, Zitadel, Ory, Janssen, Casdoor, or Pomerium
- [ ] Implement forward auth with reverse proxy
- [ ] Centralized authentication for all services

### Phase 7: Self-hosted DNS Sinkholes (Optional)
- [ ] Evaluate and deploy DNS Sinkholes
   - [ ] Options: AdGuard Home, Pi-hole, Blocky, Technitium DNS Server
   - [ ] Working with IPv6 

### Phase 8: File Storage & Collaboration
*Goal: Evaluate alternatives to Nextcloud setup.*
- [ ] Evaluate and deploy storage/collaboration (OpenCloud, Pydio Cells, or Seafile)
- [ ] Evaluate Office integration (Collabora or OnlyOffice)
- [ ] Full-text document search (PDF and Office documents)

### Phase 9: Media & Content
- [ ] Photo management (Immich, PhotoPrism, Lychee, or Phase 5 selection)
- [ ] Recipe management (Mealie, Tandoor Recipes, or Grocy)
- [ ] E-book servers (Calibre-Web, Kavita, Komga, or Ubooquity)

### Phase 10: Storage & Backups
- [ ] Storage system implementation (ZFS, Btrfs, or other RAID/NAS solutions)
- [ ] Off-site backups

## Phase 11: Monitoring & Observability
*Goal: Gain visibility into system health, performance, and reliability across all hosts.*

- [ ] Centralized metrics collection
    - [Prometheus](https://prometheus.io/) — time-series metrics collection and querying
    - [VictoriaMetrics](https://victoriametrics.com/) — lightweight, high-performance Prometheus alternative
- [ ] Visualization & dashboards
    - [Grafana](https://grafana.com/) — dashboards for system, network, and application metrics
    - [Netdata](https://www.netdata.cloud/) — real-time monitoring with minimal setup
- [ ] System & host monitoring
    - Node Exporter — CPU, memory, disk, network metrics
    - Built-in NixOS/systemd metrics (via exporters or journald integration)
- [ ] Reverse proxy monitoring
    - Nginx / Angie status endpoints (stub_status or extended metrics)
    - Evaluate Angie’s enhanced metrics/statistics capabilities (future investigation)
- [ ] Log aggregation & analysis
    - [Loki](https://grafana.com/oss/loki/) — log aggregation (pairs well with Grafana)
    - [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) — log shipping agent
    - Alternative: [Elastic Stack](https://www.elastic.co/elastic-stack/) (heavier, more complex)
- [ ] Uptime & external monitoring
    - [Uptime Kuma](https://github.com/louislam/uptime-kuma) — self-hosted uptime monitoring
    - External uptime checks (optional)
- [ ] Network & internet monitoring
    - Existing: Speedtest CLI + InfluxDB + Grafana
    - Extend with latency tracking (ping), packet loss, and outage detection
- [ ] Alerting & notifications
    - Grafana alerting
    - Prometheus Alertmanager
    - Email notifications (integrate with msmtp)
    - Optional: push notifications / webhooks

> **Note:** Monitoring may be overkill depending on usage and scale. The value vs. effort/complexity will be evaluated before full implementation, with a preference for minimal, high-signal visibility rather than a heavy observability stack.

---

## Goals

* Learn and apply NixOS best practices.
* Build a flexible, reproducible home server environment.
* Explore alternatives to previously used tools and services.
* Maintain a clean, modular, and scalable configuration.
