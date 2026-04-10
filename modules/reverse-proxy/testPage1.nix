{ config, ... }:
{
  services.caddy.virtualHosts."${config.networking.hostName}.duckdns.org" = {
    extraConfig = ''
      import security

      handle {
        respond <<HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <title>${config.networking.hostName}</title>
          <style>
            :root{--bg:#030308;--fg:#e8ecf3;--muted:#9aa3b2}
            html,body{height:100%}
            body{margin:0;background:var(--bg);color:var(--fg);font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;display:grid;place-items:center;overflow:hidden}
            body::before{content:"";position:fixed;inset:-20%;z-index:-2;background:radial-gradient(40% 35% at 20% 25%,rgba(124,140,255,.35),transparent 60%),radial-gradient(35% 30% at 80% 75%,rgba(56,189,248,.28),transparent 60%);filter:blur(40px);animation:drift 40s ease-in-out infinite alternate}
            @keyframes drift{to{transform:translate3d(4%,3%,0) scale(1.08)}}
            .card{padding:4rem 5rem;border-radius:28px;background:rgba(12,14,22,.65);border:1px solid rgba(255,255,255,.08);backdrop-filter:blur(24px);box-shadow:0 30px 80px rgba(0,0,0,.6),0 0 80px rgba(124,140,255,.15);text-align:center}
            h1{margin:0;font-size:clamp(2.5rem,8vw,5.5rem);font-weight:700;background:linear-gradient(180deg,#fff,#b8c1ff);-webkit-background-clip:text;background-clip:text;color:transparent}
            .status{margin-top:1.5rem;color:var(--muted);text-transform:uppercase;letter-spacing:.08em;display:inline-flex;gap:.6rem;align-items:center}
            .dot{width:10px;height:10px;border-radius:50%;background:#22c55e;box-shadow:0 0 12px rgba(34,197,94,.8);animation:p 2.4s infinite}
            @keyframes p{50%{transform:scale(1.3);opacity:.7}}
          </style>
        </head>
        <body>
          <div class="card">
            <h1>${config.networking.hostName}</h1>
            <div class="status"><span class="dot"></span>System is online and secure</div>
          </div>
        </body>
        </html>
        HTML 200 {
          header Content-Type "text/html; charset=utf-8"
        }
      }
    '';
  };
}
