{ ... }:
{
  ## fail2ban — SSH protection is pre-configured by NixOS.
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
  };
}
