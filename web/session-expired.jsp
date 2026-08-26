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
        body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: var(--paper); color: var(--ink); font-family: Georgia, 'Times New Roman', serif; }
        main { width: min(560px, 86vw); padding: 48px; border: 1px solid var(--line); background: #fff; }
        .eyebrow { font: 700 11px Arial, sans-serif; letter-spacing: .18em; }
        h1 { margin: 18px 0 12px; font-size: clamp(2.8rem, 8vw, 5.5rem); line-height: .9; letter-spacing: -.05em; }
        p { max-width: 420px; color: #555; font: 16px/1.6 Arial, sans-serif; }
        a { display: inline-block; margin-top: 18px; padding: 13px 18px; background: var(--ink); color: #fff; font: 700 13px Arial, sans-serif; text-decoration: none; }
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
