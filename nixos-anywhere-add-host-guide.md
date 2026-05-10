# Adding a New Host with nixos-anywhere

A guide to adding a new machine to an existing
[nixos-config](https://github.com/Smithoo4/nixos-config) flake and deploying
it remotely using [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).

nixos-anywhere SSH's into a running Linux system, streams a NixOS environment
into memory using `kexec`, partitions and formats the disk using
[Disko](https://github.com/nix-community/disko), and installs NixOS. This
guide covers registering the new host in the flake, creating its configuration
files, generating and wiring in its age key, re-encrypting secrets, and
running the remote install.

---

## Definitions

**Source machine** is the computer where you run the `nixos-anywhere` command.
It needs Nix installed with flakes and `nix-command` enabled. It can be NixOS,
macOS with nix-darwin, or any Linux system with Nix.

**Target machine** is the computer you are installing NixOS onto. It must be
reachable over SSH from the source machine and must be running one of:

- The **NixOS minimal ISO** (recommended, works on any hardware).
- Any Linux system with `kexec` support (e.g. a fresh VPS, a cloud VM, a
  bare-metal server booted from a rescue image).

---

## Assumptions

- You have a working [nixos-config](https://github.com/Smithoo4/nixos-config)
  repository structured with Flakes, Disko, sops-nix, and Home Manager.
- The source machine has the `nixos-config` repository cloned and has `age`
  and `sops` installed.
- The source machine has the admin age key available at
  `~/.config/sops/age/keys.txt` (or `SOPS_AGE_KEY_FILE` set). This is
  required to re-encrypt secrets in Section 6.
- The source machine can reach the target machine over SSH. How to set this
  up is covered in [Section 1](#1-prepare-the-target-machine).
- The target machine should have a DHCP reservation (based on its MAC address)
  so that its IP address does not change between boots. Without this, the
  machine may receive a different IP after rebooting into the kexec environment
  or the newly installed system, causing nixos-anywhere to lose its connection
  mid-install.
- The following placeholders are used throughout this guide. Substitute your
  own values wherever they appear:

| Placeholder | Meaning |
|---|---|
| `<hostname>` | The hostname for the new machine (e.g. `twoohm`, `myserver`) |
| `<TARGET-IP>` | The IP address of the target machine |
| `<PUBKEY>` | The age public key generated for the new host |
| `<DISK>` | The target disk device path (e.g. `/dev/vda`, `/dev/sda`) |

---

## Table of Contents

1. [Prepare the Target Machine](#1-prepare-the-target-machine)
2. [Identify the Target Disk](#2-identify-the-target-disk)
3. [Update the Flake on Your Source Machine](#3-update-the-flake-on-your-source-machine)
4. [Create the Host Directory and Files](#4-create-the-host-directory-and-files)
5. [Generate the Host Age Key](#5-generate-the-host-age-key)
6. [Update `.sops.yaml` and Re-encrypt Secrets](#6-update-sopsyaml-and-re-encrypt-secrets)
7. [Commit and Push](#7-commit-and-push)
8. [Run the nixos-anywhere Install](#8-run-the-nixos-anywhere-install)
9. [Post-Install Checks and Cleanup](#9-post-install-checks-and-cleanup)

**Appendices**

- [Appendix A: Setting Up binfmt for Cross-Architecture Builds](#appendix-a-setting-up-binfmt-for-cross-architecture-builds)

---

## 1. Prepare the Target Machine

nixos-anywhere needs SSH access to the target as `root`, or as a user who can
run `sudo` without a password.

### 1.1 NixOS live environment (recommended)

Boot the target from the [NixOS minimal ISO](https://nixos.org/download/#nixos-iso)
(for x86_64), or from a NixOS SD card image (for Raspberry Pi 4).

This is the universal approach and is **required** when the target does not
support `kexec` (e.g. Raspberry Pi 4). When nixos-anywhere detects that the target is
already running NixOS, it skips the kexec step entirely.

At the live console, switch to root and set up SSH access:

**Option A: Add your SSH public key (preferred)**

```bash
sudo -i
mkdir -p /root/.ssh
cat <<EOF > /root/.ssh/authorized_keys
ssh-ed25519 <YOUR-PUBLIC-KEY>
EOF
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
systemctl start sshd
ip addr show
```

Replace `<YOUR-PUBLIC-KEY>` with your SSH public key. You can add multiple
keys, one per line. Note the IP address shown on your network interface
(e.g. `enp1s0`, `eth0`, `ens3`). That is your `<TARGET-IP>`.

**Option B: Set a root password**

If you prefer password authentication for the live session:

```bash
sudo -i
passwd
systemctl start sshd
ip addr show
```

Enter a temporary password when prompted. Note the IP address. On your
source machine, connect with:

```bash
ssh -o StrictHostKeyChecking=accept-new root@<TARGET-IP>
```

> **Note:** The live ISO (or SD card image) is a throwaway environment. It is
> safe to automatically accept the SSH host fingerprint with
> `StrictHostKeyChecking=accept-new`.

### 1.2 Already running Linux with kexec (VPS / cloud instances)

Most providers give you root SSH access by default, or let you inject an SSH
public key at provisioning time. If the target is running a generic Linux
distro with `kexec` support, nixos-anywhere can take over without booting from
an ISO — it loads a NixOS environment into memory via `kexec` first.

Confirm `kexec` is available on the target:

```bash
cat /proc/sys/kernel/kexec_load_disabled
```

`0` means kexec is enabled — proceed with the install. `1` means kexec is
disabled — boot from a NixOS live environment instead
([Section 1.1](#11-nixos-live-environment-recommended)).

**Non-root user with passwordless sudo**

If you can only SSH in as a non-root user, that user must be able to run
`sudo` without a password prompt. On NixOS:

```nix
security.sudo.wheelNeedsPassword = false;
```

On a generic Linux system, add to `/etc/sudoers` (via `visudo`):

```
<your-user>  ALL=(ALL) NOPASSWD: ALL
```

Verify from your source machine before proceeding:

```bash
ssh <user>@<TARGET-IP> sudo id
```

The output should be `uid=0(root)` with no password prompt.

---

## 2. Identify the Target Disk

From your source machine, SSH into the target and list block devices:

```bash
ssh root@<TARGET-IP> lsblk -o NAME,SIZE,TYPE,MODEL
```

Example output on a VM (virtio disk):

```
NAME   SIZE TYPE MODEL
vda     40G disk
sr0    1.1G rom  QEMU DVD-ROM
```

Example output on bare metal (SATA):

```
NAME    SIZE TYPE MODEL
sda   476.9G disk Samsung SSD 870 EVO
sr0     1.1G rom
```

Example output on bare metal (NVMe):

```
NAME        SIZE TYPE MODEL
nvme0n1   476.9G disk Samsung SSD 980 PRO
sr0         1.1G rom
```

> **WARNING:**
> Confirm you have identified the correct disk. nixos-anywhere will **erase all
> data on it** during the install.

Note the device name. You will need it when writing `disko.nix` in the next
section.

For bare metal, prefer a stable identifier from `/dev/disk/by-id/`:

```bash
ssh root@<TARGET-IP> ls -la /dev/disk/by-id/
```

Use the entry that points to the whole disk (no `-part` suffix), for example:
`/dev/disk/by-id/ata-Samsung_SSD_870_EVO_S3Z2NX0K123456`.

> **Note:** VMs with virtio disks typically have no `/dev/disk/by-id/` entries.
> On a VM, use the kernel device name directly (e.g. `/dev/vda`).

---

## 3. Update the Flake on Your Source Machine

All remaining steps until Section 9 are run on your source machine inside
your cloned `nixos-config` repository.

```bash
cd ~/nixos-config   # or wherever you have the repo cloned
```

### 3.1 Add the host to `flake.nix`

Open `flake.nix` and add a new entry inside `nixosConfigurations`:

```nix
<hostname> = mkHost {
  system = "x86_64-linux";
  hostname = "<hostname>";
  timezone = "America/Edmonton";
};
```

Set `system` to match your target machine's architecture. Both `x86_64-linux`
and `aarch64-linux` are supported. Adjust `timezone` as needed.

The full `nixosConfigurations` block should look something like:

```nix
nixosConfigurations = {
  oneohm = mkHost {
    system = "x86_64-linux";
    hostname = "oneohm";
    timezone = "America/Edmonton";
  };

  fourohm = mkHost {
    system = "x86_64-linux";
    hostname = "fourohm";
    timezone = "America/Edmonton";
  };

  <hostname> = mkHost {
    system = "x86_64-linux";   # or "aarch64-linux" for ARM targets
    hostname = "<hostname>";
    timezone = "America/Edmonton";
  };
};
```

> **Note:** The `mkHost` function already imports `./modules/common` and
> `./users/smithoo4` for every host. You do not need to add them in the
> host's own `default.nix`.

---

## 4. Create the Host Directory and Files

### 4.1 Create the directory

```bash
mkdir -p hosts/<hostname>
```

### 4.2 `default.nix`

Create `hosts/<hostname>/default.nix`. The bootloader configuration belongs
in each host's `default.nix` since it is platform-specific.

For a standard UEFI server:

```nix
{ self, ... }:
{
  # Bootloader (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  imports = [
    # Hardware
    ./hardware-configuration.nix
    ./disko.nix

    # Users
    # "${self}/users/…"

    # Services
    # "${self}/modules/…"
  ];

  # Set once at install time. Do NOT change after first boot.
  system.stateVersion = "25.11";
}
```

> **Note:** `system.stateVersion` should match the NixOS release you are
> installing. Check your `flake.nix` inputs (e.g. `nixos-25.11`) and use the
> matching version string.

> **Note:** For non-UEFI targets (e.g. Raspberry Pi 4 with extlinux/U-Boot),
> the bootloader section will differ. Do not include the `systemd-boot` lines
> for those hosts.

### 4.3 `disko.nix`

For more complex layouts (RAID, LVM, ZFS, multiple disks), see the
[Disko examples](https://github.com/nix-community/disko/tree/master/example).

The example below is a simple GPT layout with a 512 MB EFI partition and an
ext4 root that fills the remainder of the disk. Use the disk path you
identified in [Section 2](#2-identify-the-target-disk).

Create `hosts/<hostname>/disko.nix`:

```nix
{ ... }:
{
  disko.devices = {
    disk = {
      main = {
        device = "<DISK>";   # replace with your disk path
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "defaults" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
```

Replace `<DISK>` with the actual device path noted in Section 2.

### 4.4 `hardware-configuration.nix` (placeholder)

nixos-anywhere generates the real `hardware-configuration.nix` during the
install and writes it back to your source machine. For now, copy the file from
an existing host as a placeholder so the flake evaluates without errors:

```bash
cp hosts/oneohm/hardware-configuration.nix hosts/<hostname>/hardware-configuration.nix
```

nixos-anywhere will replace this file automatically during the install when you
pass `--generate-hardware-config` (see [Section 8](#8-run-the-nixos-anywhere-install)).

---

## 5. Generate the Host Age Key

Each host needs its own age private key so it can decrypt secrets at boot.
Generate the key on your source machine and stage it in a temporary directory.
nixos-anywhere will copy this directory tree onto the new system before rebooting.

```bash
mkdir -p /tmp/extra/var/lib/sops-nix
age-keygen -o /tmp/extra/var/lib/sops-nix/key.txt
chmod 600 /tmp/extra/var/lib/sops-nix/key.txt
```

`age-keygen` prints the public key to the terminal when it runs. Copy the
value shown on the `Public key:` line. You will paste it into `.sops.yaml`
in the next step.

> **WARNING:**
> The private key at `/tmp/extra/var/lib/sops-nix/key.txt` is the
> only copy. If you lose it before the system boots, the host will be unable to
> decrypt its secrets and you will need to start this process over. Do not
> delete `/tmp/extra` until after the install is confirmed working.

---

## 6. Update `.sops.yaml` and Re-encrypt Secrets

### 6.1 Add the new host key to `.sops.yaml`

Open `.sops.yaml` and add the new host's public key:

```yaml
keys:
  - &admin age1v492u0esm92zy34e33xd9m7z4jt3v03j233ar75k5m7s0rlxes0sxadr2t
  - &oneohm age1mazttzsgw0eqp5c4mmkm75v07wu7nl07gt0z64qgwe2yzdk8jueq0yys3l
  - &<hostname> <PUBKEY>    # paste the PUBKEY from Section 5 here

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
        - *admin
        - *oneohm
        - *<hostname>     # add this line
```

Replace `<PUBKEY>` with the value printed in Section 5.

### 6.2 Re-encrypt the secrets file

Tell sops to re-encrypt `secrets.yaml` so the new host key is included.

```bash
sops updatekeys secrets/secrets.yaml
```

sops will show you the updated key list and ask for confirmation. Type `y` to
proceed. After this command, the new host can decrypt the secrets file at boot
using its own private key.

---

## 7. Commit and Push

Stage all changes and push before running nixos-anywhere. nixos-anywhere
fetches the flake directly from GitHub, so the remote must be up to date.

```bash
git add .
git commit -m "hosts: add <hostname>"
git push
```

Verify GitHub received the push and the flake evaluates cleanly:

```bash
nix flake show github:Smithoo4/nixos-config --all-systems
```

You should see `<hostname>` listed under `nixosConfigurations` in the output.

---

## 8. Run the nixos-anywhere Install

With the target reachable over SSH and the flake pushed to GitHub, run the
install from your source machine.

First, force Nix to fetch the latest version of the flake from GitHub,
bypassing any local cache:

```bash
nix flake prefetch --refresh github:Smithoo4/nixos-config
```

### 8.1 Default install (build locally on the source machine)

This is the standard approach. The system closure is built on your source
machine and copied to the target. Use this when the source and target share
the same architecture, or when the target has limited RAM.

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake github:Smithoo4/nixos-config#<hostname> \
  --generate-hardware-config nixos-generate-config \
    hosts/<hostname>/hardware-configuration.nix \
  --extra-files /tmp/extra \
  root@<TARGET-IP>
```

> **Note:** If SSH'ing as a non-root user with passwordless sudo, replace
> `root@<TARGET-IP>` with `<user>@<TARGET-IP>`. nixos-anywhere auto-detects
> `sudo` and `doas` on the target (since ~v1.8+).

### 8.2 Build on the target (`--build-on remote`)

If the target has plenty of RAM and you want to avoid cross-compilation or
binfmt setup, you can build directly on the target. During the install, the
target is running from **RAM** (live ISO or kexec environment), so all build
artifacts exist in RAM. Only use this when the target has enough memory.

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake github:Smithoo4/nixos-config#<hostname> \
  --generate-hardware-config nixos-generate-config \
    hosts/<hostname>/hardware-configuration.nix \
  --extra-files /tmp/extra \
  --build-on remote \
  root@<TARGET-IP>
```

**When to use which approach:**

| Target | Target RAM | Recommendation | Why |
|---|---|---|---|
| x86_64 VM | varies | Default (build locally) | Same arch as source — no cross-compilation needed |
| Raspberry Pi 4 | 2 GB | Default + binfmt on source | 2 GB can't handle building in RAM — will OOM |
| Oracle ARM VM | 24 GB | `--build-on remote` | Plenty of resources, avoids binfmt setup |

> **Note:** For cross-architecture builds (e.g. building `aarch64` from an
> `x86_64` source), you need binfmt configured on your source machine. See
> [Appendix A](#appendix-a-setting-up-binfmt-for-cross-architecture-builds).

### 8.3 What the install does, step by step

1. nixos-anywhere SSH's into `<TARGET-IP>` as root.
2. If the target is not already running NixOS, it streams a NixOS environment
   into memory via `kexec` and reboots into it. The machine stays reachable
   over SSH throughout.
3. It evaluates `github:Smithoo4/nixos-config#<hostname>` and runs Disko to
   partition and format the disk as declared in `disko.nix`.
4. It copies the contents of `/tmp/extra` onto the new system,
   placing the age private key at `/var/lib/sops-nix/key.txt` before
   first boot.
5. `--generate-hardware-config` runs `nixos-generate-config` on the target,
   writes the result to `hosts/<hostname>/hardware-configuration.nix` on your
   source machine, and includes that file in the install automatically.
6. It installs NixOS and reboots the target into the newly installed system.

> **Note:** The install typically takes 5 to 15 minutes depending on network
> speed and hardware. The target will reboot automatically at the end. Your SSH
> connection will drop at that point; that is expected.

---

## 9. Post-Install Checks and Cleanup

### 9.1 Commit the generated hardware configuration

nixos-anywhere wrote the real `hardware-configuration.nix` back to your source
machine. Commit it now so the repo reflects the actual hardware:

```bash
# Back on your source machine
cd ~/nixos-config
git add hosts/<hostname>/hardware-configuration.nix
git commit -m "hosts/<hostname>: add generated hardware-configuration"
git push
```

> **Note:** The auto-upgrade module (`modules/common/auto-upgrade.nix`) pulls
> from GitHub on a schedule. Committing the hardware configuration ensures the
> next automatic upgrade uses the correct file.

### 9.2 SSH into the new host

The SSH host key changed during the install. Remove the old known-hosts entry
before connecting:

```bash
ssh-keygen -R <TARGET-IP>
```

Then connect as your normal user:

```bash
ssh smithoo4@<TARGET-IP>
```

Your SSH key should authenticate automatically with no password prompt. This
works because your authorized key is declared in `users/smithoo4/default.nix`
and was deployed as part of the install.

### 9.3 Verify the system is healthy

Check that all services started cleanly:

```bash
sudo systemctl --failed
```

Review recent journal output for any warnings:

```bash
sudo journalctl -b --priority=warning
```

Confirm sops-nix decrypted secrets successfully:

```bash
sudo ls /run/secrets/
```

You should see the secrets listed in your configuration (e.g.
`smithoo4-password`, `smithoo4-ssh-key`).

Run a manual rebuild to confirm the host can pull and apply its configuration
from GitHub:

```bash
sudo nixos-rebuild switch --flake github:Smithoo4/nixos-config#<hostname> --refresh
```

The `--refresh` flag forces Nix to check GitHub for the latest version of the
flake rather than using a cached copy. If the rebuild completes successfully,
the auto-upgrade module is wired up correctly and the host will keep itself up
to date on its own schedule.

When you are done, exit back to your source machine:

```bash
exit
```

### 9.4 Clean up the temporary age key

The private key in `/tmp/extra` is no longer needed. It was copied
onto the target during the nixos-anywhere run. Delete it from your source
machine:

```bash
rm -rf /tmp/extra
```

> **WARNING:**
> The canonical copy of the host's private key now lives only on the target at
> `/var/lib/sops-nix/key.txt`. If you ever wipe the target, you will need to
> repeat Section 5 and Section 6 to generate a new key and re-encrypt secrets.

---

## Appendix A: Setting Up binfmt for Cross-Architecture Builds

When building `aarch64` packages from an `x86_64` source machine, you need
binfmt + QEMU to emulate the target architecture. Most packages come from
the Hydra binary cache, so actual emulated builds are rare — but binfmt must
be registered so Nix knows it *can* build `aarch64`.

### Non-NixOS Linux (Fedora, Ubuntu, etc.)

Install QEMU user emulation:

- **Fedora:**
  ```bash
  sudo dnf install qemu-user-static
  ```
- **Ubuntu / Debian:**
  ```bash
  sudo apt update
  sudo apt install qemu-user-static
  ```

Then run the following common steps:

```bash
# Verify aarch64 is registered
ls /proc/sys/fs/binfmt_misc/qemu-aarch64

# Tell the Nix daemon it can build aarch64
mkdir -p ~/.config/nix
echo "extra-platforms = aarch64-linux" >> ~/.config/nix/nix.conf
echo "extra-sandbox-paths = /usr/bin/qemu-aarch64-static" >> ~/.config/nix/nix.conf

# Restart the daemon to pick up the changes
sudo systemctl restart nix-daemon
```

### NixOS

One line in your NixOS configuration:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

Rebuild and you're done. The NixOS module handles QEMU registration
automatically.

---

## Reference

| Resource | Link |
|---|---|
| nixos-anywhere repository | https://github.com/nix-community/nixos-anywhere |
| nixos-anywhere documentation | https://nix-community.github.io/nixos-anywhere |
| Disko repository | https://github.com/nix-community/disko |
| Disko examples | https://github.com/nix-community/disko/tree/master/example |
| sops-nix repository | https://github.com/Mic92/sops-nix |
| age repository | https://github.com/FiloSottile/age |
| nixos-config repository | https://github.com/Smithoo4/nixos-config |

---

**Version:** 2.4 | **Last Updated:** April 2026
