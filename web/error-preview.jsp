<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    int statusCode = 500;
    try {
        statusCode = Integer.parseInt(request.getParameter("status"));
    } catch (Exception ignored) {
    }
    if (statusCode != 403 && statusCode != 404 && statusCode != 500) { statusCode = 500; }
    String title = statusCode == 403 ? "Access denied" : statusCode == 404 ? "Page not found" : "A quiet malfunction";
    String detail = statusCode == 403 ? "This area is reserved for another role." : statusCode == 404 ? "The page you are looking for moved, vanished, or never existed." : "The system hit an unexpected pause. Your data remains safe.";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 | Employee Attendance System</title>
    <style>
        :root { color-scheme: light; --ink: #111; --paper: #f5f5f2; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; overflow: hidden; background: var(--paper); color: var(--ink); font-family: Georgia, 'Times New Roman', serif; }
        .error-page { min-height: 100vh; display: grid; grid-template-columns: minmax(180px, 34vw) 1fr; }
        .error-index { display: flex; align-items: center; justify-content: center; background: var(--ink); color: var(--paper); font: 900 clamp(8rem, 24vw, 25rem)/.8 Arial, sans-serif; letter-spacing: -.1em; overflow: hidden; }
        .error-index span { transform: rotate(-90deg); }
        .error-copy { display: flex; flex-direction: column; justify-content: center; padding: 8vw; position: relative; }
        .error-copy:before { content: ''; position: absolute; width: 180px; height: 180px; top: 11%; right: 9%; border: 1px solid var(--ink); border-radius: 50%; box-shadow: 0 0 0 18px var(--paper), 0 0 0 19px var(--ink), 0 0 0 36px var(--paper), 0 0 0 37px var(--ink); opacity: .25; }
        .eyebrow { font: 700 11px/1.2 Arial, sans-serif; letter-spacing: .2em; }
        h1 { max-width: 650px; margin: 22px 0 16px; font-size: clamp(3rem, 7vw, 7rem); line-height: .9; letter-spacing: -.06em; }
        .detail { max-width: 480px; margin: 0 0 34px; font: 16px/1.6 Arial, sans-serif; color: #4d4d49; }
        .home-link { display: inline-block; width: fit-content; padding: 13px 18px; border: 1px solid var(--ink); background: var(--ink); color: var(--paper); font: 700 13px Arial, sans-serif; text-decoration: none; }
        .home-link:hover { background: transparent; color: var(--ink); }
        @media (max-width: 700px) { body { overflow: auto; } .error-page { grid-template-columns: 1fr; } .error-index { min-height: 35vh; } .error-index span { transform: none; } .error-copy { min-height: 65vh; padding: 12vw 9vw; } }
    </style>
</head>
<body>
    <main class="error-page">
        <div class="error-index"><span><%= statusCode %></span></div>
        <section class="error-copy">
            <div class="eyebrow">EMPLOYEE ATTENDANCE SYSTEM / PREVIEW</div>
            <h1><%= title %></h1>
            <p class="detail"><%= detail %></p>
            <a class="home-link" href="<%= request.getContextPath() %>/index.html">Return to the entrance</a>
        </section>
    </main>
</body>
</html>
