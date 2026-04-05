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
              @keyframes gradient {
                  0% { background-position: 0% 50%; }
                  50% { background-position: 100% 50%; }
                  100% { background-position: 0% 50%; }
              }
              body {
                  margin: 0;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  background: linear-gradient(-45deg, #0f0c29, #302b63, #24243e, #000000);
                  background-size: 400% 400%;
                  animation: gradient 15s ease infinite;
                  font-family: "JetBrains Mono", monospace, system-ui;
                  color: white;
              }
              .glass-card {
                  background: rgba(255, 255, 255, 0.03);
                  backdrop-filter: blur(10px);
                  -webkit-backdrop-filter: blur(10px);
                  border: 1px solid rgba(255, 255, 255, 0.1);
                  border-radius: 20px;
                  padding: 3rem;
                  text-align: center;
                  box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.8);
              }
              h1 {
                  font-size: 3rem;
                  margin: 0;
                  letter-spacing: -2px;
                  text-transform: uppercase;
                  background: linear-gradient(to right, #fff, #58a6ff);
                  -webkit-background-clip: text;
                  -webkit-text-fill-color: transparent;
              }
              .status-line {
                  margin-top: 1rem;
                  font-size: 0.9rem;
                  color: #8b949e;
                  letter-spacing: 2px;
              }
              .pulse {
                  display: inline-block;
                  width: 8px;
                  height: 8px;
                  background: #00ff88;
                  border-radius: 50%;
                  margin-right: 10px;
                  box-shadow: 0 0 15px #00ff88;
              }
          </style>
      </head>
      <body>
          <div class="glass-card">
              <h1>${config.networking.hostName}</h1>
              <div class="status-line">
                  <span class="pulse"></span> ENCRYPTED LINK ACTIVE
              </div>
          </div>
      </body>
      </html>
HTML 200
    '';
  };
}
