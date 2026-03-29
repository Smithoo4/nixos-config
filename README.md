# NixOS Home Server Configuration

This repository contains my personal NixOS configuration for building and managing home servers using flakes.

## Status

Active Development — currently being refined, expanded, and tested.

---

## Hosts

| Host     | Status              | Purpose                 |
|----------|-------------------|--------------------------|
| oneohm   | Active Development | Testing and development |
| twoohm   | Planned           | TBD                      |
| threeohm | Planned           | TBD                      |

All hosts except `oneohm` are still in the planning stage.

---

## To Do

### System and Maintenance
- [ ] S.M.A.R.T error notifications  
  (Initial focus: testing non-common services and msmtp setup)  
- [ ] Automatic updates with notifications  

---

### Reverse Proxy (Caddy)
- [ ] Set up Caddy (previous experience with Nginx — trying something new)  
  - [ ] ACME DNS challenge using DuckDNS  
  - [ ] Enable HTTP/3  
  - [ ] Hardened proxy connections  
  - [ ] Strict host matching  
    - Drop all unmatched requests (similar to Nginx 444 or Traefik sniStrict)  
- [ ] Set up CrowdSec (previously used Fail2Ban — exploring alternatives)  

---

### Deployment and Documentation
- [ ] Write installation and deployment tutorial using this repository  
  - Similar to: nixos-homeserver-install-guide.md  
  - Use this repo directly as the system configuration  
  - Cover full flow:
    - Disk provisioning with Disko  
    - Initial install using flakes  
    - Secrets bootstrapping (sops-nix / age keys)  
    - First boot considerations  
    - Rebuild and update workflow  
  - Goal: make spinning up a new host from this repo straightforward and repeatable  

---

### Authentication / SSO
- [ ] Evaluate and deploy one of:  
  - Kanidm, Keycloak, Rauthy, Authentik, Zitadel, Ory, Janssen, Casdoor, or Pomerium  
  (previously used Authelia + lldap)  

- [ ] Implement SSO  
  - [ ] Forward auth with reverse proxy  
  - [ ] Centralized authentication for all services  

---

### File Storage and Collaboration
- [ ] Evaluate and deploy one of:  
  - OpenCloud, Pydio Cells, or Seafile (previously used Nextcloud)  

- [ ] Office integration  
  - [ ] Collabora or OnlyOffice  

- [ ] Full-text document search  

---

### Media and Content
- [ ] Photo management:  
  - Immich, PhotoPrism, or Lychee  

- [ ] Recipe management:  
  - Mealie, Tandoor Recipes, or Grocy  

- [ ] E-book servers:  
  - Calibre-Web, Kavita, Komga, or Ubooquity  

---

### Storage and Backups
- [ ] Storage system:  
  - ZFS, Btrfs, or other RAID/NAS solutions  

- [ ] Off-site backups  

---

## Completed

- [x] Install NixOS from scratch  
  https://github.com/Smithoo4/nixos-config/blob/main/nixos-homeserver-install-guide.md  
  - [x] Flakes  
  - [x] Disko  
  - [x] Secrets management  
    - [ ] Agenix (initial attempt unsuccessful — but did not try to hard)  
    - [x] SOPS-Nix (working)  
    - [x] Bootstrap process for new hosts  
  - [x] Home Manager and Git integration  

- [x] Refactor configuration  
  - Prepared for multiple hosts  
  - Improved layout and structure  

- [x] msmtp setup  

---

## Goals

- Learn and apply NixOS best practices  
- Build a flexible, reproducible home server environment  
- Explore alternatives to previously used tools and services  
- Maintain a clean, modular, and scalable configuration  
