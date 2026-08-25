<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Department" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.EmploymentStatus" %>
<%@ page import="com.nimbus.admin.model.Role" %>
<%@ page import="java.util.List" %>
<%
    Employee employee = (Employee) request.getAttribute("employee");
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    String error = (String) request.getAttribute("error");
    Employee viewer = (Employee) session.getAttribute("employee");
    boolean adminView = viewer != null && viewer.getRole() == Role.ADMIN;
        boolean isHr = employee != null && employee.getRole() == Role.HR;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Employee</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .page-content { padding: 30px 20px; }
        .container { max-width: 700px; margin: auto; }
        .card { background: #fff; padding: 26px; border-radius: 8px; box-shadow: 0 3px 10px rgba(0,0,0,.08); }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        label { display: flex; flex-direction: column; gap: 6px; font-size: 13px; font-weight: bold; }
        input, select, button { padding: 10px; border: 1px solid #ccd1d6; border-radius: 5px; font-size: 14px; }
        input[readonly] { background: #eef0f2; }
        button { background: #222; color: #fff; cursor: pointer; margin-top: 18px; }
        .error { color: #a00; margin-bottom: 15px; }
        .department-field.hidden { display: none; }
        @media (max-width: 650px) { .grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <main class="page-content"><div class="container"><div class="card">
        <h1>Edit Employee</h1>
        <% if (error != null) { %><p class="error"><%= error %></p><% } %>
        <form method="post" action="<%= request.getContextPath() %>/EditEmployeeServlet">
            <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
            <input type="hidden" name="empId" value="<%= employee.getEmpId() %>">
            <div class="grid">
                <label>Employee code<input name="empCode" value="<%= employee.getEmpCode() %>" readonly></label>
                <label>Full name<input name="fullName" value="<%= employee.getFullName() %>" required></label>
                <label>Email<input type="email" name="email" value="<%= employee.getEmail() %>"></label>
                <label>New password<input type="password" name="password" minlength="8" maxlength="50" pattern="(?=.*[A-Za-z])(?=.*[0-9])[A-Za-z0-9]{8,50}" title="Use 8-50 letters and numbers, including at least one of each." placeholder="Leave blank to keep current" autocomplete="new-password"></label>
                <% if (adminView) { %><label>Role<select name="role" id="role" onchange="toggleDepartmentRequirement()"><option value="EMPLOYEE" <%= employee.getRole() == Role.EMPLOYEE ? "selected" : "" %>>EMPLOYEE</option><option value="HR" <%= employee.getRole() == Role.HR ? "selected" : "" %>>HR</option></select></label><% } else { %><input type="hidden" name="role" value="<%= employee.getRole().name() %>"><% } %>
                <label>Designation<input name="designation" value="<%= employee.getDesignation() %>"></label>
                <label>Department<select name="deptId" id="deptId" <%= isHr ? "" : "required" %>><option value="">Select department</option><% if (departments != null) { for (Department department : departments) { %><option value="<%= department.getDeptId() %>" <%= department.getDeptId() == employee.getDeptId() ? "selected" : "" %>><%= department.getDeptName() %></option><% }} %></select></label>
                <label>Joining date<input type="date" name="joiningDate" value="<%= employee.getJoiningDate() %>" required></label>
                <label>Employment status<select name="employmentStatus"><% for (EmploymentStatus status : EmploymentStatus.values()) { %><option value="<%= status.name() %>" <%= status == employee.getEmploymentStatus() ? "selected" : "" %>><%= status.name() %></option><% } %></select></label>
            </div>
            <button type="submit">Save Changes</button>
        </form>
    </div></div></main>
    <script>
        function toggleDepartmentRequirement() {
            const isHr = document.getElementById('role').value === 'HR';
            const departmentField = document.getElementById('deptId');
            departmentField.required = !isHr;
            departmentField.disabled = false;
            departmentField.closest('label').classList.remove('hidden');
        }
        toggleDepartmentRequirement();
    </script>
</body>
</html>