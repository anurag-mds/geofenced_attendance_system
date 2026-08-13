<%-- Shared navbar and sidebar styles for all authenticated pages. --%>
<style>
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

    .app-navbar h2 {
        font-size: 22px;
        font-weight: 600;
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
        transition: transform 0.3s ease;
        z-index: 1000;
        overflow-y: auto;
    }

    .app-sidebar.open {
        transform: translateX(0);
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
        transition: 0.2s;
    }

    .app-sidebar a:hover,
    .app-sidebar a.active {
        background-color: #f0f2f5;
    }

    .page-content {
        transition: margin-left 0.3s ease;
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
