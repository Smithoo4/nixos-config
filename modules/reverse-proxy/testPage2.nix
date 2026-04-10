{ config, ... }:
{
  services.caddy.virtualHosts."${config.networking.hostName}.duckdns.org" = {
    extraConfig = ''
      import security
      header Content-Type text/html
      respond <<HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <title>NODE: ${config.networking.hostName}</title>
          <style>
              body {
                  background-color: #1a1a1a;
                  background-image: radial-gradient(#333 10%, transparent 10%);
                  background-size: 20px 20px;
                  color: #00f2ff;
                  font-family: "Courier New", Courier, monospace;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  margin: 0;
                  text-transform: uppercase;
              }
              .console {
                  background: #2b2b2b;
                  border: 10px solid #444;
                  border-style: outset;
                  border-radius: 40px;
                  padding: 4rem;
                  box-shadow: 0 0 50px rgba(0,0,0,0.8), inset 0 0 20px rgba(0,0,0,0.5);
                  text-align: center;
                  position: relative;
              }
              /* Oscilloscope screen effect */
              .screen {
                  background: #001a1a;
                  border: 4px solid #111;
                  padding: 2rem;
                  border-radius: 10px;
                  box-shadow: inset 0 0 15px #00f2ff;
                  margin-bottom: 2rem;
              }
              h1 {
                  font-size: 2.5rem;
                  margin: 0;
                  letter-spacing: 4px;
                  color: #fff;
                  text-shadow: 0 0 10px #00f2ff;
              }
              .status-light {
                  width: 20px;
                  height: 20px;
                  background: #ff0000;
                  border-radius: 50%;
                  display: inline-block;
                  margin-right: 15px;
                  box-shadow: 0 0 10px #ff0000;
                  animation: blink 0.8s infinite;
              }
              .label {
                  font-size: 0.8rem;
                  color: #888;
                  margin-top: 10px;
                  display: block;
              }
              @keyframes blink {
                  0%, 100% { opacity: 1; filter: brightness(1.5); }
                  50% { opacity: 0.7; filter: brightness(0.8); }
              }
              .secure-msg {
                  font-weight: bold;
                  letter-spacing: 2px;
                  color: #00f2ff;
              }
          </style>
      </head>
      <body>
          <div class="console">
              <div class="screen">
                  <span class="label">TRANSISTOR NODE IDENTIFICATION</span>
                  <h1>${config.networking.hostName}</h1>
              </div>
              <div class="secure-msg">
                  <span class="status-light"></span>
                  System is online and secure
              </div>
              <span class="label">VACUUM TUBE ARRAY: OPERATIONAL</span>
          </div>
      </body>
      </html>
HTML 200
    '';
  };
}
