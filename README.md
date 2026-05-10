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
    - [X] Serve a test page
    - [X] Template for proxying future services
- [X] Set up [Nginx](https://nginx.org/)
    - [X] ACME DNS challenge using [DuckDNS](https://www.duckdns.org/domains)
    - [X] Enable HTTP/3
    - [X] Hardened proxy connections
    - [X] Strict host matching and drop unmatched requests (e.g. no connecting unless it matches an FQDN)
    - [X] Serve a test page
    - [X] Template for proxying future services
    - [ ] Test [Angie](https://github.com/webserver-llc/angie) (e.g. `services.nginx.package = pkgs.angie`)

*Decision: Continue testing both, with Nginx as the standard.*  

Caddy's custom DuckDNS plugin build adds compile-time friction, especially on low-power ARM hosts. Nginx offers equivalent features with the mature, pre-built `lego` ACME client and better NixOS integration. Both will continue running on separate hosts during early service deployments to compare real-world behavior before full fleet commitment.

## Phase 3: Security
- [ ] Set up [CrowdSec](https://www.crowdsec.net/) — *on hold, NixOS module has known issues ([nixpkgs#446307](https://github.com/NixOS/nixpkgs/pull/446307))*
    - [ ] SSH protection
    - [ ] Caddy protection
        - [ ] Block repeated requests that don't match an FQDN (IP-only / unknown SNI)
    - [ ] Nginx protection
        - [ ] Block repeated requests that don't match an FQDN (IP-only / unknown SNI)
    - [ ] Evaluate [CrowdSec Console](https://app.crowdsec.net/) — cloud monitoring & automation dashboard
    - [ ] Evaluate [Metabase](https://www.metabase.com/) — local self-hosted dashboard (`cscli dashboard setup`)
- [ ] Set up [Fail2Ban](https://github.com/fail2ban/fail2ban) — *only being considered because of implementation issues with CrowdSec on NixOS*
    - [ ] SSH protection
    - [ ] Caddy protection
        - [ ] Block repeated requests that don't match an FQDN (IP-only / unknown SNI)
    - [ ] Nginx protection
        - [ ] Block repeated requests that don't match an FQDN (IP-only / unknown SNI)

&gt; **Note:** Not all evaluated tools will necessarily be implemented. Items are tracked for comparison and may be dropped based on findings.
  
### Phase 4: Deployment & Documentation
- [X] Store configuration exclusively in GitHub (no local persistence)
- [ ] Comprehensive deployment tutorial
    - [X] Install second host (`fourohm`) pulling config from GitHub
    - [X] Evaluate [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
    - [ ] Cover installing on raspberry pi 4
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

---

## Goals

* Learn and apply NixOS best practices.
* Build a flexible, reproducible home server environment.
* Explore alternatives to previously used tools and services.
* Maintain a clean, modular, and scalable configuration.
