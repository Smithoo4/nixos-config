# nixos-config

Personal NixOS flake configuration for a fleet of headless home servers.

## Hosts

| Hostname | Architecture | Timezone | Status |
|----------|-------------|----------|--------|
| oneohm | x86_64-linux | America/Edmonton | ✅ Active |
| auir | aarch64-linux | TBD | 🔜 Planned |
| artimoose | x86_64-linux | TBD | 🔜 Planned |
| gypsystudio | x86_64-linux | TBD | 🔜 Planned |

## Structure

```
.
├── flake.nix                        # Flake inputs & mkHost helper
├── .sops.yaml                       # SOPS key groups & path rules
├── hosts/
│   └── oneohm/
│       ├── default.nix              # Hardware, disko, users, services
│       ├── disko.nix                # Disk layout
│       └── hardware-configuration.nix
├── modules/
│   └── common/
│       ├── default.nix              # Shared config applied to all hosts
│       └── openssh.nix              # SSH hardening
├── users/
│   └── smithoo4/
│       ├── default.nix              # NixOS layer: user account & secrets
│       ├── home-manager.nix         # Home Manager layer: packages & dotfiles
│       └── smithoo4_github_ed25519.pub
└── secrets/
    └── secrets.yaml                 # SOPS-encrypted secrets
```

## What Every Host Gets

Everything in `modules/common/` is applied to all hosts via `mkHost` in `flake.nix`:

- systemd-boot bootloader
- zram swap
- Hardened OpenSSH (key-only, no root login)
- SOPS-nix secrets infrastructure
- Weekly Nix garbage collection & store optimisation
- Flakes & nix-command enabled

## Secrets

Secrets are managed with [SOPS](https://github.com/getsops/sops) and [sops-nix](https://github.com/Mic92/sops-nix), encrypted with [age](https://github.com/FiloSottile/age).

The age key for a host is expected at `/var/lib/sops-nix/key.txt`.

## Adding a New Host

**1.** Create the host directory:
```bash
mkdir hosts/<hostname>
```

**2.** Add `default.nix`, `hardware-configuration.nix`, and `disko.nix` for the new host.

**3.** Uncomment or add an entry in `flake.nix`:
```nix
<hostname> = mkHost {
  system = "x86_64-linux";
  hostname = "<hostname>";
  timezone = "America/Edmonton";
};
```

**4.** Add the new host's age public key to `.sops.yaml` and re-encrypt secrets:
```bash
sops updatekeys secrets/secrets.yaml
```

## Deploying

```bash
# On the target host
sudo nixos-rebuild switch --flake .#<hostname>

# Or remotely
nixos-rebuild switch --flake .#<hostname> --target-host <hostname>
```

## Adding a Service

Create a module under `modules/` and opt the host in via its `default.nix`:

```nix
# hosts/oneohm/default.nix
imports = [
  ...
  "${self}/modules/jellyfin"
];
```

## Planned Services

- [ ] Caddy (reverse proxy)
- [ ] Nextcloud
- [ ] Jellyfin
- [ ] Immich
