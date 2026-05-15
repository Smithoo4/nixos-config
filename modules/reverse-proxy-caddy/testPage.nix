{ config, pkgs, ... }:

let
  domain = "${config.networking.hostName}.duckdns.org";

  testPageFile = ./html/random.html;

  webroot = pkgs.runCommand "caddy-test-page" { } ''
    mkdir -p $out
    substitute ${testPageFile} $out/index.html \
      --replace-fail "{{HOSTNAME}}" "${config.networking.hostName}"
  '';
in
{
  services.caddy.virtualHosts.${domain} = {
    extraConfig = ''
      root * ${webroot}
      file_server
    '';
  };
}
