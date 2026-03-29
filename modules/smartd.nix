{ ... }:
{
  # S.M.A.R.T disk monitoring
  services.smartd = {
    enable = true;
    defaults = ''
      -a
      -o on
      -s (S/../.././02|L/../../6/03)
      -W 4,45,50
    '';
    notifications.mail = {
      enable = true;
      recipient = "root";
    };
    notifications.test = true;
  };
}
