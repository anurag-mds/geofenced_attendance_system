<%-- Shared navbar and sidebar styles for all authenticated pages. --%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" crossorigin="anonymous" referrerpolicy="no-referrer">

<style>
    :root {
        --app-font: 'Montserrat', 'Segoe UI', sans-serif;
        --app-header-bg: #2a2a32;
        --app-header-text: #ffffff;
        --app-sidebar-bg: #ffffff;
        --app-border: #e5e7eb;
        --app-text: #1f2937;
        --app-muted: #6b7280;
        --app-bg: #f3f5f7;
        --app-accent: #e74c3c;
    }

    html {
        scroll-behavior: smooth;
    }

    body,
    body * {
        font-family: var(--app-font);
    }

    h1, h2, h3, h4, h5, h6,
    .app-navbar h2,
    .app-dashboard-label,
    .user-name,
    .logout-dialog-panel h2,
    .option h2,
    .welcome h1,
    .card h2,
    .request-count,
    .btn {
        font-family: var(--app-font);
        letter-spacing: -0.04em;
    }

    body {
        margin: 0;
        background: var(--app-bg);
        color: var(--app-text);
    }

    .app-navbar {
        background: var(--app-header-bg);
        color: var(--app-header-text);
        padding: 12px 22px;
        height: 72px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: sticky;
        top: 0;
        z-index: 1100;
        box-sizing: border-box;
    }

    .app-navbar-left {
        display: flex;
        align-items: center;
        gap: 14px;
    }

    .app-brand-block {
        display: flex;
        flex-direction: column;
        justify-content: center;
        gap: 2px;
        line-height: 1.15;
    }

    .app-navbar h2 {
        margin: 0;
        font-size: 20px;
        font-weight: 700;
        line-height: 1.2;
        color: var(--app-header-text);
        letter-spacing: -0.02em;
    }

    .app-dashboard-label {
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 0.12em;
        color: rgba(255, 255, 255, 0.82);
    }

    .app-menu-button {
        background: transparent;
        border: 0;
        color: var(--app-header-text);
        cursor: pointer;
        width: 36px;
        height: 36px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: background-color 0.2s ease;
    }

    .app-menu-button svg {
        width: 20px;
        height: 20px;
        display: block;
    }

    .app-menu-button:hover {
        background: rgba(255, 255, 255, 0.09);
    }

    .app-navbar-right {
        display: flex;
        align-items: center;
        gap: 14px;
        font-size: 14px;
    }

    .app-header-notifications {
        position: relative;
        width: 36px;
        height: 36px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: var(--app-header-text);
        border-radius: 6px;
        text-decoration: none;
        font-size: 17px;
        transition: background-color 0.2s ease;
    }

    .app-header-notifications:hover {
        background: rgba(255, 255, 255, 0.09);
    }

    .app-notification-badge {
        position: absolute;
        top: 1px;
        right: 0;
        min-width: 16px;
        height: 16px;
        padding: 0 4px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-sizing: border-box;
        border: 2px solid var(--app-header-bg);
        border-radius: 999px;
        background: #dc2626;
        color: #fff;
        font-size: 9px;
        font-weight: 700;
        line-height: 1;
    }

    .user-name {
        color: var(--app-header-text);
        font-weight: 600;
        font-size: 14px;
    }

    .app-logout-button {
        background: var(--app-accent);
        color: #fff;
        padding: 9px 16px;
        border: none;
        border-radius: 6px;
        text-decoration: none;
        font-size: 14px;
        font-weight: 600;
        line-height: 1;
        transition: background-color 0.2s ease;
    }

    .app-logout-button:hover {
        background: #c63f33;
    }

    body.dialog-open {
        overflow: hidden;
    }

    .logout-dialog[hidden] {
        display: none;
    }

    .logout-dialog {
        position: fixed;
        inset: 0;
        z-index: 2000;
        display: grid;
        place-items: center;
        padding: 20px;
    }

    .logout-dialog-backdrop {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.72);
    }

    .logout-dialog-panel {
        position: relative;
        width: min(440px, 100%);
        padding: 30px 28px 24px;
        background: #fff;
        color: #171717;
        border: 1px solid #171717;
        box-shadow: 10px 10px 0 #000;
    }

    .logout-dialog-kicker {
        margin: 0 0 14px;
        font-size: 11px;
        letter-spacing: 0.16em;
        font-weight: 700;
    }

    .logout-dialog-panel h2 {
        margin: 0 0 10px;
        font-size: 28px;
        letter-spacing: -0.02em;
    }

    .logout-dialog-panel p {
        margin: 0;
        line-height: 1.5;
    }

    .logout-dialog-close {
        position: absolute;
        top: 10px;
        right: 12px;
        border: 0;
        background: none;
        color: #171717;
        font-size: 26px;
        cursor: pointer;
    }

    .logout-dialog-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 24px;
    }

    .logout-dialog-cancel,
    .logout-dialog-confirm {
        width: 128px;
        height: 52px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-sizing: border-box;
        padding: 0;
        border: 1px solid #171717;
        font: inherit;
        line-height: 1;
        text-decoration: none;
        cursor: pointer;
    }

    .logout-dialog-cancel {
        background: #fff;
        color: #171717;
    }

    .logout-dialog-confirm {
        background: #171717;
        color: #fff;
    }

    .app-sidebar {
        position: fixed;
        top: 0;
        left: 0;
        width: 220px;
        height: 100vh;
        background: var(--app-sidebar-bg);
        border-right: 1px solid var(--app-border);
        padding: 90px 12px 18px;
        transform: translateX(-100%);
        transition: transform 0.25s ease;
        z-index: 1000;
        overflow-y: auto;
        box-sizing: border-box;
    }

    .app-sidebar.open {
        transform: translateX(0);
        box-shadow: 10px 0 24px rgba(17, 17, 17, 0.08);
    }

    .app-sidebar-title {
        font-size: 11px;
        color: var(--app-muted);
        text-transform: uppercase;
        letter-spacing: 0.12em;
        margin: 0 0 14px;
        padding-left: 12px;
        font-weight: 700;
    }

    .app-sidebar a {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 12px;
        margin-bottom: 6px;
        border-radius: 8px;
        text-decoration: none;
        color: var(--app-text);
        font-size: 14px;
        font-weight: 500;
        transition: background-color 0.2s ease, transform 0.2s ease;
    }

    .app-sidebar a:hover,
    .app-sidebar a.active {
        background: #f3f4f6;
        transform: translateX(2px);
    }

    .nav-icon {
        width: 22px;
        min-width: 22px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: #374151;
        font-size: 14px;
    }

    .notification-dot {
        width: 8px;
        height: 8px;
        margin-left: auto;
        border-radius: 50%;
        background: #e74c3c;
        display: inline-block;
        flex-shrink: 0;
    }

    .page-content {
        transition: margin-left 0.25s ease;
    }

    .page-content.sidebar-open {
        margin-left: 220px;
    }

    @media (max-width: 900px) {
        .app-navbar {
            padding: 12px 18px;
            height: 66px;
        }

        .app-sidebar {
            top: 0;
            height: 100vh;
            padding-top: 84px;
        }

        .app-navbar h2 {
            font-size: 18px;
        }

        .app-navbar-right .user-name {
            display: none;
        }
    }
</style>
