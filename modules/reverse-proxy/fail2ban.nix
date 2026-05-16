{ ... }:
{
  ## Custom filter: match EVERY line in the catch-all access log.
  ##
  ## Since catchall.access.log ONLY receives traffic that hit the
  ## default_server (no valid FQDN / unmatched Host header), every
  ## single line is hostile — regardless of HTTP status code.
  ## Assumes default nginx "combined" log format (not customised).
  environment.etc."fail2ban/filter.d/nginx-catchall.conf".text = ''
    [Definition]
    failregex = ^<HOST>
    ignoreregex =
  '';

  ## Nginx fail2ban jails
  ## Assumes services.fail2ban.enable = true in modules/common/fail2ban.nix
  services.fail2ban.jails = {
    ## Ban clients repeatedly hitting the catch-all (no valid FQDN)
    nginx-catchall.settings = {
      enabled = true;
      filter = "nginx-catchall";
      protocol = "all";
      port = "http,https";
      logpath = "/var/log/nginx/catchall.access.log";
      backend = "polling";
      maxretry = 2;
    };

    ## Ban bots probing common exploit paths on real vhosts
    nginx-botsearch.settings = {
      enabled = true;
      filter = "nginx-botsearch";
      protocol = "all";
      port = "http,https";
      logpath = "/var/log/nginx/access.log";
      backend = "polling";
    };

    ## Ban clients sending malformed/garbage requests to real vhosts
    nginx-bad-request.settings = {
      enabled = true;
      filter = "nginx-bad-request";
      protocol = "all";
      port = "http,https";
      logpath = "/var/log/nginx/access.log";
      backend = "polling";
    };

    ## Ban clients that repeatedly hit rate limits on real vhosts
    nginx-limit-req.settings = {
      enabled = true;
      filter = "nginx-limit-req";
      protocol = "all";
      port = "http,https";
      backend = "systemd";
      journalmatch = "_SYSTEMD_UNIT=nginx.service";
      maxretry = 5;
    };
  };
}
