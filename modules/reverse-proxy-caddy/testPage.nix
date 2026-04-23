{ config, pkgs, ... }:

let
  domain = "${config.networking.hostName}.duckdns.org";

  # Random theme on each page load: pick ./html/random.html or ./html/kaleidoscope.html
  testPageFile = ./html/random.html;

  webroot = pkgs.runCommand "caddy-test-page" {} ''
    mkdir -p $out
    substitute ${testPageFile} $out/index.html \
      --replace-fail "{{HOSTNAME}}" "${config.networking.hostName}"
  '';
in
{
  services.caddy.virtualHosts.${domain} = {
    extraConfig = ''
      import security
      root * ${webroot}
      file_server
    '';
  };
}
