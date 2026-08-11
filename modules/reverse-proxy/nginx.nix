{ pkgs, ... }:
let
  # Declaratively generate a self-signed "snake oil" certificate.
  snakeoilCert =
    pkgs.runCommand "snakeoil-cert"
      {
        nativeBuildInputs = [ pkgs.openssl ];
      }
      ''
        mkdir -p $out
        openssl req -x509 -nodes -days 3650 \
          -newkey rsa:2048 \
          -keyout $out/key.pem \
          -out $out/cert.pem \
          -subj "/CN=invalid"
      '';
in
{
  ## Nginx
  services.nginx = {
    enable = true;
    #package = pkgs.angie;
    enableReload = true;

    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;

    clientMaxBodySize = "100m";
    commonHttpConfig = ''
      # Rate limiting zone — shared across all vhosts
      limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    '';
  };

  ## Catch-all: drop ALL unmatched traffic (HTTP + HTTPS) → 444
  services.nginx.virtualHosts."_" = {
    default = true;
    addSSL = true;
    sslCertificate = "${snakeoilCert}/cert.pem";
    sslCertificateKey = "${snakeoilCert}/key.pem";

    extraConfig = ''
      access_log /var/log/nginx/catchall.access.log;
      error_log  /var/log/nginx/catchall.error.log;
      return 444;
    '';
  };

  ## Firewall (IPv4 + IPv6)
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}
