{ pkgs, ... }:

let
  tplinkrouterc6u = pkgs.python3Packages.buildPythonPackage rec {
    pname = "tplinkrouterc6u";
    version = "5.21.0";
    pyproject = true;
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      hash = "";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    propagatedBuildInputs = with pkgs.python3Packages; [
      requests
      pycryptodome
    ];
    doCheck = false;
  };

  routerPython = pkgs.python3.withPackages (_: [ tplinkrouterc6u ]);
in
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
  ];

  # CLI tools for ISP monitoring
  environment.systemPackages = [
    pkgs.jq
    routerPython
  ];
}
