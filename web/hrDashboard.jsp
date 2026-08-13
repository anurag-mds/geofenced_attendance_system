<%-- This page is the HR landing screen after login.
     It links HR users into the dedicated leave request workflow without
     mixing attendance or admin responsibilities into the same screen. --%>
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
    <title>HR Dashboard</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; }
        .card {
            background: #fff; border-radius: 10px; padding: 30px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08); margin-bottom: 20px;
        }
        h1 { font-size: 28px; margin-bottom: 8px; }
        p { color: #666; margin-bottom: 18px; }
        .links { display: flex; flex-wrap: wrap; gap: 12px; }
        .btn {
            display: inline-block; padding: 12px 18px; border-radius: 6px;
            text-decoration: none; background: #222; color: #fff; font-size: 14px;
        }
        .btn-secondary { background: #e9ecef; color: #333; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <div class="page-content">
        <div class="container">
            <div class="card">
                <h1>Welcome, <%= employee.getFullName() %></h1>
                <p>Manage employee leave requests and review pending approvals.</p>
                <div class="links">
                    <a class="btn" href="HrLeaveRequestsServlet">Leave Requests</a>
                    <a class="btn btn-secondary" href="HrLeaveRequestsServlet?status=SUBMITTED">Pending Requests</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
