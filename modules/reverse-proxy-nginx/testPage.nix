{ config, pkgs, ... }:

let
  domain = "${config.networking.hostName}.duckdns.org";

  # Default: random theme on each page load
  # Pin a specific theme by changing this to:
  #   ./html/terminal.html
  #   ./html/matrix.html
  #   ./html/blueprint.html
  testPageFile = ./html/random.html;

  webroot = pkgs.runCommand "nginx-test-page" {} ''
    mkdir -p $out
    substitute ${testPageFile} $out/index.html \
      --replace-fail "{{HOSTNAME}}" "${config.networking.hostName}"
  '';
in
{
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    http3 = true;
    quic = true;

    extraConfig = ''
      add_header Alt-Svc 'h3=":443"; ma=86400' always;
    '';

    locations."/" = {
      root = webroot;
      index = "index.html";
    };
  };
}
