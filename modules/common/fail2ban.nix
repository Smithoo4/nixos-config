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

    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "192.168.0.0/24"
    ];
  };
}

# Check fail2ban is running and SSH jail is active
# sudo fail2ban-client status
# sudo fail2ban-client status sshd

# Check the nftables rules were created
# sudo nft list ruleset | grep f2b

# Watch bans in real time
# journalctl -u fail2ban -f
