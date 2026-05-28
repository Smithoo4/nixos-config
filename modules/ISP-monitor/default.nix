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

    def escape_tag(value):
        """Escape special characters in InfluxDB line protocol tag values."""
        s = str(value)
        s = s.replace(" ", "\\ ")
        s = s.replace(",", "\\,")
        s = s.replace("=", "\\=")
        return s

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

        # --- Router-level metrics ---
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

        # Total traffic across all devices
        total_traffic = sum(d.traffic_usage for d in s.devices if d.traffic_usage is not None)
        fields.append(f"total_traffic={total_traffic}i")

        if fields:
            print(f"router_status {','.join(fields)} {ts}")

        # --- Per-device metrics ---
        for d in s.devices:
            dev_fields = []

            if d.traffic_usage is not None:
                dev_fields.append(f"traffic_usage={d.traffic_usage}i")
            if d.packets_sent is not None:
                dev_fields.append(f"packets_sent={d.packets_sent}i")
            if d.packets_received is not None:
                dev_fields.append(f"packets_received={d.packets_received}i")
            if d.signal is not None:
                dev_fields.append(f"signal={d.signal}i")

            if dev_fields:
                mac = escape_tag(d.macaddr)
                hostname = escape_tag(d.hostname)
                conn_type = escape_tag(str(d.type).replace("Connection.", ""))
                print(f"router_device,mac={mac},hostname={hostname},type={conn_type} {','.join(dev_fields)} {ts}")

    if __name__ == "__main__":
        main()
  '';
in
{
  imports = [
    ./victoriametrics.nix
    ./telegraf.nix
  ];

  # Router credentials for polling script
  sops.secrets.router-ip = {
    owner = "telegraf";
    mode = "0400";
  };
  sops.secrets.router-password = {
    owner = "telegraf";
    mode = "0400";
  };

  # Router polling via Telegraf exec input
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
