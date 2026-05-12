{ ... }:

{
  # Nginx
  services.nginx = {
    enable = true;
    package = pkgs.angie;
    enableReload = true;

    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;

    clientMaxBodySize = "100m";
  };

  # Catch-all: drop unmatched HTTP
  services.nginx.virtualHosts."_" = {
    default = true;
    extraConfig = "return 444;";
  };

  # Catch-all: reject unmatched HTTPS (TLS handshake rejected via SNI)
  services.nginx.virtualHosts."_reject_https" = {
    rejectSSL = true;
  };

  # Firewall (IPv4 + IPv6)
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}
