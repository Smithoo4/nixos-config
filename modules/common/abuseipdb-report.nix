{ ... }:

{
  # AbuseIPDB API key for fail2ban reporting
  sops.secrets.abuseipdb-apikey = { };

  # Add AbuseIPDB reporting to sshd jail
  # Categories: 18 = Brute-Force, 22 = SSH
  services.fail2ban.jails.sshd.settings = {
    action = ''
      %(action_)s
                     abuseipdb[abuseipdb_apikey="$(cat /run/secrets/abuseipdb-apikey)", abuseipdb_category="18,22"]'';
  };
}
