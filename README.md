# NixOS Home Server Configuration

This repository contains a personal NixOS configuration for building and managing home servers using flakes.

## Status

Active Development — currently being refined, expanded, and tested.

---

## Hosts

| Host | Status | Purpose |
| :--- | :--- | :--- |
| **oneohm** | Active Development | Testing and development |
| **twoohm** | Planned | TBD |
| **threeohm** | Planned | TBD |
| **fourohm** | Planned | TBD |

*Note: All hosts except `oneohm` are currently in the planning stage.*

---

## Roadmap & Implementation

### Phase 1: Core System & Infrastructure
- [x] Initial installation guide [here](https://github.com/Smithoo4/nixos-config/blob/main/nixos-homeserver-install-guide.md)
    - [x] Install NixOS from scratch (Flakes + Disko)
    - [x] Home Manager and Git integration
    - [x] Secrets Management via SOPS-Nix
        - *Evaluated Agenix; proceeded with SOPS-Nix as the primary solution.*
- [x] Refactor configuration for modular, multi-host support
- [x] msmtp setup
- [x] S.M.A.R.T disk monitoring with email notifications via `smartd`
 - Enable on physical hosts via `"${self}/modules/smartd.nix"` in host `default.nix`
- [X] Automatic updates
    - [X] Central `flake.lock` update for all hosts (Evaluate master host vs. [update-flake-lock](https://github.com/DeterminateSystems/update-flake-lock))
    - [X] Schedule auto updates
    - [X] Email notifications of failed update or warnings

### Phase 2: Reverse Proxy
*Goal: Evaluate alternatives to Nginx and Fail2Ban.*
- [X] Set up Caddy
    - [X] ACME DNS challenge using DuckDNS
    - [X] Enable HTTP/3
    - [X] Hardened proxy connections
    - [X] Strict host matching (Drop unmatched requests)

### Phase 3: Deployment & Documentation
- [ ] Comprehensive deployment tutorial
    - [ ] Install second host (`fourohm`) pulling config from GitHub
    - [ ] Evaluate [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)

### Phase 3a: Ideas & Modular Exploration (Optional)
- [ ] Store configuration exclusively in GitHub (no local persistence)
- [ ] Reconsider using:
    - [ ] Nginx as Reverse Proxy
        - *I'm not a fan of having to compile a custom Caddy build just to get the DNS challenge working. It adds unnecessary complexity, and I'm worried about long compile times on low-power ARM machines.*
    - [ ] Dynamic DNS using another provider
        - *DYNU: I've used it before, and it has lots of nice features plus a wider selection of domain names.*
    - [ ] Agenix for Secrets Management
    	- *I like sops-nix, but I'm worried about long compile times on low-power ARM machines, which may not be an issue with Agenix.*
- [ ] Set up CrowdSec — on hold, NixOS module has known issues (nixpkgs#446307)
    - [ ] SSH protection
    - [ ] WebServer protection
- [ ] Evaluate [flake-parts](https://github.com/hercules-ci/flake-parts)
- [ ] Refactor configuration layout based on lessons learned
- [ ] Static ip address on local network
    - [ ] IPv4
    - [ ] IPv6
- [ ] Dynamic dns Using DuckDNS/DYNU on Public Network
     - [ ] IP address Update script vs [ddns-updater](https://github.com/qdm12/ddns-updater) vs [ddclirnt](https://ddclient.net/) 
     - [ ] IPv4 with NAT Port Forwarding
     - [ ] IPv6

### Phase 4: Authentication & SSO
*Goal: Evaluate alternatives to Authelia + lldap.*
- [ ] Evaluate and deploy SSO
    - [ ] Options: Kanidm, Keycloak, Rauthy, Authentik, Zitadel, Ory, Janssen, Casdoor, or Pomerium
- [ ] Implement forward auth with reverse proxy
- [ ] Centralized authentication for all services

### Phase 4a: Self-hosted DNS Sinkholes (Optional)
- [ ] Evaluate and deploy DNS Sinkholes
   - [ ] Options: AdGuard Home, Pi-hole, Blocky, Technitium DNS Server
   - [ ] Working with IPv6 

### Phase 5: File Storage & Collaboration
*Goal: Evaluate alternatives to Nextcloud setup.*
- [ ] Evaluate and deploy storage/collaboration (OpenCloud, Pydio Cells, or Seafile)
- [ ] Evaluate Office integration (Collabora or OnlyOffice)
- [ ] Full-text document search (PDF and Office documents)

### Phase 6: Media & Content
- [ ] Photo management (Immich, PhotoPrism, Lychee, or Phase 5 selection)
- [ ] Recipe management (Mealie, Tandoor Recipes, or Grocy)
- [ ] E-book servers (Calibre-Web, Kavita, Komga, or Ubooquity)

### Phase 7: Storage & Backups
- [ ] Storage system implementation (ZFS, Btrfs, or other RAID/NAS solutions)
- [ ] Off-site backups

---

## Goals

* Learn and apply NixOS best practices.
* Build a flexible, reproducible home server environment.
* Explore alternatives to previously used tools and services.
* Maintain a clean, modular, and scalable configuration.
