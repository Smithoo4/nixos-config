# Currently not in use — I only have VMs and Pi SD cards running on servers, but keeping it for future bare-metal development
{ ... }:
{
  # S.M.A.R.T disk monitoring
  services.smartd = {
    enable = true;
    defaults.monitored = "-a -o on -S on -W 4,45,50 -s (S/../.././02|L/../../6/03)";
    notifications.mail = {
      enable = true;
      recipient = "root";
    };
  };
}
