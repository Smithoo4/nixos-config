{ config, ... }:
{
  services.caddy.virtualHosts."${config.networking.hostName}.duckdns.org" = {
    extraConfig = ''
      import security
      header Content-Type text/html; charset=utf-8

      respond <<HTML
      <!DOCTYPE html>
      <html>
      <head>
      <meta charset="UTF-8">
      <title>${config.networking.hostName} - My Geocities Homepage!!!</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <style>
        body {
          background-color:#c0c0c0;
          background-image:
            linear-gradient(45deg, #b9b9b9 25%, transparent 25%),
            linear-gradient(-45deg, #b9b9b9 25%, transparent 25%),
            linear-gradient(45deg, transparent 75%, #b9b9b9 75%),
            linear-gradient(-45deg, transparent 75%, #b9b9b9 75%);
          background-size:4px 4px;
          margin:0;
          padding:10px;
          cursor: crosshair;
        }
        .blink {
          animation: blinky 0.8s steps(2,start) infinite;
          color:#ff0000;
          font-weight:bold;
          font-family:"Comic Sans MS", cursive;
        }
        @keyframes blinky { to { visibility:hidden; } }
        h1.geocities {
          font-family:Impact,"Comic Sans MS",cursive;
          font-size:68px;
          color:#0099ff;
          margin:6px 0;
          letter-spacing:5px;
          text-shadow:
            -3px -3px 0 #ffff00,
             3px -3px 0 #ffff00,
            -3px 3px 0 #ffff00,
             3px 3px 0 #ffff00,
            -3px 0 0 #ffff00,
             3px 0 0 #ffff00,
             0 -3px 0 #ffff00,
             0 3px 0 #ffff00,
             6px 6px 0 #000;
          transform:skewX(-8deg) scaleY(1.1);
        }
        .header-bg {
          background:linear-gradient(90deg,#ff0000,#ff7f00,#ffff00,#00ff00,#00ffff,#0000ff,#ff00ff,#ff0000);
          background-size:1200% 100%;
          animation:slide 6s linear infinite;
        }
        @keyframes slide { from{background-position:0% 0;} to{background-position:1000% 0;} }
        .stars {
          background-color:#000080;
          background-image:
            radial-gradient(#ffffff 1.2px, transparent 1.2px),
            radial-gradient(#ffff00 1px, transparent 1px);
          background-size:36px 36px, 36px 36px;
          background-position:0 0,18px 18px;
        }
        a:link{color:#0000ff;text-decoration:underline;}
        a:visited{color:#800080;}
        a:hover{color:#ff0000;background:#ffff00;}
        hr.funky1{border:0;height:7px;background:#ff00ff;box-shadow:inset 0 2px 0 #fff,inset 0 -2px 0 #000;margin:8px 0;}
        hr.funky2{border:3px ridge #00ff00;background:#00ff00;height:8px;margin:8px 0;}
        hr.funky3{border:0;height:10px;background:repeating-linear-gradient(90deg,#ffff00 0 12px,#ff0000 12px 24px);margin:8px 0;}
        .counter{font-family:"Courier New",monospace;background:#000;color:#00ff00;padding:3px 8px;border:3px inset #666;letter-spacing:4px;font-weight:bold;}
        table{border-collapse:separate;}
        @media(max-width:640px){
          h1.geocities{font-size:44px;}
          td{display:block!important;width:100%!important;}
        }
      </style>
      </head>
      <body>
      <center>
      <table border="6" cellpadding="4" cellspacing="3" width="800" bgcolor="#c0c0c0" style="max-width:95%;border:6px outset #e6e6e6;">

        <tr>
          <td colspan="2" align="center" class="header-bg" style="border:5px ridge #ff00ff;padding:8px;">
            <h1 class="geocities">${config.networking.hostName}</h1>
          </td>
        </tr>

        <tr>
          <td colspan="2" bgcolor="#000000" style="border:4px outset #00ff00;padding:2px;">
            <marquee scrollamount="7" behavior="alternate" onmouseover="this.stop()" onmouseout="this.start()">
              <font face="Comic Sans MS" color="#ffff00" size="4"><b>WELCOME TO MY HOMEPAGE!!! System is online and secure !!! Last updated: TODAY</b></font>
            </marquee>
          </td>
        </tr>

        <tr>
          <td width="190" valign="top" bgcolor="#00ffff" style="border:4px outset #ff00ff;padding:8px;">
            <center>
              <font face="Impact" size="5" color="#ff0000"><u>NAVIGATION</u></font>
            </center>
            <ul>
              <li><a href="#"><font face="Arial" size="3" color="blue">Home</font></a> <span class="blink">NEW!</span></li>
              <li><a href="#"><font face="Arial" size="3" color="blue">About Me</font></a></li>
              <li><a href="#"><font face="Arial" size="3" color="blue">Links</font></a></li>
              <li><a href="#"><font face="Arial" size="3" color="blue">Guestbook</font></a> <span class="blink">NEW!</span></li>
            </ul>
            <hr color="#0000ff" size="4" noshade>
            <center>
              <font face="Arial" size="2" color="#000080"><b>You are visitor No.</b></font><br>
              <table border="3" cellpadding="2" cellspacing="0" bgcolor="#000000" style="border:3px inset #333;margin-top:4px;">
                <tr><td align="center"><span class="counter">0001337</span></td></tr>
              </table>
            </center>
            <br>
            <center>
              <div style="width:160px;height:32px;background:repeating-linear-gradient(45deg,#ffff00 0 11px,#000000 11px 22px);border:3px solid #000;box-shadow:2px 2px 0 #fff;">
                <font face="Impact" color="#ff0000" size="3">UNDER CONSTRUCTION</font>
              </div>
            </center>
            <br>
            <center>
              <img width="88" height="31" alt="Netscape Now" src="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='88' height='31'><rect width='88' height='31' fill='%23c0c0c0' stroke='%23000' stroke-width='2'/><text x='44' y='13' font-family='Arial Black' font-size='9' fill='%230000ff' text-anchor='middle'>NETSCAPE</text><text x='44' y='25' font-family='Arial Black' font-size='9' fill='%23ff0000' text-anchor='middle'>NOW!</text></svg>" style="border:2px outset #fff;">
              <br><font size="1" face="Arial" color="#000">best viewed 800x600</font>
            </center>
          </td>

          <td valign="top" bgcolor="#ffffff" style="border:4px inset #0000ff;padding:6px;">
            <table width="100%" border="3" cellpadding="8" cellspacing="0" style="border:3px outset #ffff00;" bgcolor="#000000">
              <tr>
                <td class="stars" style="border:4px groove #00ffff;">
                  <font face="Comic Sans MS" size="6" color="#ffff00"><b><i>*** WELCOME 2 MY CYBER PAD!!! ***</i></b></font>
                  <br><br>
                  <font face="Arial" size="3" color="#00ff00">Hi!!! I'm the <font color="#ff00ff"><b>WEBMASTER</b></font> and u just entered my <font color="#00ffff"><u>ULTIMATE</u></font> homepage!!! I coded this ALL BY HAND in Notepad on Windows 95!!!</font> <span class="blink">NEW!</span>

                  <hr class="funky1">

                  <font face="Comic Sans MS" size="4" color="#ff00ff"><b>This site is</b> <font color="#ffff00">100% FREE</font> <b>of Java, so it loads SUPER FAST!!!</b></font>
                  <br>
                  <font face="Courier New" size="2" color="#ffffff">Optimized for 256 colors and dial-up 28.8k</font>

                  <hr class="funky2">

                  <table border="2" cellpadding="4" cellspacing="2" width="100%" bgcolor="#ff00ff" style="border:3px outset #fff;">
                    <tr><td bgcolor="#ffff00" align="center"><font face="Impact" size="4" color="#ff0000">HOT LINKS!!!</font></td></tr>
                    <tr><td bgcolor="#00ffff"><font face="Comic Sans MS" size="3" color="#000080">» My Top 10 MIDI Files (x-files, mortal kombat)</font></td></tr>
                    <tr><td bgcolor="#00ff00"><font face="Comic Sans MS" size="3" color="#000080">» Pictures of my CAT Whiskers!!!</font> <span class="blink">NEW!</span></td></tr>
                    <tr><td bgcolor="#ff99ff"><font face="Comic Sans MS" size="3" color="#000080">» My DragonBall Z fanfic!!!</font></td></tr>
                  </table>

                  <hr class="funky3">

                  <center>
                    <font face="Arial" size="3" color="#ffffff">Please sign my </font>
                    <a href="#"><font face="Comic Sans MS" size="4" color="#00ffff"><b>GUESTBOOK</b></font></a>
                    <font face="Arial" size="3" color="#ffffff">!!!</font>
                    <br>
                    <a href="mailto:webmaster@geocities.com">
                      <img alt="email me" width="120" height="32" src="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='32'><rect width='120' height='32' fill='%230000ff' stroke='%23ffff00' stroke-width='3'/><text x='60' y='21' font-family='Comic Sans MS' font-size='14' fill='%23ffff00' text-anchor='middle'>E-MAIL ME!</text></svg>" style="margin-top:6px;border:3px outset #c0c0c0;">
                    </a>
                  </center>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <tr>
          <td colspan="2" align="center" bgcolor="#c0c0c0" style="border:5px outset #ffffff;padding:8px;">
            <font face="Comic Sans MS" size="3" color="#000080"><b>~*~ MY WEBRING CREW ~*~</b></font><br>
            <marquee scrollamount="3" width="80%">
              <img src="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='88' height='31'><rect width='88' height='31' fill='%2300ffff'/><text x='44' y='20' font-family='Arial' font-size='11' fill='black' text-anchor='middle' font-weight='bold'>COOL</text></svg>" width="88" height="31" style="border:2px outset #fff;margin:2px;">
              <img src="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='88' height='31'><rect width='88' height='31' fill='%23ff00ff'/><text x='44' y='20' font-family='Arial' font-size='11' fill='yellow' text-anchor='middle' font-weight='bold'>90s</text></svg>" width="88" height="31" style="border:2px outset #fff;margin:2px;">
              <img src="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='88' height='31'><rect width='88' height='31' fill='%23ffff00'/><text x='44' y='20' font-family='Arial' font-size='11' fill='red' text-anchor='middle' font-weight='bold'>WEB</text></svg>" width="88" height="31" style="border:2px outset #fff;margin:2px;">
              <img src="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='88' height='31'><rect width='88' height='31' fill='%2300ff00'/><text x='44' y='20' font-family='Arial' font-size='11' fill='black' text-anchor='middle' font-weight='bold'>RULEZ</text></svg>" width="88" height="31" style="border:2px outset #fff;margin:2px;">
              <img src="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='88' height='31'><rect width='88' height='31' fill='%23ff0000'/><text x='44' y='20' font-family='Arial' font-size='11' fill='white' text-anchor='middle' font-weight='bold'>Y2K</text></svg>" width="88" height="31" style="border:2px outset #fff;margin:2px;">
            </marquee>
            <br>
            <font face="Times New Roman" size="2" color="#800000"><i>This page created on 08/15/1998 and still rocking! Proudly hosted on GeoCities Area51</i></font>
          </td>
        </tr>

      </table>
      </center>
      </body>
      </html>
      HTML 200
    '';
  };
}
