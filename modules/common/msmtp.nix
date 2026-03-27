{ config, ... }:
{
  # Sops-nix
  sops.secrets.msmtp-password = {};
  sops.secrets.msmtp-root-alias = {};

  # msmtp
  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      auth = "on";
      tls = "off";
      tls_starttls = "on";
    };
    accounts = {
      default = {
        host = "mail.shaw.ca";
        port = 587;
        user = "smith_oo4";
        from = "smith_oo4@shaw.ca";
        passwordeval = "cat ${config.sops.secrets.msmtp-password.path}";
      };
    };
  };

  # Root mail alias
  environment.etc."aliases" = {
    text = "root: $(cat ${config.sops.secrets.msmtp-root-alias.path})\n";
    mode = "0644";
  };
}
