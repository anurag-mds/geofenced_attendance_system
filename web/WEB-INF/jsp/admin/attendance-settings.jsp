<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null || employee.getRole() != com.nimbus.admin.model.Role.ADMIN) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Attendance Settings</title></head>
<body>
    <h1>Attendance Settings</h1>
    <p><%= request.getAttribute("message") %></p>
    <a href="<%= request.getContextPath() %>/DashboardServlet">Back to dashboard</a>
</body>
</html>