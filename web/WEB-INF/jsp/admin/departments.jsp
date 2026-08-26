<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Department" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.Role" %>
<%@ page import="java.util.List" %>
<%
    List<Department> departments = (List<Department>) request.getAttribute("departments");
    List<Employee> hrEmployees = (List<Employee>) request.getAttribute("hrEmployees");
    String error = request.getParameter("error");
    Employee current = (Employee) session.getAttribute("employee");
    boolean adminView = current != null && current.getRole() == Role.ADMIN;
    Department editingDepartment = (Department) request.getAttribute("editingDepartment");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Departments</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        body { font-family: var(--app-font, Georgia, 'Times New Roman', serif); background: #f2f4f7; color: #222; }
        .page-content { padding: 30px 20px; }
        .container { max-width: 1000px; margin: auto; }
        .card { background: #fff; padding: 24px; margin-bottom: 20px; border-radius: 8px; box-shadow: 0 3px 10px rgba(0,0,0,.08); }
        h1, h2 { margin-bottom: 16px; }
        form { display: flex; gap: 10px; flex-wrap: wrap; }
        input, button { padding: 11px 12px; border: 1px solid #ccd1d6; border-radius: 5px; font-size: 14px; }
        button { background: #222; color: #fff; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 12px 10px; border-bottom: 1px solid #e5e7eb; }
        th { background: #f7f7f7; }
        .muted { color: #666; }
        .actions { display: flex; gap: 6px; align-items: center; }
        .actions form { margin: 0; }
        .action { display: inline-flex; align-items: center; justify-content: center; box-sizing: border-box; min-width: 86px; min-height: 32px; padding: 0 9px; border: 1px solid #ccd1d6; border-radius: 5px; background: #fff; color: #24292f; text-decoration: none; font: 12px Arial, sans-serif; line-height: 1; cursor: pointer; }
        .danger { color: #cf222e; }
        .status-active { color: #1f7a3f; font-weight: 600; }
        .status-inactive { color: #6e7781; font-weight: 600; }
        .toast { position: fixed; right: 22px; bottom: 22px; z-index: 2000; padding: 14px 18px; border-radius: 6px; background: #1f883d; color: #fff; box-shadow: 0 6px 20px rgba(27,31,36,.2); }
        .toast.error { background: #cf222e; }
        .confirm-dialog[hidden] { display: none; }
        .confirm-dialog { position: fixed; inset: 0; z-index: 2000; display: grid; place-items: center; padding: 20px; }
        .confirm-backdrop { position: absolute; inset: 0; background: rgba(0, 0, 0, .72); backdrop-filter: blur(4px); }
        .confirm-panel { position: relative; width: min(440px, 100%); padding: 30px; background: #fff; border: 1px solid #171717; border-radius: 8px; box-shadow: 10px 10px 0 #171717; }
        .confirm-panel h2 { margin: 0 0 10px; }
        .confirm-panel p { color: #666; line-height: 1.5; }
        .confirm-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; }
        .confirm-actions button { min-width: 110px; }
        .confirm-cancel { background: #fff; color: #171717; }
        .confirm-submit { background: #cf222e; border-color: #cf222e; color: #fff; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <main class="page-content"><div class="container">
        <div class="card">
            <h1>Departments</h1>
            <p class="muted">Available departments and their active employee counts.</p>
            <% if ("hrRequired".equals(error)) { %><p class="muted">Select an HR representative before creating a department.</p><% } %>
            <% if (editingDepartment != null) { %>
            <form method="post" action="<%= request.getContextPath() %>/DepartmentServlet">
                <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                <input type="hidden" name="action" value="update"><input type="hidden" name="deptId" value="<%= editingDepartment.getDeptId() %>">
                <input name="deptName" value="<%= editingDepartment.getDeptName() %>" maxlength="50" required>
                <input name="deptCode" value="<%= editingDepartment.getDeptCode() %>" readonly>
                <button type="submit">Save Department</button>
                <a class="action" href="<%= request.getContextPath() %>/DepartmentServlet">Cancel</a>
            </form>
            <% } else if (hrEmployees == null || hrEmployees.isEmpty()) { %>
                <p class="muted">No unassigned active HR is available. Create an HR employee first, then return here to create a department.</p>
            <% } else { %>
            <form method="post" action="<%= request.getContextPath() %>/DepartmentServlet">
                <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                <input type="hidden" name="action" value="add">
                <input name="deptName" placeholder="Department name" required>
                <select name="hrEmployeeId" required>
                    <option value="">Assign HR representative</option>
                    <% if (hrEmployees != null) { for (Employee hr : hrEmployees) { %>
                        <option value="<%= hr.getEmpId() %>"><%= hr.getEmpCode() %> - <%= hr.getFullName() %></option>
                    <% }} %>
                </select>
                <button type="submit">Add Department</button>
            </form>
            <% } %>
        </div>
        <div class="card">
            <table>
                <thead><tr><th>Name</th><th>Code</th><th>Active employees</th><th>Status</th><% if (adminView) { %><th>Actions</th><% } %></tr></thead>
                <tbody>
                <% if (departments != null) { for (Department department : departments) { %>
                    <tr>
                        <td><%= department.getDeptName() %></td>
                        <td><%= department.getDeptCode() %></td>
                        <td><%= department.getActiveEmployeeCount() %></td>
                        <td class="<%= department.isActive() ? "status-active" : "status-inactive" %>"><%= department.isActive() ? "ACTIVE" : "INACTIVE" %></td>
                        <% if (adminView) { %><td><div class="actions">
                            <a class="action" href="<%= request.getContextPath() %>/DepartmentServlet?edit=<%= department.getDeptId() %>">Edit</a>
                            <form class="department-action-form" method="post" action="<%= request.getContextPath() %>/DepartmentServlet">
                                <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                                <input type="hidden" name="action" value="toggle"><input type="hidden" name="deptId" value="<%= department.getDeptId() %>"><input type="hidden" name="active" value="<%= !department.isActive() %>">
                                <button class="action <%= department.isActive() ? "danger" : "" %>" type="submit"><%= department.isActive() ? "Deactivate" : "Activate" %></button>
                            </form>
                            <form class="department-action-form" method="post" action="<%= request.getContextPath() %>/DepartmentServlet">
                                <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                                <input type="hidden" name="action" value="delete"><input type="hidden" name="deptId" value="<%= department.getDeptId() %>">
                                <button class="action danger" type="submit">Delete</button>
                            </form>
                        </div></td><% } %>
                    </tr>
                <% }} %>
                </tbody>
            </table>
        </div>
    </div></main>
    <div class="confirm-dialog" id="confirmDialog" hidden>
        <div class="confirm-backdrop" data-close-confirm></div>
        <section class="confirm-panel" role="dialog" aria-modal="true" aria-labelledby="confirmTitle">
            <h2 id="confirmTitle">Confirm department action</h2>
            <p id="confirmMessage"></p>
            <div class="confirm-actions">
                <button class="confirm-cancel" type="button" data-close-confirm>Cancel</button>
                <button class="confirm-submit" type="button" id="confirmSubmit">Confirm</button>
            </div>
        </section>
    </div>
    <% String success = request.getParameter("success"); %>
    <% if (success != null || error != null && !"hrRequired".equals(error)) { %>
        <div class="toast <%= error != null ? "error" : "" %>"><%= error != null ? "Department operation failed." : "Department updated successfully." %></div>
        <script>setTimeout(function () { document.querySelector('.toast').remove(); }, 4500);</script>
    <% } %>
    <script>
        (function () {
            const dialog = document.getElementById('confirmDialog');
            const message = document.getElementById('confirmMessage');
            const submit = document.getElementById('confirmSubmit');
            let pendingForm;
            document.querySelectorAll('.department-action-form').forEach(function (form) {
                form.addEventListener('submit', function (event) {
                    event.preventDefault();
                    pendingForm = form;
                    const action = form.querySelector('input[name="action"]').value;
                    const isDelete = action === 'delete';
                    message.textContent = isDelete
                        ? 'Delete this department? This is allowed only when no employees are assigned.'
                        : (form.querySelector('input[name="active"]').value === 'true'
                            ? 'Activate this department?' : 'Deactivate this department?');
                    submit.textContent = isDelete ? 'Delete' : 'Confirm';
                    submit.classList.toggle('confirm-submit', isDelete);
                    dialog.hidden = false;
                    submit.focus();
                });
            });
            function closeDialog() { dialog.hidden = true; pendingForm = null; }
            document.querySelectorAll('[data-close-confirm]').forEach(function (element) {
                element.addEventListener('click', closeDialog);
            });
            submit.addEventListener('click', function () {
                if (pendingForm) pendingForm.submit();
            });
        }());
    </script>
</body>
</html>
