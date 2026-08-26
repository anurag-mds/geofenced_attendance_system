<%-- Shared hamburger navbar and role-based sidebar for authenticated pages. --%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.Role" %>
<%@ page import="com.nimbus.admin.dao.NotificationDAO" %>

<%
    Employee navEmployee = (Employee) session.getAttribute("employee");

    String ctx = request.getContextPath();

    Role navRole = navEmployee != null
            ? navEmployee.getRole()
            : null;
    int unreadNotifications = 0;
    if (navEmployee != null) {
        try {
            unreadNotifications = new NotificationDAO().getUnreadCount(navEmployee.getEmpId());
        } catch (Exception ignored) {
            unreadNotifications = 0;
        }
    }

    String menuTitle = "Menu";
    String systemTitle = "Employee Attendance System";
    String dashboardLabel = "Dashboard";

    if (navRole == Role.EMPLOYEE) {
        menuTitle = "Employee Menu";
        dashboardLabel = "Employee Dashboard";
    } else if (navRole == Role.HR) {
        menuTitle = "HR Menu";
        dashboardLabel = "HR Dashboard";
    } else if (navRole == Role.ADMIN) {
        menuTitle = "Admin Menu";
        dashboardLabel = "Admin Dashboard";
    }
%>


<nav class="app-navbar">

    <div class="app-navbar-left">

        <button type="button"
                class="app-menu-button"
                onclick="toggleAppSidebar()"
                aria-label="Open navigation menu">
            <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                <path d="M3 6.75h18M3 12h18M3 17.25h18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
        </button>

        <div class="app-brand-block">
            <h2><%= systemTitle %></h2>
            <span class="app-dashboard-label"><%= dashboardLabel %></span>
        </div>

    </div>


    <div class="app-navbar-right">

        <% if (navEmployee != null) { %>

            <span class="user-name">
                <%= navEmployee.getFullName() %>
            </span>

                <a href="<%= ctx %>/LogoutServlet"
                    class="app-logout-button"
                    data-logout-url="<%= ctx %>/LogoutServlet"
                    onclick="return openLogoutDialog(event);">
                Logout
            </a>

        <% } %>

    </div>

</nav>


<aside class="app-sidebar" id="appSidebar">

    <div class="app-sidebar-title">
        <%= menuTitle %>
    </div>


    <% if (navRole == Role.EMPLOYEE) { %>

        <a href="<%= ctx %>/EmployeeDashboardServlet">
            <span class="nav-icon"><i class="fa-solid fa-house"></i></span>
            <span>Dashboard</span>
        </a>

        <a href="#">
            <span class="nav-icon"><i class="fa-regular fa-calendar-days"></i></span>
            <span>Attendance</span>
        </a>

        <a href="<%= ctx %>/EmployeeLeaveMenuServlet">
            <span class="nav-icon"><i class="fa-regular fa-file-lines"></i></span>
            <span>Leave</span>
        </a>

        <a href="<%= ctx %>/ApplyRemoteWorkServlet">
            <span class="nav-icon"><i class="fa-solid fa-house-laptop"></i></span>
            <span>Work From Home</span>
        </a>

        <a href="<%= ctx %>/NotificationServlet">
            <span class="nav-icon"><i class="fa-regular fa-bell"></i></span>
            <span>Notifications</span>
            <% if (unreadNotifications > 0) { %><span class="notification-dot"></span><% } %>
        </a>

        <a href="<%= ctx %>/ProfileServlet">
            <span class="nav-icon"><i class="fa-regular fa-user"></i></span>
            <span>My Profile</span>
        </a>


    <% } else if (navRole == Role.HR) { %>

        <a href="<%= ctx %>/HrDashboardServlet">
            <span class="nav-icon"><i class="fa-solid fa-chart-column"></i></span>
            <span>HR Dashboard</span>
        </a>

        <a href="<%= ctx %>/HrLeaveRequestsServlet">
            <span class="nav-icon"><i class="fa-regular fa-clipboard"></i></span>
            <span>Leave Requests</span>
        </a>

        <a href="<%= ctx %>/HrRemoteWorkRequestsServlet">
            <span class="nav-icon"><i class="fa-solid fa-laptop-house"></i></span>
            <span>WFH Requests</span>
        </a>

        <a href="<%= ctx %>/SearchEmployeeServlet">
            <span class="nav-icon"><i class="fa-solid fa-users"></i></span>
            <span>My Employees</span>
        </a>

        <a href="<%= ctx %>/ContactServlet?role=ADMIN">
            <span class="nav-icon"><i class="fa-solid fa-phone"></i></span>
            <span>Contact Admin</span>
        </a>

        <a href="<%= ctx %>/NotificationServlet">
            <span class="nav-icon"><i class="fa-regular fa-bell"></i></span>
            <span>Notifications</span>
            <% if (unreadNotifications > 0) { %><span class="notification-dot"></span><% } %>
        </a>

        <a href="<%= ctx %>/ProfileServlet">
            <span class="nav-icon"><i class="fa-regular fa-user"></i></span>
            <span>Profile</span>
        </a>


    <% } else if (navRole == Role.ADMIN) { %>

        <a href="<%= ctx %>/adminDashboard.jsp">
            <span class="nav-icon"><i class="fa-solid fa-gauge-high"></i></span>
            <span>Admin Dashboard</span>
        </a>

        <a href="<%= ctx %>/SearchEmployeeServlet">
            <span class="nav-icon"><i class="fa-solid fa-user-tie"></i></span>
            <span>Manage Employees</span>
        </a>

        <a href="<%= ctx %>/SearchEmployeeServlet?role=HR">
            <span class="nav-icon"><i class="fa-solid fa-user-shield"></i></span>
            <span>Manage HR</span>
        </a>

        <a href="<%= ctx %>/DepartmentServlet">
            <span class="nav-icon"><i class="fa-solid fa-building"></i></span>
            <span>Manage Departments</span>
        </a>

        <a href="<%= ctx %>/ContactServlet?role=HR">
            <span class="nav-icon"><i class="fa-solid fa-phone"></i></span>
            <span>Contact HR</span>
        </a>

        <a href="<%= ctx %>/NotificationServlet">
            <span class="nav-icon"><i class="fa-regular fa-bell"></i></span>
            <span>Notifications</span>
            <% if (unreadNotifications > 0) { %><span class="notification-dot"></span><% } %>
        </a>

        <a href="<%= ctx %>/ProfileServlet">
            <span class="nav-icon"><i class="fa-regular fa-user"></i></span>
            <span>Profile</span>
        </a>

    <% } %>

</aside>

<div class="logout-dialog" id="logoutDialog" hidden>
    <div class="logout-dialog-backdrop" onclick="closeLogoutDialog()"></div>
    <section class="logout-dialog-panel" role="dialog" aria-modal="true" aria-labelledby="logoutDialogTitle">
        <button type="button" class="logout-dialog-close" onclick="closeLogoutDialog()" aria-label="Close">&times;</button>
        <p class="logout-dialog-kicker">SESSION CONTROL</p>
        <h2 id="logoutDialogTitle">Leave this session?</h2>
        <p>Goodbye, <%= navEmployee != null ? navEmployee.getFullName() : "there" %>. Your session will be closed securely.</p>
        <div class="logout-dialog-actions">
            <button type="button" class="logout-dialog-cancel" onclick="closeLogoutDialog()">Stay Here</button>
            <a class="logout-dialog-confirm" id="logoutDialogConfirm" href="#">Log out</a>
        </div>
    </section>
</div>


<script>

    (function () {
        const currentPath = window.location.pathname;
        document.addEventListener('click', function (event) {
            const link = event.target.closest('a[href]');
            if (!link || event.defaultPrevented || link.target === '_blank'
                    || link.hasAttribute('download') || link.getAttribute('href').startsWith('#')
                    || link.dataset.logoutUrl) {
                return;
            }
            const destination = new URL(link.href, window.location.href);
            if (destination.origin !== window.location.origin
                    || destination.pathname === currentPath) {
                return;
            }
            document.body.classList.add('flow-leaving');
        });
    }());

    function toggleAppSidebar() {

        const sidebar =
                document.getElementById("appSidebar");

        sidebar.classList.toggle("open");

        document.querySelectorAll(".page-content")
                .forEach(function (section) {

                    section.classList.toggle(
                            "sidebar-open"
                    );

                });
    }

    function openLogoutDialog(event) {
        if (event) {
            event.preventDefault();
        }
        const dialog = document.getElementById('logoutDialog');
        const source = event.currentTarget;
        const confirmLink = document.getElementById('logoutDialogConfirm');
        confirmLink.href = source.dataset.logoutUrl;
        confirmLink.onclick = function () {
            window.location.replace(this.href);
            return false;
        };
        dialog.hidden = false;
        document.body.classList.add('dialog-open');
        confirmLink.focus();
        return false;
    }

    function closeLogoutDialog() {
        const dialog = document.getElementById('logoutDialog');
        if (dialog) {
            dialog.hidden = true;
            document.body.classList.remove('dialog-open');
        }
        return false;
    }

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeLogoutDialog();
        }
    });

</script>