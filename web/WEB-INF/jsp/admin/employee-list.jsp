<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.Role" %>
<%@ page import="com.nimbus.admin.util.HtmlEscaper" %>
<%@ page import="com.nimbus.admin.model.Department" %>
<%@ page import="java.util.List" %>
<%
    List<Employee> employees = (List<Employee>) request.getAttribute("employees");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    String keyword = (String) request.getAttribute("keyword");
    String selectedRole = (String) request.getAttribute("selectedRole");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String selectedDepartment = (String) request.getAttribute("selectedDepartment");
    Employee viewer = (Employee) request.getSession().getAttribute("employee");
    boolean adminView = viewer != null && viewer.getRole() == Role.ADMIN;
    boolean hrView = viewer != null && viewer.getRole() == Role.HR;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employees</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        body { font-family: Arial, sans-serif; background: #eef1f5; color: #20242a; }
        .page-content { padding: 38px 28px 56px; }
        .container { max-width: 1440px; margin: auto; }
        .card { background: #fff; padding: 32px; border: 1px solid #e1e5ea; border-radius: 12px; box-shadow: 0 10px 30px rgba(31,35,40,.07); }
        .page-heading { display: flex; align-items: flex-end; justify-content: space-between; gap: 20px; margin-bottom: 26px; }
        h1 { margin: 0 0 7px; font-size: 30px; letter-spacing: -.03em; }
        .page-heading p { margin: 0; color: #6e7781; font-size: 14px; }
        .toolbar { display: flex; gap: 18px; align-items: center; justify-content: space-between; margin-bottom: 16px; padding-bottom: 18px; border-bottom: 1px solid #edf0f2; flex-wrap: wrap; }
        .search-form, .toolbar-actions { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
        .toolbar-actions { margin-left: auto; }
        .search-form input { width: min(360px, 54vw); }
        .filters { display: flex; gap: 10px; padding: 14px; flex-wrap: wrap; align-items: center; margin-bottom: 22px; border: 1px solid #e1e5ea; border-radius: 8px; background: #f8fafc; }
        .filters select, .filters input { min-width: 160px; }
        .reset { color: #57606a; font-size: 13px; text-decoration: none; padding: 0 4px; }
        .reset:hover { color: #0969da; text-decoration: underline; }
        input, select, button, .button { min-height: 40px; padding: 0 13px; border: 1px solid #ccd1d6; border-radius: 6px; font-size: 14px; }
        input:focus, select:focus, button:focus-visible, a:focus-visible { outline: 3px solid rgba(9,105,218,.22); outline-offset: 2px; }
        button, .button { display: inline-flex; align-items: center; justify-content: center; background: #24292f; color: #fff; text-decoration: none; cursor: pointer; white-space: nowrap; font-weight: 600; }
        button:hover, .button:hover { background: #414951; }
        table { width: 100%; border-collapse: collapse; }
        .table-wrap { overflow-x: auto; }
        th, td { text-align: left; padding: 13px 12px; border-bottom: 1px solid #edf0f2; white-space: nowrap; }
        th { background: #f6f8fa; color: #57606a; font-size: 11px; letter-spacing: .08em; text-transform: uppercase; }
        td { font-size: 13px; }
        tbody tr:last-child td { border-bottom: 0; }
        tbody tr:hover { background: #f8fafc; }
        .actions { display: flex; gap: 6px; align-items: center; }
        .actions form { margin: 0; }
        .status-cell { min-width: 92px; }
        .actions-cell { min-width: 230px; }
        td.actions-cell { background: #fff; }
        th.actions-cell { background: #f6f8fa; }
        tbody tr:hover td.actions-cell { background: #f8fafc; }
        .action-link { width: 86px; height: 32px; display: inline-flex; align-items: center; justify-content: center; box-sizing: border-box; padding: 0; border: 1px solid #ccd1d6; border-radius: 5px; color: #24292f; text-decoration: none; font: 12px Arial, sans-serif; }
        .action-link:hover { background: #f6f8fa; }
        .danger { color: #cf222e; background: #fff; }
        .action-link.danger:hover { background: #fff1f0; }
        .toast { position: fixed; right: 22px; bottom: 22px; z-index: 2000; padding: 14px 18px; border-radius: 8px; background: #1f883d; color: #fff; box-shadow: 0 6px 20px rgba(27,31,36,.2); animation: toast-in .25s ease-out; }
        .toast.error { background: #cf222e; }
        @keyframes toast-in { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <main class="page-content"><div class="container"><div class="card">
        <div class="page-heading">
            <div><h1><%= adminView ? "Employees & HR" : "My Employees" %></h1><p><%= adminView ? "Review and manage every employee and HR account, assignment, and status." : "View the employees assigned to your department and their current account details." %></p></div>
        </div>
        <div class="toolbar">
            <form class="search-form" method="get" action="<%= request.getContextPath() %>/SearchEmployeeServlet">
                <input name="keyword" value="<%= HtmlEscaper.text(keyword == null ? "" : keyword) %>" placeholder="Search code, name, or email">
                <button type="submit">Search</button>
            </form>
            <% if (adminView) { %>
                <div class="toolbar-actions">
                    <a class="button" href="<%= request.getContextPath() %>/AddEmployeeServlet?mode=employee">Add Employee</a>
                    <a class="button" href="<%= request.getContextPath() %>/AddEmployeeServlet?mode=hr">Add HR</a>
                </div>
            <% } %>
        </div>
        <% if (adminView) { %>
        <form class="filters" method="get" action="<%= request.getContextPath() %>/SearchEmployeeServlet">
            <input type="hidden" name="keyword" value="<%= HtmlEscaper.text(keyword == null ? "" : keyword) %>">
            <select name="role" aria-label="Filter by role"><option value="">All roles</option><option value="ADMIN" <%= "ADMIN".equals(selectedRole) ? "selected" : "" %>>Admin</option><option value="HR" <%= "HR".equals(selectedRole) ? "selected" : "" %>>HR</option><option value="EMPLOYEE" <%= "EMPLOYEE".equals(selectedRole) ? "selected" : "" %>>Employee</option></select>
            <select name="status" aria-label="Filter by status"><option value="">All statuses</option><option value="ACTIVE" <%= "ACTIVE".equals(selectedStatus) ? "selected" : "" %>>Active</option><option value="INACTIVE" <%= "INACTIVE".equals(selectedStatus) ? "selected" : "" %>>Inactive</option></select>
            <select name="departmentId" aria-label="Filter by department"><option value="">All departments</option><% if (departments != null) { for (Department department : departments) { %><option value="<%= department.getDeptId() %>" <%= String.valueOf(department.getDeptId()).equals(selectedDepartment) ? "selected" : "" %>><%= HtmlEscaper.text(department.getDeptName()) %></option><% }} %></select>
            <button type="submit">Apply filters</button>
            <a class="reset" href="<%= request.getContextPath() %>/SearchEmployeeServlet">Reset</a>
        </form>
        <% } %>
        <div class="table-wrap"><table>
            <thead><tr><th>ID</th><th>Code</th><th>Full name</th><th>Email</th><th>Password</th><th>Role</th><th>Designation</th><th>Department</th><th>Joining date</th><th class="status-cell">Status</th><th class="actions-cell">Actions</th></tr></thead>
            <tbody>
            <% if (employees != null && !employees.isEmpty()) { %>
            <% for (Employee employee : employees) { %>
                <tr>
                    <td><%= employee.getEmpId() %></td>
                    <td><%= HtmlEscaper.text(employee.getEmpCode()) %></td>
                    <td><%= HtmlEscaper.text(employee.getFullName()) %></td>
                    <td><%= HtmlEscaper.text(employee.getEmail()) %></td>
                    <td aria-label="Password hidden">********</td>
                    <td><%= employee.getRole() %></td>
                    <td><%= HtmlEscaper.text(employee.getDesignation()) %></td>
                    <td><%= employee.getDeptId() > 0 ? employee.getDeptId() + " - " + HtmlEscaper.text(employee.getDepartmentName()) : "Unassigned" %></td>
                    <td><%= employee.getJoiningDate() %></td>
                    <td class="status-cell"><%= employee.getEmploymentStatus() %></td>
                    <td class="actions-cell"><div class="actions">
                        <% boolean canManage = adminView && (employee.getRole() != Role.ADMIN
                            || employee.getEmpId() == viewer.getEmpId())
                            || hrView && ((employee.getEmpId() == viewer.getEmpId()
                            && employee.getRole() == Role.HR)
                            || (employee.getRole() == Role.EMPLOYEE
                            && employee.getDeptId() == viewer.getDeptId())); %>
                        <% if (canManage) { %>
                            <a class="action-link" href="<%= request.getContextPath() %>/EditEmployeeServlet?empId=<%= employee.getEmpId() %>">Edit</a>
                            <% if (employee.getEmpId() != viewer.getEmpId()) { %>
                                <form method="post" action="<%= request.getContextPath() %>/DeleteEmployeeServlet" onsubmit="return window.confirm('Deactivate this account?');">
                                    <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                                    <input type="hidden" name="empId" value="<%= employee.getEmpId() %>">
                                    <button class="action-link danger" type="submit">Deactivate</button>
                                </form>
                            <% } %>
                        <% } else { %><span><%= employee.getEmpId() == viewer.getEmpId() ? "Self account" : "Protected" %></span><% } %>
                    </div></td>
                </tr>
            <% } %>
            <% } else { %>
                <tr><td colspan="11" style="padding: 34px; text-align: center; color: #6e7781;">No employee records match the current search or filters.</td></tr>
            <% } %>
            </tbody>
        </table></div>
    </div></div></main>
    <% String success = request.getParameter("success"); String error = request.getParameter("error"); %>
    <% if (success != null || error != null) { %>
        <div class="toast <%= error != null ? "error" : "" %>"><%= error != null ? ("protected".equals(error) ? "Admin accounts are protected." : "Operation failed.") : ("added".equals(success) ? ("HR".equals(request.getParameter("createdRole")) ? "HR representative added successfully." : "Employee added successfully.") : ("deleted".equals(success) ? "Employee deactivated successfully." : "Changes saved successfully.")) %></div>
        <script>setTimeout(function () { document.querySelector('.toast').remove(); }, 4500);</script>
    <% } %>
</body>
</html>
