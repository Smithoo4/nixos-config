{ pkgs, config, ... }:

let
  tplinkrouterc6u = pkgs.python3Packages.buildPythonPackage rec {
    pname = "tplinkrouterc6u";
    version = "5.21.0";
    pyproject = true;
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-81gX4VvVwJkBRQUCbrzq3qJS+tsjPVF5ee7lPTxv19A=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    propagatedBuildInputs = with pkgs.python3Packages; [
      requests
      pycryptodome
      macaddress
    ];
    doCheck = false;
  };

  routerPython = pkgs.python3.withPackages (_: [ tplinkrouterc6u ]);

  pollRouterScript = pkgs.writeScript "poll-router" ''
    #!${routerPython}/bin/python3
    """Poll TP-Link AXE75 via tplinkrouterc6u - output InfluxDB line protocol."""

    import sys
    import time
    from tplinkrouterc6u import TplinkRouterProvider

    def read_secret(path):
        with open(path) as f:
            return f.read().strip()

    def main():
        router_ip = read_secret("/run/secrets/router-ip")
        router_pw = read_secret("/run/secrets/router-password")

        router = TplinkRouterProvider.get_client(f"http://{router_ip}", router_pw)
        try:
            router.authorize()
            s = router.get_status()
        except Exception as e:
            print(f"ERROR: {e}", file=sys.stderr)
            sys.exit(1)
        finally:
            try:
                router.logout()
            except Exception:
                pass

        ts = int(time.time() * 1e9)

        fields = []
        if s.cpu_usage is not None:
            fields.append(f"cpu_usage={s.cpu_usage}")
        if s.mem_usage is not None:
            fields.append(f"mem_usage={s.mem_usage}")
        if s.wan_ipv4_uptime is not None:
            fields.append(f"wan_uptime={s.wan_ipv4_uptime}i")
        if s.clients_total is not None:
            fields.append(f"clients_total={s.clients_total}i")
        if s.wired_total is not None:
            fields.append(f"wired_total={s.wired_total}i")
        if s.wifi_clients_total is not None:
            fields.append(f"wifi_clients_total={s.wifi_clients_total}i")
        if s.guest_clients_total is not None:
            fields.append(f"guest_clients_total={s.guest_clients_total}i")

        if fields:
            print(f"router_status {','.join(fields)} {ts}")

    if __name__ == "__main__":
        main()
  '';
in
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
  ];

  sops.secrets.router-ip = {
    owner = "telegraf";
    mode = "0400";
  };
  sops.secrets.router-password = {
    owner = "telegraf";
    mode = "0400";
  };

  services.telegraf.extraConfig.inputs.exec = {
    commands = [ "${pollRouterScript}" ];
    timeout = "30s";
    data_format = "influx";
    interval = "60s";
  };

  environment.systemPackages = [
    pkgs.jq
    routerPython
  ];
}
