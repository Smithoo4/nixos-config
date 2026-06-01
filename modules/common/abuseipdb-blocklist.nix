{ pkgs, ... }:

let
  # Blocklist: abuseipdb-s100-30d.ipv4
  #   - 100% confidence score, 30-day window (~127k IPs)
  #   - Recommended by borestad (≤30d avoids false positives)
  #   - https://github.com/borestad/blocklist-abuseipdb
  listUrl = "https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/main/abuseipdb-s100-30d.ipv4";

  updateScript = pkgs.writeShellScript "update-abuseipdb-blocklist" ''
    set -euo pipefail

    TABLE="blocklist"
    SET="abuseipdb-v4"
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    LIST="$TMPDIR/list.txt"
    SCRIPT="$TMPDIR/nft.conf"

    echo "Downloading AbuseIPDB blocklist..."
    ${pkgs.curl}/bin/curl -sSf --retry 3 --retry-delay 30 --max-time 120 \
      -o "$LIST" "${listUrl}"

    # Validate — must contain at least 1000 IPs (sanity check against
    # empty or corrupted downloads)
    COUNT=$(${pkgs.gnugrep}/bin/grep -cE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' "$LIST" || true)
    if [ "$COUNT" -lt 1000 ]; then
      echo "ERROR: only $COUNT IPs found (expected 1000+). Aborting." >&2
      exit 1
    fi

    echo "Building nft script for $COUNT IPs..."
    {
      echo "flush set inet $TABLE $SET"
      echo "add element inet $TABLE $SET {"
      ${pkgs.gnugrep}/bin/grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' "$LIST" \
        | ${pkgs.gnused}/bin/sed 's/$/,/'
      echo "}"
    } > "$SCRIPT"

    echo "Loading blocklist into nftables..."
    ${pkgs.nftables}/bin/nft -f "$SCRIPT"

    echo "Done. $COUNT IPs loaded into inet $TABLE/$SET."
  '';
in
{
  # ── nftables table: empty set + prerouting drop chain ──────────────
  #
  # The set is declared empty here and populated by the systemd service.
  # Prerouting at raw priority (-300) drops packets before conntrack,
  # the NixOS firewall, and fail2ban ever process them.
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

  # ── Oneshot service: download and load the blocklist ───────────────
  systemd.services.abuseipdb-blocklist = {
    description = "Download and load AbuseIPDB blocklist into nftables";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = updateScript;
      PrivateTmp = true;
      ProtectHome = true;
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
