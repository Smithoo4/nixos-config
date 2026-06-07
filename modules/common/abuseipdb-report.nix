{ pkgs, ... }:

{
  # AbuseIPDB API key
  sops.secrets.abuseipdb-apikey = { };

  # Custom fail2ban action — reads API key from sops secret at runtime.
  # Overrides the packaged abuseipdb.conf (which expects the key inline).
  # https://www.abuseipdb.com/fail2ban.html
  environment.etc."fail2ban/action.d/abuseipdb.conf".text = ''
    # AbuseIPDB reporting action (sops-nix variant)
    # Categories: https://www.abuseipdb.com/categories
    #
    # Usage in jail:
    #   abuseipdb[abuseipdb_category="18,22"]

    [Definition]

    actionban = APIKEY=$(cat <abuseipdb_apikey_file>) && \
                ${pkgs.curl}/bin/curl --fail --tlsv1.2 -s -o /dev/null \
                'https://api.abuseipdb.com/api/v2/report' \
                -H 'Accept: application/json' \
                -H "Key: $APIKEY" \
                --data-urlencode 'ip=<ip>' \
                --data-urlencode 'comment=<matches>' \
                --data 'categories=<abuseipdb_category>'

    [Init]
    abuseipdb_category = 18
    abuseipdb_apikey_file = /run/secrets/abuseipdb-apikey
  '';

  # Add AbuseIPDB reporting to sshd jail
  # Categories: 18 = Brute-Force, 22 = SSH
  services.fail2ban.jails.sshd.settings = {
    action = "%(action_)s\n         abuseipdb[abuseipdb_category=\"18,22\"]";
  };
}
