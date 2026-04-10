{ config, ... }:
{
  services.caddy.virtualHosts."${config.networking.hostName}.duckdns.org" = {
    extraConfig = ''
      import security
      respond <<HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>${config.networking.hostName}</title>
        <style>
          :root{--bg:#030308;--fg:#e8ecf3;--muted:#9aa3b2}
          *{box-sizing:border-box}
          html,body{height:100%}
          body{
            margin:0;
            background:var(--bg);
            color:var(--fg);
            font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Ubuntu,"Helvetica Neue",Arial,sans-serif;
            display:grid;
            place-items:center;
            overflow:hidden;
          }
          body::before,body::after{
            content:"";
            position:fixed;
            inset:-20%;
            z-index:-2;
            background:
              radial-gradient(40% 35% at 20% 25%, rgba(124,140,255,0.35), transparent 60%),
              radial-gradient(35% 30% at 80% 75%, rgba(56,189,248,0.28), transparent 60%),
              radial-gradient(30% 25% at 50% 50%, rgba(168,85,247,0.22), transparent 60%);
            filter:blur(40px);
            animation:drift 40s ease-in-out infinite alternate;
          }
          body::after{
            animation-duration:55s;
            animation-direction:alternate-reverse;
            opacity:0.7;
          }
          @keyframes drift{
            0%{transform:translate3d(-4%,-3%,0) scale(1)}
            100%{transform:translate3d(4%,3%,0) scale(1.08)}
          }
          .noise{
            position:fixed;inset:0;pointer-events:none;z-index:-1;
            background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
            opacity:0.03;mix-blend-mode:soft-light;
          }
          .container{
            position:relative;
            padding:clamp(2.5rem,6vw,4rem) clamp(2.5rem,7vw,5rem);
            border-radius:28px;
            background:rgba(12,14,22,0.65);
            border:1px solid rgba(255,255,255,0.08);
            backdrop-filter:blur(24px);
            -webkit-backdrop-filter:blur(24px);
            box-shadow:0 30px 80px rgba(0,0,0,0.6),0 0 80px rgba(124,140,255,0.15),inset 0 1px 0 rgba(255,255,255,0.06);
            text-align:center;
            max-width:min(900px,92vw);
          }
          h1{
            margin:0;
            font-size:clamp(2.5rem,8vw,5.5rem);
            font-weight:700;
            letter-spacing:-0.02em;
            line-height:1.05;
            background:linear-gradient(180deg,#ffffff 0%,#b8c1ff 100%);
            -webkit-background-clip:text;
            background-clip:text;
            color:transparent;
            text-shadow:0 0 40px rgba(124,140,255,0.25);
          }
          .status{
            margin-top:1.75rem;
            display:inline-flex;
            align-items:center;
            gap:0.75rem;
            font-size:1.05rem;
            letter-spacing:0.08em;
            text-transform:uppercase;
            color:var(--muted);
          }
          .dot{
            width:10px;height:10px;border-radius:50%;
            background:#22c55e;
            box-shadow:0 0 12px rgba(34,197,94,0.8),0 0 24px rgba(34,197,94,0.4);
            animation:pulse 2.4s ease-in-out infinite;
          }
          @keyframes pulse{
            0%,100%{transform:scale(1);opacity:1}
            50%{transform:scale(1.35);opacity:0.7}
          }
        </style>
      </head>
      <body>
        <div class="noise"></div>
        <div class="container">
          <h1>${config.networking.hostName}</h1>
          <div class="status"><span class="dot"></span>System is online and secure</div>
        </div>
      </body>
      </html>
      HTML 200
    '';
  };
}
