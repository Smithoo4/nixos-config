# nixos-config

NixOS flake configuration for headless home servers.

## Hosts

| Hostname | Arch | Timezone | Status |
|----------|------|----------|--------|
| oneohm | x86_64 | America/Edmonton | ✅ Active |
| auir | aarch64 | TBD | 🔜 Planned |
| artimoose | x86_64 | TBD | 🔜 Planned |
| gypsystudio | x86_64 | TBD | 🔜 Planned |

## Structure

```
├── flake.nix
├── hosts/          # Host-specific config (hardware, disko, users, services)
├── modules/
│   └── common/     # Applied to all hosts (bootloader, SSH, msmtp, nix, sops)
├── users/          # Per-user NixOS and Home Manager config
└── secrets/        # SOPS-encrypted secrets
```

## Common Modules

Everything in `modules/common/` is applied to every host:

- systemd-boot, zram
- Hardened OpenSSH (key-only, no root login)
- msmtp email relay for service notifications
- SOPS-nix secrets management
- Weekly Nix GC and store optimisation

## Adding a Host

1. Create `hosts/<hostname>/` with `default.nix`, `hardware-configuration.nix`, and `disko.nix`
2. Add an entry in `flake.nix` under `nixosConfigurations`
3. Add the host age key to `.sops.yaml` and run `sops updatekeys secrets/secrets.yaml`

## Deploying

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Planned Services

- [ ] Caddy
- [ ] Nextcloud
- [ ] Jellyfin
- [ ] Immich
