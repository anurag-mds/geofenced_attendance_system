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
            &#9776;
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

        <!-- Employee Dashboard -->
        <a href="<%= ctx %>/EmployeeDashboardServlet">
            &#127968; Dashboard
        </a>

        <!-- Attendance -->
        <a href="#">
            &#128197; Attendance
        </a>

        <!-- Apply Leave -->
        <a href="<%= ctx %>/ApplyLeaveServlet">
            &#127958; Apply Leave
        </a>

        <!-- Leave History -->
        <a href="<%= ctx %>/LeaveHistoryServlet">
            &#128203; Leave History
        </a>

        <!-- Work From Home -->
        <a href="<%= ctx %>/ApplyRemoteWorkServlet">
            &#127968; Apply for Work From Home
        </a>

        <!-- Notifications -->
        <a href="<%= ctx %>/NotificationServlet">
            &#128276; Notifications<% if (unreadNotifications > 0) { %><span class="notification-dot"></span><% } %>
        </a>

        <!-- Profile -->
        <a href="<%= ctx %>/ProfileServlet">
            &#128100; My Profile
        </a>


    <% } else if (navRole == Role.HR) { %>

        <!-- HR Dashboard -->
        <a href="<%= ctx %>/HrDashboardServlet">
            &#127968; HR Dashboard
        </a>

        <a href="<%= ctx %>/HrLeaveRequestsServlet">
            &#128203; Leave Requests
        </a>

        <a href="<%= ctx %>/HrRemoteWorkRequestsServlet">
            &#127968; WFH Requests
        </a>

        <a href="<%= ctx %>/SearchEmployeeServlet">&#128100; My Employees</a>
        <a href="<%= ctx %>/ContactServlet?role=ADMIN">&#128222; Contact Admin</a>
        <a href="<%= ctx %>/ProfileServlet">&#128100; Profile</a>
        <a href="<%= ctx %>/NotificationServlet">&#128276; Notifications<% if (unreadNotifications > 0) { %><span class="notification-dot"></span><% } %></a>


    <% } else if (navRole == Role.ADMIN) { %>

        <!-- Admin Dashboard -->
        <a href="<%= ctx %>/adminDashboard.jsp">
            &#127968; Admin Dashboard
        </a>

        <a href="<%= ctx %>/SearchEmployeeServlet">
            &#128100; Manage Employees
        </a>

        <a href="<%= ctx %>/SearchEmployeeServlet?role=HR">
            &#128100; Manage HR
        </a>

        <a href="<%= ctx %>/DepartmentServlet">
            &#127979; Manage Departments
        </a>

        <a href="<%= ctx %>/ContactServlet?role=HR">&#128222; Contact HR</a>
        <a href="<%= ctx %>/ProfileServlet">&#128100; Profile</a>
        <a href="<%= ctx %>/NotificationServlet">&#128276; Notifications<% if (unreadNotifications > 0) { %><span class="notification-dot"></span><% } %></a>

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