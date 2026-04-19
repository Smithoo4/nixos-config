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
          <title>Welcome to ${config.networking.hostName}'s Home Page!</title>
          <style>
              body {
                  background-color: #000080;
                  background-image: url('https://www.transparenttextures.com/patterns/stardust.png');
                  color: #ffff00;
                  font-family: "Comic Sans MS", "Comic Sans", cursive, sans-serif;
                  margin: 0;
                  padding: 20px;
                  text-align: center;
              }
              table {
                  border: 5px outset #808080;
                  background-color: #c0c0c0;
                  color: #000;
                  margin: 20px auto;
                  padding: 10px;
                  width: 80%;
                  max-width: 600px;
              }
              .blink {
                  animation: blinker 1s linear infinite;
                  color: #ff0000;
                  font-weight: bold;
              }
              @keyframes blinker {
                  50% { opacity: 0; }
              }
              marquee {
                  background-color: #00ff00;
                  color: #000;
                  font-weight: bold;
                  padding: 5px;
                  border: 2px inset #fff;
              }
              .counter {
                  background: #000;
                  color: #00ff00;
                  font-family: "Courier New", monospace;
                  padding: 5px 10px;
                  border: 2px silver gray;
                  display: inline-block;
                  margin-top: 10px;
              }
              h1 {
                  font-size: 2.5rem;
                  text-shadow: 3px 3px #ff00ff;
              }
              .under-construction {
                  border: 3px yellow dashed;
                  padding: 10px;
                  margin: 10px;
                  display: inline-block;
              }
          </style>
      </head>
      <body>
          <h1>*** ${config.networking.hostName} ***</h1>

          <div class="under-construction">
              <span class="blink">NEW!</span>
              <marquee scrollamount="10">System is online and secure --- System is online and secure</marquee>
          </div>

          <table>
              <tr>
                  <td>
                      <p>Welcome to my server! You have reached the digital home of <b>${config.networking.hostName}</b>.</p>
                      <hr>
                      <p>STATUS: <span style="color: blue; text-decoration: underline;">OPERATIONAL</span></p>
                      <p>This site is best viewed in Netscape Navigator 4.0 at 800x600 resolution!</p>
                  </td>
              </tr>
          </table>

          <p>Visitor Number:</p>
          <div class="counter">000042</div>

          <p><br>Last Updated: April 9, 2026</p>
      </body>
      </html>
HTML 200
    '';
  };
}
