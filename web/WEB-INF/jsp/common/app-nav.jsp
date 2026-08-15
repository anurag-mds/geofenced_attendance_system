<%-- Shared hamburger navbar and role-based sidebar for authenticated pages. --%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.Role" %>

<%
    Employee navEmployee = (Employee) session.getAttribute("employee");

    String ctx = request.getContextPath();

    Role navRole = navEmployee != null
            ? navEmployee.getRole()
            : null;

    String menuTitle = "Menu";

    if (navRole == Role.EMPLOYEE) {
        menuTitle = "Employee Menu";
    } else if (navRole == Role.HR) {
        menuTitle = "HR Menu";
    } else if (navRole == Role.ADMIN) {
        menuTitle = "Admin Menu";
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

        <h2>Employee Attendance System</h2>

    </div>


    <div class="app-navbar-right">

        <% if (navEmployee != null) { %>

            <span class="user-name">
                <%= navEmployee.getFullName() %>
            </span>

            <a href="<%= ctx %>/LogoutServlet"
               class="app-logout-button"
               onclick="return confirm('Goodbye <%= navEmployee.getFullName() %>! Are you sure you want to logout?');">
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
            &#128276; Notifications
        </a>

        <!-- Profile -->
        <a href="<%= ctx %>/ProfileServlet">
            &#128100; My Profile
        </a>


    <% } else if (navRole == Role.HR) { %>

        <!-- HR Dashboard -->
        <a href="<%= ctx %>/hrDashboard.jsp">
            &#127968; HR Dashboard
        </a>

        <!-- Leave Requests -->
        <a href="<%= ctx %>/HrLeaveRequestsServlet">
            &#128203; Leave Requests
        </a>

        <!-- Pending Leave Requests -->
        <a href="<%= ctx %>/HrLeaveRequestsServlet?status=SUBMITTED">
            &#9203; Pending Requests
        </a>


    <% } else if (navRole == Role.ADMIN) { %>

        <!-- Admin Dashboard -->
        <a href="<%= ctx %>/adminDashboard.jsp">
            &#127968; Admin Dashboard
        </a>

        <!-- Leave Overview -->
        <a href="<%= ctx %>/AdminLeaveOverviewServlet">
            &#128202; Leave Overview
        </a>

        <!-- Leave Records -->
        <a href="<%= ctx %>/AdminLeaveOverviewServlet?view=records">
            &#128451; Leave Records
        </a>

    <% } %>

</aside>


<script>

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

</script>