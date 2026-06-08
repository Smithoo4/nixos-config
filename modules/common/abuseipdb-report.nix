{ pkgs, ... }:

{
  sops.secrets.abuseipdb-apikey = { };

  # Custom action file — named differently to avoid conflict with
  # the stock abuseipdb.conf shipped by the fail2ban package.
  environment.etc."fail2ban/action.d/abuseipdb-nixos.conf".text = ''
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

  # Categories: 18 = Brute-Force, 22 = SSH
  services.fail2ban.jails.sshd.settings = {
    action = ''
      %(action_)s
                     abuseipdb-nixos[abuseipdb_category="18,22"]'';
  };
}
