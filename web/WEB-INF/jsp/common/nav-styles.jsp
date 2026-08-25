<%-- Shared navbar and sidebar styles for all authenticated pages. --%>

<style>

    * {
        box-sizing: border-box;
    }


    /* =========================================================
       NAVBAR
       ========================================================= */

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

        margin: 0;

        font-size: 22px;

        font-weight: 600;

    }


    /* =========================================================
       MENU BUTTON
       ========================================================= */

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


    /* =========================================================
       RIGHT SIDE OF NAVBAR
       ========================================================= */

    .app-navbar-right {

        display: flex;

        align-items: center;

        gap: 16px;

        font-size: 14px;

    }


    .user-name {

        color: #fff;

        font-size: 14px;

    }


    /* =========================================================
       NOTIFICATION ICON
       ========================================================= */

    .notification-button {

        width: 38px;

        height: 38px;

        display: flex;

        align-items: center;

        justify-content: center;

        border-radius: 50%;

        color: #fff;

        text-decoration: none;

        transition: 0.2s;

    }


    .notification-button:hover {

        background: rgba(255, 255, 255, 0.12);

    }


    .notification-icon {

        font-size: 21px;

        line-height: 1;

    }


    /* =========================================================
       LOGOUT
       ========================================================= */

    .app-logout-button {

        background-color: #e74c3c;

        color: #fff;

        padding: 9px 16px;

        border: none;

        border-radius: 5px;

        text-decoration: none;

        font-size: 14px;

        transition: 0.2s;

    }


    .app-logout-button:hover {

        background-color: #c0392b;

    }


    /* =========================================================
       SIDEBAR
       ========================================================= */

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


    /* =========================================================
       SIDEBAR LINKS
       ========================================================= */

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


    .app-sidebar a:hover {

        background-color: #f0f2f5;

    }


    .app-sidebar a.active {

        background-color: #f0f2f5;

        font-weight: 600;

    }


    .nav-icon {

        width: 22px;

        text-align: center;

        font-size: 17px;

    }


    /* =========================================================
       PAGE CONTENT
       ========================================================= */

    .page-content {

        transition: margin-left 0.3s ease;

    }


    .page-content.sidebar-open {

        margin-left: 230px;

    }


    /* =========================================================
       MOBILE
       ========================================================= */

    @media (max-width: 900px) {

        .app-navbar {

            padding: 16px 20px;

        }


        .app-navbar h2 {

            font-size: 18px;

        }


        .app-navbar-right {

            gap: 8px;

        }


        .app-navbar-right .user-name {

            display: none;

        }


        .app-sidebar {

            width: 220px;

        }


        .page-content.sidebar-open {

            margin-left: 0;

        }

    }
/* =========================================================
   NOTIFICATION BELL
   ========================================================= */

.notification-button {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    text-decoration: none;
}


.notification-icon {
    font-size: 25px;
    line-height: 1;
}


/* =========================================================
   UNREAD NOTIFICATION BADGE
   ========================================================= */

.notification-badge {
    position: absolute;

    top: -5px;
    right: -7px;

    min-width: 18px;
    height: 18px;

    padding: 0 5px;

    display: flex;
    align-items: center;
    justify-content: center;

    background: #e53935;
    color: white;

    border-radius: 50%;

    font-size: 10px;
    font-weight: 700;

    line-height: 1;

    border: 2px solid #222;

    box-sizing: border-box;
}
</style>