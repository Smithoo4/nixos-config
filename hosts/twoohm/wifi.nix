{ config, ... }:
{
  ## WiFi firmware (brcmfmac for BCM43455)
  hardware.enableRedistributableFirmware = true;

  ## Sops secret
  sops.secrets.wifi-psk = { };
  sops.templates."wireless.env" = {
    content = ''
      psk_elysium=${config.sops.placeholder.wifi-psk}
    '';
  };

  ## WiFi (wpa_supplicant)
  networking.wireless = {
    enable = true;
    secretsFile = config.sops.templates."wireless.env".path;
    networks.elysium = {
      psk = "ext:psk_elysium";
    };
  };
}
