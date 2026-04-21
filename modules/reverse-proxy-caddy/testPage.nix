{ config, pkgs, ... }:

let
  domain = "${config.networking.hostName}.duckdns.org";

  # Default: random theme on each page load
  # Pin a specific theme by changing this to:
  #   ./html/geocities.html
  #   ./html/synthwave.html
  #   ./html/bootsequence.html
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
