{ config, ... }:
{
  # Sops-nix
  sops.secrets.msmtp-password = {};
  sops.secrets.msmtp-root-alias = {};
  sops.templates."aliases" = {
    content = ''
      root: ${config.sops.placeholder.msmtp-root-alias}
    '';
  };

  # msmtp
  programs.msmtp = {
    enable = true;
    setSendmail = true;

    defaults = {
      tls = "on";
      auth = "on";
      tls_starttls = "on";
      aliases = "/etc/aliases";
    };

    accounts.default = {
      host = "mail.shaw.ca";
      port = 587;
      user = "smith_oo4";
      from = "smith_oo4@shaw.ca";
      passwordeval = "cat ${config.sops.secrets.msmtp-password.path}";
    };
  };

  # Root mail alias
  environment.etc."aliases".source = config.sops.templates."aliases".path;
}












