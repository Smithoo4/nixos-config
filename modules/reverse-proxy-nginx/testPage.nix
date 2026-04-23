{ config, pkgs, ... }:

let
  domain = "${config.networking.hostName}.duckdns.org";

  # Random theme on each page load: pick ./html/random.html or ./html/kaleidoscope.html
  testPageFile = ./html/kaleidoscope.html;

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
