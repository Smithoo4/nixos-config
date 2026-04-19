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
          <title>NODE // ${config.networking.hostName}</title>
          <style>
              :root {
                  --bg: #0a0a0a;
                  --text: #f0f0f0;
                  --accent: #ff3e00;
              }
              body {
                  margin: 0;
                  background-color: var(--bg);
                  color: var(--text);
                  font-family: "Inter", system-ui, -apple-system, sans-serif;
                  height: 100vh;
                  display: flex;
                  overflow: hidden;
                  letter-spacing: -0.02em;
              }
              /* Grain overlay */
              body::after {
                  content: "";
                  position: fixed;
                  top: 0; left: 0; width: 100%; height: 100%;
                  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3F%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
                  opacity: 0.05;
                  pointer-events: none;
                  z-index: 10;
              }
              .background-text {
                  position: absolute;
                  font-size: 30vw;
                  font-weight: 900;
                  color: rgba(255, 255, 255, 0.02);
                  white-space: nowrap;
                  top: 50%;
                  left: 50%;
                  transform: translate(-50%, -50%) rotate(-10deg);
                  user-select: none;
                  z-index: 1;
              }
              .content {
                  position: relative;
                  z-index: 2;
                  margin: auto 10%;
                  width: 100%;
              }
              .line {
                  width: 60px;
                  height: 4px;
                  background: var(--accent);
                  margin-bottom: 2rem;
              }
              h1 {
                  font-size: clamp(3rem, 10vw, 8rem);
                  line-height: 0.9;
                  margin: 0;
                  font-weight: 800;
                  text-transform: uppercase;
              }
              .status {
                  margin-top: 2rem;
                  display: flex;
                  align-items: center;
                  gap: 1rem;
                  font-family: monospace;
                  font-size: 1.2rem;
                  text-transform: uppercase;
                  color: #888;
              }
              .coord {
                  position: absolute;
                  bottom: 40px;
                  right: 40px;
                  font-family: monospace;
                  font-size: 0.8rem;
                  color: #444;
                  writing-mode: vertical-rl;
              }
          </style>
      </head>
      <body>
          <div class="background-text">${config.networking.hostName}</div>
          
          <div class="content">
              <div class="line"></div>
              <h1>${config.networking.hostName}</h1>
              <div class="status">
                  <span style="color: var(--accent)">[ LIVE ]</span>
                  System is online and secure
              </div>
          </div>

          <div class="coord">
              NETWORK_NODE_ID // ${config.networking.hostName} // 2026
          </div>
      </body>
      </html>
HTML 200
    '';
  };
}
