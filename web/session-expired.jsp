<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="8;url=<%= request.getContextPath() %>/index.html">
    <title>Session ended | Employee Attendance System</title>
    <style>
        :root { --ink: #171717; --paper: #f5f5f2; --line: #c9c9c3; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: var(--paper); color: var(--ink); font-family: Georgia, 'Times New Roman', serif; overflow: hidden; }
        body:before, body:after { content: ''; position: fixed; width: 28vw; aspect-ratio: 1; border: 1px solid var(--line); border-radius: 50%; pointer-events: none; animation: float 8s ease-in-out infinite alternate; }
        body:before { top: -12vw; right: -8vw; }
        body:after { bottom: -16vw; left: -10vw; animation-delay: -3s; }
        main { position: relative; width: min(560px, 86vw); padding: 48px; border: 1px solid var(--line); background: #fff; animation: arrive .65s cubic-bezier(.22,.61,.36,1) both; }
        .eyebrow { font: 700 11px Arial, sans-serif; letter-spacing: .18em; }
        h1 { margin: 18px 0 12px; font-size: clamp(2.8rem, 8vw, 5.5rem); line-height: .9; letter-spacing: -.05em; }
        p { max-width: 420px; color: #555; font: 16px/1.6 Arial, sans-serif; }
        a { display: inline-block; margin-top: 18px; padding: 13px 18px; background: var(--ink); color: #fff; font: 700 13px Arial, sans-serif; text-decoration: none; }
        @keyframes arrive { from { opacity: 0; transform: translateY(18px) rotate(-1deg); } to { opacity: 1; transform: translateY(0) rotate(0); } }
        @keyframes float { to { transform: translate(16px, 12px) rotate(12deg); } }
        @media (prefers-reduced-motion: reduce) { *, *:before, *:after { animation: none !important; } }
    </style>
</head>
<body>
    <main>
        <div class="eyebrow">EMPLOYEE ATTENDANCE SYSTEM / SESSION CONTROL</div>
        <h1>Your session ended.</h1>
        <p>For your security, this inactive session was closed. You will be taken to the login page shortly.</p>
        <a href="<%= request.getContextPath() %>/index.html">Continue to login</a>
    </main>
</body>
</html>
