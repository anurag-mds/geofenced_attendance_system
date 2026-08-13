<%-- This page is the Admin landing screen after login.
     It provides administrative navigation, including read-only leave monitoring,
     while keeping HR as the sole role responsible for leave approvals. --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
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
            display: inline-block; padding: 12px 18px; border-radius: 6px;
            text-decoration: none; background: #222; color: #fff; font-size: 14px;
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <div class="page-content">
        <div class="container">
            <div class="card">
                <h1>Welcome, <%= employee.getFullName() %></h1>
                <p>Monitor system activity and review administrative leave information.</p>
                <a class="btn" href="AdminLeaveOverviewServlet">Leave Overview</a>
            </div>
        </div>
    </div>
</body>
</html>
