<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    if (statusCode == null) { statusCode = 500; }
    String title = statusCode == 403 ? "Access denied" : statusCode == 404 ? "Page not found" : statusCode == 500 ? "A quiet malfunction" : "Something went sideways";
    String detail = statusCode == 403 ? "This area is reserved for another role." : statusCode == 404 ? "The page you are looking for moved, vanished, or never existed." : statusCode == 500 ? "The system hit an unexpected pause. Your data remains safe." : "The request could not be completed, but the system is still standing.";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= statusCode %> | Employee Attendance System</title>
    <style>
        :root { color-scheme: light; --ink: #111; --paper: #f5f5f2; --line: #c9c9c3; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; overflow: hidden; background: var(--paper); color: var(--ink); font-family: Georgia, 'Times New Roman', serif; }
        .error-page { min-height: 100vh; display: grid; grid-template-columns: minmax(180px, 34vw) 1fr; position: relative; animation: error-arrive .7s cubic-bezier(.22, .61, .36, 1) both; }
        .error-index { display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--ink); background: var(--ink); color: var(--paper); font: 900 clamp(8rem, 24vw, 25rem)/.8 Arial, sans-serif; letter-spacing: -.1em; overflow: hidden; }
        .error-index span { transform: rotate(-90deg); opacity: .94; }
        .error-copy { display: flex; flex-direction: column; justify-content: center; padding: 8vw; position: relative; }
        .error-copy:before { content: ''; position: absolute; width: 180px; height: 180px; top: 11%; right: 9%; border: 1px solid var(--ink); border-radius: 50%; box-shadow: 0 0 0 18px var(--paper), 0 0 0 19px var(--ink), 0 0 0 36px var(--paper), 0 0 0 37px var(--ink); opacity: .25; }
        .eyebrow { font: 700 11px/1.2 Arial, sans-serif; letter-spacing: .2em; }
        h1 { max-width: 650px; margin: 22px 0 16px; font-size: clamp(3rem, 7vw, 7rem); line-height: .9; letter-spacing: -.06em; }
        .detail { max-width: 480px; margin: 0 0 34px; font: 16px/1.6 Arial, sans-serif; color: #4d4d49; }
        .home-link { display: inline-block; width: fit-content; padding: 13px 18px; border: 1px solid var(--ink); background: var(--ink); color: var(--paper); font: 700 13px Arial, sans-serif; text-decoration: none; }
        .home-link:hover { background: transparent; color: var(--ink); }
        .trace { position: absolute; bottom: 28px; left: 8vw; font: 11px Arial, sans-serif; letter-spacing: .08em; color: #777; }
        @keyframes error-arrive { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: translateY(0); } }
        @media (prefers-reduced-motion: reduce) { .error-page { animation: none; } }
        @media (max-width: 700px) { body { overflow: auto; } .error-page { min-height: 100vh; grid-template-columns: 1fr; } .error-index { min-height: 35vh; border-right: 0; border-bottom: 1px solid var(--ink); } .error-index span { transform: none; } .error-copy { min-height: 65vh; padding: 12vw 9vw; } .error-copy:before { width: 100px; height: 100px; top: 8%; right: 8%; } .trace { left: 9vw; } }
    </style>
</head>
<body>
    <main class="error-page">
        <div class="error-index"><span><%= statusCode %></span></div>
        <section class="error-copy">
            <div class="eyebrow">EMPLOYEE ATTENDANCE SYSTEM / SYSTEM NOTE</div>
            <h1><%= title %></h1>
            <p class="detail"><%= detail %></p>
            <a class="home-link" href="<%= request.getContextPath() %>/index.html">Return to the entrance</a>
            <div class="trace">STATUS <%= statusCode %> · REQUEST RECEIVED, RECOVERY READY</div>
        </section>
    </main>
</body>
</html>