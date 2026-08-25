<%-- This page is the Admin landing screen after login.
    It provides administrative CRUD navigation for employees, HR, and departments. --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.Role" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null || employee.getRole() != Role.ADMIN) {
        response.sendRedirect("index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; }
        .card {
            background: #fff; border-radius: 10px; padding: 30px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }
        h1 { font-size: 28px; margin-bottom: 8px; }
        p { color: #666; margin-bottom: 18px; }
        .btn {
            display: inline-flex; align-items: center; justify-content: center; min-width: 190px; min-height: 44px; padding: 0 18px; border-radius: 6px;
            text-decoration: none; background: #222; color: #fff; font-size: 14px;
        }
        .dashboard-actions { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; margin-top: 24px; }
        @media (max-width: 680px) { .dashboard-actions { grid-template-columns: 1fr; } }
        .toast { position: fixed; right: 22px; bottom: 22px; z-index: 2000; padding: 14px 18px; border-radius: 6px; background: #1f883d; color: #fff; box-shadow: 0 6px 20px rgba(27,31,36,.2); }
        .toast.error { background: #cf222e; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <div class="page-content">
        <div class="container">
            <div class="card">
                <h1>Welcome, <%= employee.getFullName() %></h1>
                <p>Manage employees, HR representatives, and departments.</p>
                <div class="dashboard-actions">
                    <a class="btn" href="AddEmployeeServlet?mode=employee">Add Employee</a>
                    <a class="btn" href="AddEmployeeServlet?mode=hr">Add HR Representative</a>
                    <a class="btn" href="SearchEmployeeServlet">Manage Employees &amp; HR</a>
                    <a class="btn" href="DepartmentServlet">Manage Departments</a>
                </div>
            </div>
        </div>
    </div>
    <% String success = request.getParameter("success"); String error = request.getParameter("error"); %>
    <% if (success != null || error != null) { %>
        <div class="toast <%= error != null ? "error" : "" %>"><%= error != null ? "Operation failed." : ("added".equals(success) ? "Employee added successfully." : "Operation completed successfully.") %></div>
        <script>setTimeout(function () { document.querySelector('.toast').remove(); }, 4500);</script>
    <% } %>
</body>
</html>
