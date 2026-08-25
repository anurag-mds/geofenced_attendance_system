<%-- Shared navbar and sidebar styles for all authenticated pages. --%>
<style>
    :root {
        --flow-ink: #111;
        --flow-paper: #f5f5f2;
        --flow-line: rgba(17, 17, 17, .14);
        --flow-accent: #ef594c;
    }

    html { scroll-behavior: smooth; }

    body {
        animation: flow-arrive .52s cubic-bezier(.22, .61, .36, 1) both;
    }

    body::after {
        content: '';
        position: fixed;
        inset: 0;
        z-index: 3000;
        pointer-events: none;
        background: var(--flow-paper);
        opacity: 0;
        transform: scaleY(0);
        transform-origin: bottom;
    }

    body.flow-leaving::after {
        animation: flow-leave .34s cubic-bezier(.76, 0, .24, 1) forwards;
    }

    .page-content, main, .container, .profile-container {
        animation: flow-rise .62s .05s cubic-bezier(.22, .61, .36, 1) both;
    }

    @keyframes flow-arrive { from { opacity: 0; } to { opacity: 1; } }
    @keyframes flow-rise { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes flow-leave { from { opacity: 0; transform: scaleY(0); } to { opacity: .96; transform: scaleY(1); } }

    @media (prefers-reduced-motion: reduce) {
        html { scroll-behavior: auto; }
        body, .page-content, main, .container, .profile-container { animation: none; }
        body.flow-leaving::after { animation: none; opacity: 1; }
    }

    .app-navbar {
        background-color: #222;
        color: #fff;
        padding: 18px 30px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: sticky;
        top: 0;
        z-index: 1100;
    }

    .app-navbar-left {
        display: flex;
        align-items: center;
        gap: 15px;
    }

    .app-brand-block {
        display: flex;
        flex-direction: column;
        gap: 2px;
    }

    .app-navbar h2 {
        font-size: 22px;
        font-weight: 600;
        line-height: 1.2;
        color: #fff;
    }

    .app-dashboard-label {
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: #dfe7f1;
    }

    .app-menu-button {
        background: none;
        border: none;
        color: #fff;
        font-size: 28px;
        line-height: 1;
        cursor: pointer;
        padding: 4px 8px;
        border-radius: 6px;
    }

    .app-menu-button:hover {
        background: rgba(255, 255, 255, 0.12);
    }

    .app-navbar-right {
        display: flex;
        align-items: center;
        gap: 16px;
        font-size: 14px;
    }

    .app-logout-button {
        background-color: #e74c3c;
        color: #fff;
        padding: 9px 16px;
        border: none;
        border-radius: 5px;
        text-decoration: none;
        font-size: 14px;
    }

    .app-logout-button:hover {
        background-color: #c0392b;
    }

    body.dialog-open { overflow: hidden; }

    .logout-dialog[hidden] { display: none; }

    .logout-dialog { position: fixed; inset: 0; z-index: 2000; display: grid; place-items: center; padding: 20px; }
    .logout-dialog-backdrop { position: absolute; inset: 0; background: rgba(0, 0, 0, .72); backdrop-filter: blur(4px); }
    .logout-dialog-panel { position: relative; width: min(440px, 100%); padding: 34px; background: #fff; color: #171717; border: 1px solid #171717; box-shadow: 12px 12px 0 #000; }
    .logout-dialog-kicker { margin: 0 0 16px; font-size: 11px; letter-spacing: .16em; font-weight: 700; }
    .logout-dialog-panel h2 { margin: 0 0 10px; font-size: 28px; letter-spacing: -.02em; }
    .logout-dialog-panel p { line-height: 1.5; }
    .logout-dialog-close { position: absolute; top: 10px; right: 12px; border: 0; background: none; color: #171717; font-size: 26px; cursor: pointer; }
    .logout-dialog-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 26px; }
    .logout-dialog-cancel, .logout-dialog-confirm { width: 128px; height: 54px; display: inline-flex; align-items: center; justify-content: center; box-sizing: border-box; padding: 0; border: 1px solid #171717; font: inherit; line-height: 1; text-decoration: none; cursor: pointer; }
    .logout-dialog-cancel { background: #fff; color: #171717; }
    .logout-dialog-confirm { background: #171717; color: #fff; }

    .app-sidebar {
        position: fixed;
        top: 70px;
        left: 0;
        width: 230px;
        height: calc(100vh - 70px);
        background-color: #fff;
        border-right: 1px solid #ddd;
        padding: 25px 15px;
        transform: translateX(-100%);
        transition: transform 0.42s cubic-bezier(.22, .61, .36, 1), box-shadow .42s ease;
        z-index: 1000;
        overflow-y: auto;
    }

    .app-sidebar.open {
        transform: translateX(0);
        box-shadow: 16px 0 40px rgba(17, 17, 17, .12);
    }

    .app-sidebar-title {
        font-size: 13px;
        color: #888;
        text-transform: uppercase;
        margin-bottom: 15px;
        padding-left: 12px;
    }

    .app-sidebar a {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 14px 12px;
        margin-bottom: 6px;
        border-radius: 7px;
        text-decoration: none;
        color: #333;
        font-size: 15px;
        transition: background-color .25s ease, transform .25s ease, color .25s ease;
    }

    .app-sidebar a:hover,
    .app-sidebar a.active {
        background-color: #f0f2f5;
        transform: translateX(3px);
    }

    .notification-dot {
        width: 8px;
        height: 8px;
        margin-left: auto;
        border-radius: 50%;
        background: #e74c3c;
        display: inline-block;
    }

    .page-content {
        transition: margin-left .42s cubic-bezier(.22, .61, .36, 1);
    }

    .page-content.sidebar-open {
        margin-left: 230px;
    }

    @media (max-width: 900px) {
        .app-navbar {
            padding: 16px 20px;
        }

        .app-navbar h2 {
            font-size: 18px;
        }

        .app-navbar-right .user-name {
            display: none;
        }
    }
</style>
