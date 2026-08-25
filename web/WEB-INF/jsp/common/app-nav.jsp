<%-- Shared navbar and role-based sidebar for authenticated pages. --%>

<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.Role" %>
<%@ page import="com.nimbus.admin.dao.NotificationDAO" %>
<%@ page import="java.sql.SQLException" %>
<%
    Employee navEmployee =
            (Employee) session.getAttribute("employee");

    String ctx =
            request.getContextPath();

    Role navRole =
            navEmployee != null
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


   /*
     * =========================================================
     * UNREAD NOTIFICATION COUNT
     * =========================================================
     */

    int navUnreadCount = 0;

    if (navEmployee != null) {

        try {

            NotificationDAO notificationDAO =
                    new NotificationDAO();

            navUnreadCount =
                    notificationDAO.getUnreadCount(
                            navEmployee.getEmpId()
                    );

        } catch (SQLException e) {

            navUnreadCount = 0;

            e.printStackTrace();
        }
    }
%>

<!-- =========================================================
     TOP NAVBAR
     ========================================================= -->

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

            <!-- Employee name -->

            <span class="user-name">
                <%= navEmployee.getFullName() %>
            </span>


            <!-- Notifications -->

         <!-- Notifications -->

<a href="<%= ctx %>/NotificationServlet"
   class="notification-button"
   title="Notifications"
   aria-label="Notifications">

    <span class="notification-icon">
        &#128276;
    </span>

    <% if (navUnreadCount > 0) { %>

        <span class="notification-badge">
            <%= navUnreadCount > 99 ? "99+" : navUnreadCount %>
        </span>

    <% } %>

</a>

            <!-- Logout -->

            <a href="<%= ctx %>/LogoutServlet"
               class="app-logout-button"
               onclick="return confirm('Goodbye <%= navEmployee.getFullName() %>! Are you sure you want to logout?');">

                Logout

            </a>

        <% } %>

    </div>

</nav>


<!-- =========================================================
     SIDEBAR
     ========================================================= -->

<aside class="app-sidebar"
       id="appSidebar">

    <div class="app-sidebar-title">
        <%= menuTitle %>
    </div>


    <% if (navRole == Role.EMPLOYEE) { %>


        <!-- =================================================
             EMPLOYEE MENU
             ================================================= -->


        <!-- Home -->

        <a href="<%= ctx %>/EmployeeDashboardServlet">

            <span class="nav-icon">&#127968;</span>

            <span>Home</span>

        </a>


        <!-- Leave -->

        <a href="<%= ctx %>/EmployeeLeaveMenuServlet">

            <span class="nav-icon">&#128203;</span>

            <span>Leave</span>

        </a>


        <!-- Attendance -->

        <a href="#">

            <span class="nav-icon">&#128197;</span>

            <span>Attendance</span>

        </a>


        <!-- My Profile -->

        <a href="<%= ctx %>/ProfileServlet">

            <span class="nav-icon">&#128100;</span>

            <span>My Profile</span>

        </a>


    <% } else if (navRole == Role.HR) { %>


        <!-- =================================================
             HR MENU
             ================================================= -->


        <!-- HR Dashboard -->

        <a href="<%= ctx %>/hrDashboard.jsp">

            <span class="nav-icon">&#127968;</span>

            <span>HR Dashboard</span>

        </a>


        <!-- Leave Requests -->

        <a href="<%= ctx %>/HrLeaveRequestsServlet">

            <span class="nav-icon">&#128203;</span>

            <span>Leave Requests</span>

        </a>


        <!-- Pending Requests -->

        <a href="<%= ctx %>/HrLeaveRequestsServlet?status=SUBMITTED">

            <span class="nav-icon">&#9203;</span>

            <span>Pending Requests</span>

        </a>


    <% } else if (navRole == Role.ADMIN) { %>


        <!-- =================================================
             ADMIN MENU
             ================================================= -->


        <!-- Admin Dashboard -->

        <a href="<%= ctx %>/adminDashboard.jsp">

            <span class="nav-icon">&#127968;</span>

            <span>Admin Dashboard</span>

        </a>


        <!-- Leave Overview -->

        <a href="<%= ctx %>/AdminLeaveOverviewServlet">

            <span class="nav-icon">&#128202;</span>

            <span>Leave Overview</span>

        </a>


        <!-- Leave Records -->

        <a href="<%= ctx %>/AdminLeaveOverviewServlet?view=records">

            <span class="nav-icon">&#128451;</span>

            <span>Leave Records</span>

        </a>


    <% } %>

</aside>


<!-- =========================================================
     SIDEBAR SCRIPT
     ========================================================= -->

<script>

    function toggleAppSidebar() {

        const sidebar =
                document.getElementById("appSidebar");

        sidebar.classList.toggle("open");


        document
                .querySelectorAll(".page-content")
                .forEach(function(section) {

                    section.classList.toggle(
                            "sidebar-open"
                    );

                });

    }

</script>