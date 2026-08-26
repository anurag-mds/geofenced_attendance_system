<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Department" %>
<%@ page import="java.util.List" %>
<%
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    String error = (String) request.getAttribute("error");
    String creationMode = (String) request.getAttribute("creationMode");
    if (creationMode == null) { creationMode = "employee"; }
    boolean isHr = "hr".equalsIgnoreCase(creationMode);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isHr ? "Add HR Representative" : "Add Employee" %></title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .page-content { padding: 30px 20px; }
        .container { max-width: 700px; margin: auto; }
        .card { background: #fff; padding: 26px; border-radius: 8px; box-shadow: 0 3px 10px rgba(0,0,0,.08); }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        label { display: flex; flex-direction: column; gap: 6px; font-size: 13px; font-weight: bold; }
        input, select, button { padding: 10px; border: 1px solid #ccd1d6; border-radius: 5px; font-size: 14px; }
        button { background: #222; color: #fff; cursor: pointer; margin-top: 18px; }
        .error { color: #a00; margin-bottom: 15px; }
        .code-status { min-height: 18px; font-size: 12px; font-weight: normal; }
        .code-status.available { color: #176b3a; }
        .code-status.unavailable { color: #a00; }
        .department-field.hidden { display: none; }
        @media (max-width: 650px) { .grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <main class="page-content"><div class="container"><div class="card">
        <h1><%= isHr ? "Add HR Representative" : "Add Employee" %></h1>
        <% if (error != null) { %><p class="error"><%= error %></p><% } %>
        <form method="post" action="<%= request.getContextPath() %>/AddEmployeeServlet?mode=<%= creationMode %>">
            <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
            <div class="grid">
                <label>Employee code<input name="empCode" id="empCode" required maxlength="5" pattern="NT[0-9]{1,3}" title="Use NT followed by 1 to 3 numbers, for example NT001." placeholder="NT001" autocomplete="off"><span class="code-status" id="codeStatus" aria-live="polite"></span></label>
                <label>Full name<input name="fullName" required maxlength="100"></label>
                <label>Email<input type="email" name="email" required maxlength="100" pattern="[A-Za-z0-9._%+-]+@nimbustech\.com" title="Use your @nimbustech.com company email."></label>
                <label>Password<input type="password" name="password" required minlength="8" maxlength="50" pattern="(?=.*[A-Za-z])(?=.*[0-9])[A-Za-z0-9]{8,50}" title="Use 8-50 letters and numbers, including at least one of each." autocomplete="new-password"></label>
                <label>Designation<input name="designation" value="<%= isHr ? "HR Manager" : "" %>" <%= isHr ? "readonly" : "" %> required maxlength="50"></label>
                <label class="<%= isHr ? "department-field hidden" : "department-field" %>" id="departmentField">Department<select name="deptId" id="deptId" <%= isHr ? "disabled" : "required" %>><option value="">Select department</option><% if (departments != null) { for (Department department : departments) { %><option value="<%= department.getDeptId() %>"><%= department.getDeptName() %></option><% }} %></select></label>
                <label>Joining date<input type="date" name="joiningDate" required></label>
            </div>
            <button type="submit">Create <%= isHr ? "HR Representative" : "Employee" %></button>
        </form>
    </div></div></main>
    <script>
        const empCodeInput = document.getElementById('empCode');
        const codeStatus = document.getElementById('codeStatus');
        let codeCheck;

        function checkEmployeeCode() {
            const empCode = empCodeInput.value.trim();
            clearTimeout(codeCheck);
            codeStatus.className = 'code-status';
            codeStatus.textContent = '';
            if (!empCode) return;
            if (!/^NT[0-9]{1,3}$/.test(empCode)) {
                codeStatus.className = 'code-status unavailable';
                codeStatus.textContent = 'Use NT followed by 1 to 3 numbers.';
                return;
            }
            codeCheck = setTimeout(function () {
                fetch('<%= request.getContextPath() %>/CheckEmployeeCodeServlet?empCode=' + encodeURIComponent(empCode))
                    .then(function (response) {
                        if (response.status === 403) throw new Error('Only an administrator can check employee codes.');
                        if (!response.ok) throw new Error('The code-check service is unavailable.');
                        return response.json();
                    })
                    .then(function (result) {
                        if (empCodeInput.value.trim() !== empCode) return;
                        codeStatus.className = result.exists
                                ? 'code-status unavailable' : 'code-status available';
                        codeStatus.textContent = result.exists
                                ? 'Employee code already exists.' : 'Employee code is available.';
                    })
                    .catch(function (error) {
                        codeStatus.className = 'code-status unavailable';
                        codeStatus.textContent = error.message || 'Could not check code availability.';
                    });
            }, 250);
        }

        empCodeInput.addEventListener('input', checkEmployeeCode);
        empCodeInput.addEventListener('blur', checkEmployeeCode);

        function toggleDepartmentRequirement() {
            document.getElementById('deptId').required = <%= isHr ? "false" : "true" %>;
        }
        toggleDepartmentRequirement();
    </script>
</body>
</html>
