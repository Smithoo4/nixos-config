{ pkgs, ... }:
let
  # Blocklist: abuseipdb-s100-30d.ipv4
  #   - 100% confidence score, 30-day window (~127k IPs)
  #   - https://github.com/borestad/blocklist-abuseipdb
  listUrl = "https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/main/abuseipdb-s100-30d.ipv4";

  stateDir = "/var/lib/abuseipdb-blocklist";
  cacheFile = "${stateDir}/blocklist.nft";

  updateScript = pkgs.writeShellScript "update-abuseipdb-blocklist" ''
    set -euo pipefail
    TABLE="blocklist"
    SET="abuseipdb-v4"
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT
    RAW="$TMPDIR/raw.txt"
    LIST="$TMPDIR/list.txt"
    SCRIPT="$TMPDIR/nft.conf"

    echo "Downloading AbuseIPDB blocklist..."
    ${pkgs.curl}/bin/curl -sSf --retry 3 --retry-delay 30 --max-time 120 \
      -o "$RAW" "${listUrl}"

    ${pkgs.gawk}/bin/awk '/^[0-9]/ { print $1 }' "$RAW" > "$LIST"
    COUNT=$(wc -l < "$LIST")
    if [ "$COUNT" -lt 1000 ]; then
      echo "ERROR: only $COUNT IPs found (expected 1000+). Aborting." >&2
      exit 1
    fi

    {
      echo "flush set inet $TABLE $SET"
      echo "add element inet $TABLE $SET {"
      ${pkgs.gnused}/bin/sed 's/$/,/' "$LIST"
      echo "}"
    } > "$SCRIPT"

    # Validate before replacing the cache
    ${pkgs.nftables}/bin/nft -c -f "$SCRIPT"

    # Atomic cache update
    install -m 0600 "$SCRIPT" "${cacheFile}.tmp"
    mv "${cacheFile}.tmp" "${cacheFile}"

    ${pkgs.nftables}/bin/nft -f "${cacheFile}"
    echo "Done. $COUNT IPs loaded into inet $TABLE/$SET."
  '';

  restoreScript = pkgs.writeShellScript "restore-abuseipdb-blocklist" ''
    set -euo pipefail
    if [ ! -s "${cacheFile}" ]; then
      echo "No cached blocklist yet; skipping."
      exit 0
    fi
    ${pkgs.nftables}/bin/nft -f "${cacheFile}"
    echo "Restored cached AbuseIPDB blocklist."
  '';
in
{
  # ── nftables table: empty set + prerouting drop chain ──────────────
  networking.nftables.tables.blocklist = {
    family = "inet";
    content = ''
      set abuseipdb-v4 {
        type ipv4_addr
        flags interval
      }
      chain prerouting {
        type filter hook prerouting priority raw; policy accept;
        ip saddr @abuseipdb-v4 counter drop
      }
    '';
  };

  # ── Daily download: fetch, cache, load ─────────────────────────────
  systemd.services.abuseipdb-blocklist = {
    description = "Download and load AbuseIPDB blocklist into nftables";
    after = [ "network-online.target" "nftables.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = updateScript;
      StateDirectory = "abuseipdb-blocklist";
      StateDirectoryMode = "0700";
      PrivateTmp = true;
      ProtectHome = true;
    };
    unitConfig.OnFailure = [ "notify-failure@%n.service" ];
  };

  # ── Restore cached set whenever nftables restarts or reloads ───────
  systemd.services.abuseipdb-blocklist-restore = {
    description = "Restore cached AbuseIPDB blocklist after nftables (re)load";
    after = [ "nftables.service" ];
    partOf = [ "nftables.service" ];          # follow restarts
    wantedBy = [ "nftables.service" "multi-user.target" ];
    unitConfig.ReloadPropagatedFrom = "nftables.service"; # follow reloads
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;                 # required for ExecReload
      ExecStart = restoreScript;
      ExecReload = restoreScript;
    };
    unitConfig.OnFailure = [ "notify-failure@%n.service" ];
  };

  # ── Daily timer ────────────────────────────────────────────────────
  systemd.timers.abuseipdb-blocklist = {
    description = "Daily AbuseIPDB blocklist update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:30";
      RandomizedDelaySec = "30min";
      Persistent = true;
    };
  };
}
