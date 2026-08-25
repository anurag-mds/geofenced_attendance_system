<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (!Boolean.TRUE.equals(request.getAttribute("logoutTransition"))) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signed out | Employee Attendance System</title>
    <style>
        :root { color-scheme: light; --ink: #111; --paper: #f5f5f2; --line: #c9c9c3; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; overflow: hidden; background: var(--paper); color: var(--ink); font-family: Georgia, 'Times New Roman', serif; }
        .logout-page { min-height: 100vh; display: grid; grid-template-columns: minmax(180px, 34vw) 1fr; position: relative; opacity: 0; transform: translateY(14px); transition: opacity .45s ease-out, transform .45s ease-out; }
        .logout-page.ready { opacity: 1; transform: translateY(0); }
        .logout-index { display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--ink); background: var(--ink); color: var(--paper); overflow: hidden; position: relative; }
        .logout-index:after { content: ''; position: absolute; width: 52vw; height: 52vw; max-width: 700px; max-height: 700px; border: 1px solid rgba(245,245,242,.42); border-radius: 50%; box-shadow: 0 0 0 26px rgba(245,245,242,.06), 0 0 0 52px rgba(245,245,242,.34), 0 0 0 78px rgba(245,245,242,.05); animation: orbit 9s linear infinite; }
        .logout-word { position: relative; z-index: 1; transform: rotate(-90deg) translateX(24px); font: 900 clamp(8rem, 24vw, 25rem)/.8 Arial, sans-serif; letter-spacing: -.1em; opacity: 0; transition: opacity .5s ease-out .08s, transform .5s ease-out .08s; }
        .logout-page.ready .logout-word { opacity: .94; transform: rotate(-90deg) translateX(0); }
        .logout-copy { display: flex; flex-direction: column; justify-content: center; padding: 8vw; position: relative; }
        .logout-copy:before { content: ''; position: absolute; width: 180px; height: 180px; top: 12%; right: 10%; border: 1px solid var(--ink); border-radius: 50%; box-shadow: 0 0 0 18px var(--paper), 0 0 0 19px var(--ink), 0 0 0 36px var(--paper), 0 0 0 37px var(--ink); opacity: .24; animation: pulse 3s ease-in-out infinite; }
        .eyebrow { font: 700 11px/1.2 Arial, sans-serif; letter-spacing: .2em; }
        h1 { max-width: 650px; margin: 22px 0 16px; font-size: clamp(3rem, 7vw, 7rem); line-height: .9; letter-spacing: -.06em; }
        p { max-width: 480px; margin: 0; font: 16px/1.6 Arial, sans-serif; color: #4d4d49; }
        .progress { width: min(430px, 100%); height: 1px; margin-top: 48px; background: var(--line); overflow: hidden; }
        .progress span { display: block; width: 100%; height: 100%; background: var(--ink); transform-origin: left; animation: progress 1.3s linear both; }
        .trace { position: absolute; bottom: 28px; left: 8vw; font: 11px Arial, sans-serif; letter-spacing: .08em; color: #777; }
        @keyframes logout-arrive { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes reveal { from { opacity: 0; transform: rotate(-90deg) translateX(40px); } to { opacity: .94; transform: rotate(-90deg) translateX(0); } }
        @keyframes orbit { to { transform: rotate(360deg); } }
        @keyframes pulse { 50% { transform: scale(1.08); opacity: .14; } }
        @keyframes progress { from { transform: scaleX(0); } to { transform: scaleX(1); } }
        @keyframes logout-exit { from { opacity: 1; } to { opacity: 0; transform: translateY(-10px); } }
        .logout-page.leaving { opacity: 0; transform: translateY(-10px); transition: opacity .45s ease-in, transform .45s ease-in; }
        @media (prefers-reduced-motion: reduce) { .logout-page, .logout-page.ready, .logout-page.leaving { transition: none; } .logout-word, .logout-page.ready .logout-word { opacity: .94; transform: rotate(-90deg) translateX(0) !important; transition: none; } * { animation-duration: .01ms !important; animation-iteration-count: 1 !important; } }
        @media (max-width: 700px) { body { overflow: auto; } .logout-page { grid-template-columns: 1fr; } .logout-index { min-height: 35vh; border-right: 0; border-bottom: 1px solid var(--ink); } .logout-index:after { width: 65vw; height: 65vw; } .logout-word { font-size: clamp(8rem, 25vw, 12rem); } .logout-page.ready .logout-word { transform: rotate(-90deg) translateX(0); } .logout-copy { min-height: 65vh; padding: 12vw 9vw; } .logout-copy:before { width: 100px; height: 100px; top: 8%; right: 8%; } .trace { left: 9vw; } }
    </style>
</head>
<body>
    <main class="logout-page" aria-live="polite">
        <div class="logout-index"><span class="logout-word">BYE</span></div>
        <section class="logout-copy">
            <div class="eyebrow">EMPLOYEE ATTENDANCE SYSTEM / SESSION NOTE</div>
            <h1>Session closed.</h1>
            <p>You have been securely signed out. The entrance will be ready in a moment.</p>
            <div class="progress" aria-hidden="true"><span></span></div>
            <div class="trace">STATUS 204 · SESSION RELEASED, RETURNING</div>
        </section>
    </main>
    <script>
        (function () {
            const loginUrl = '<%= request.getContextPath() %>/index.html';
            const page = document.querySelector('.logout-page');
            history.replaceState(null, '', loginUrl);
            window.addEventListener('popstate', function () { window.location.replace(loginUrl); });
            window.requestAnimationFrame(function () { page.classList.add('ready'); });
            window.setTimeout(function () {
                page.classList.add('leaving');
            }, 1050);
            window.setTimeout(function () { window.location.replace(loginUrl); }, 1500);
        }());
    </script>
</body>
</html>