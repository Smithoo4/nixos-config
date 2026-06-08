{ pkgs, ... }:

{
  # AbuseIPDB API key for fail2ban reporting
  sops.secrets.abuseipdb-apikey = { };

  # Custom fail2ban action
  # Reads API key from sops secret at runtime.
  # Based on upstream abuseipdb.conf with NixOS-specific adaptations.
  # Categories: https://www.abuseipdb.com/categories
  environment.etc."fail2ban/action.d/abuseipdb.conf".text = ''
    [Definition]
    norestored = 1

    actionban = APIKEY=$(${pkgs.coreutils}/bin/cat /run/secrets/abuseipdb-apikey) && \
                lgm=$(${pkgs.coreutils}/bin/printf '%%.1000s\n...' "<matches>") && \
                ${pkgs.curl}/bin/curl --fail --tlsv1.2 -sSo /dev/null \
                  'https://api.abuseipdb.com/api/v2/report' \
                  -H 'Accept: application/json' \
                  -H "Key: $APIKEY" \
                  --data-urlencode "comment=$lgm" \
                  --data-urlencode 'ip=<ip>' \
                  --data 'categories=<abuseipdb_category>'

    actionstart =
    actionstop =
    actioncheck =
    actionunban =

    [Init]
    abuseipdb_category = 18
  '';

  # Add AbuseIPDB reporting to sshd jail
  # Categories: 18 = Brute-Force, 22 = SSH
  services.fail2ban.jails.sshd.settings = {
    action = ''
      %(action_)s
                     abuseipdb[abuseipdb_category="18,22"]'';
  };
}
