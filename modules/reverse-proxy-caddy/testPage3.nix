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
          <title>${config.networking.hostName}</title>
          <style>
              body {
                  margin: 0;
                  background: #050505;
                  color: #00ff41;
                  font-family: "Courier New", Courier, monospace;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  overflow: hidden;
              }
              /* Scanline effect */
              body::before {
                  content: " ";
                  position: absolute;
                  top: 0; left: 0; bottom: 0; right: 0;
                  background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%), 
                              linear-gradient(90deg, rgba(255, 0, 0, 0.06), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));
                  background-size: 100% 2px, 3px 100%;
                  z-index: 2;
                  pointer-events: none;
              }
              .container {
                  text-align: center;
                  border: 2px solid #00ff41;
                  padding: 4rem;
                  box-shadow: 0 0 20px #00ff41, inset 0 0 20px #00ff41;
                  position: relative;
                  z-index: 1;
              }
              h1 {
                  font-size: 3.5rem;
                  margin: 0;
                  text-transform: uppercase;
                  letter-spacing: 10px;
                  text-shadow: 0 0 10px #00ff41;
              }
              p {
                  margin-top: 2rem;
                  font-size: 1.2rem;
                  letter-spacing: 2px;
                  opacity: 0.8;
              }
              .flicker {
                  animation: pulse 2s infinite;
              }
              @keyframes pulse {
                  0% { opacity: 1; }
                  50% { opacity: 0.4; }
                  100% { opacity: 1; }
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>${config.networking.hostName}</h1>
              <p class="flicker">System is online and secure</p>
          </div>
      </body>
      </html>
HTML 200
    '';
  };
}
