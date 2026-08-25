<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Reports</title></head>
<body>
    <h1>Reports</h1>
    <p><%= request.getAttribute("message") %></p>
    <a href="<%= request.getContextPath() %>/DashboardServlet">Back to dashboard</a>
</body>
</html>