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
