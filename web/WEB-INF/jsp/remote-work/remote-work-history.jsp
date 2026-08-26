<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.RemoteWork" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    List<RemoteWork> remoteRequests = (List<RemoteWork>) request.getAttribute("remoteRequests");
    String success = (String) request.getAttribute("success");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Work From Home History</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: #f2f4f7; color: #222; font-family: var(--app-font, Georgia, 'Times New Roman', serif); }
        .page-content { padding: 38px; }
        .container { max-width: 1000px; margin: 0 auto; }
        .card { padding: 28px; border-radius: 10px; background: #fff; box-shadow: 0 3px 10px rgba(0,0,0,.08); }
        h1 { margin: 0 0 8px; font-size: 28px; }
        .subtitle { margin: 0 0 22px; color: #666; }
        .success { margin-bottom: 18px; padding: 12px 14px; border-left: 4px solid #222; background: #f0f0f0; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 13px 10px; border-bottom: 1px solid #eee; text-align: left; font-size: 14px; }
        th { color: #666; font-weight: 600; }
        .status { display: inline-block; padding: 5px 10px; border-radius: 5px; font-size: 12px; font-weight: 600; }
        .pending { background: #f1f1f1; color: #555; }
        .approved { background: #e7f7ec; color: #1f7a3f; }
        .rejected { background: #fdecea; color: #b42318; }
        .empty { padding: 24px 0; color: #777; }
        .back { display: inline-block; margin-top: 20px; color: #333; text-decoration: none; }
        @media (max-width: 700px) { .page-content { padding: 20px; } .card { padding: 20px; overflow-x: auto; } table { min-width: 650px; } }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <main class="page-content"><div class="container"><section class="card">
        <h1>Work From Home History</h1>
        <p class="subtitle">View the status of your work from home requests.</p>
        <% if ("1".equals(success)) { %><div class="success">Your work from home request was submitted successfully.</div><% } %>
        <% if (remoteRequests == null || remoteRequests.isEmpty()) { %>
            <p class="empty">You have not submitted any work from home requests.</p>
        <% } else { %>
            <table><thead><tr><th>Start Date</th><th>End Date</th><th>Requested On</th><th>Status</th></tr></thead><tbody>
            <% for (RemoteWork item : remoteRequests) { %><tr>
                <td><%= item.getStartDate() == null ? "-" : item.getStartDate().toLocalDate().format(dateFormatter) %></td>
                <td><%= item.getEndDate() == null ? "-" : item.getEndDate().toLocalDate().format(dateFormatter) %></td>
                <td><%= item.getRequestedOn() == null ? "-" : item.getRequestedOn().toLocalDate().format(dateFormatter) %></td>
                <td><span class="status <%= item.getStatus() == null ? "" : item.getStatus().toLowerCase() %>"><%= item.getStatus() == null ? "Unknown" : item.getStatus() %></span></td>
            </tr><% } %></tbody></table>
        <% } %>
        <a class="back" href="<%= request.getContextPath() %>/EmployeeLeaveMenuServlet">&larr; Back to Leave</a>
    </section></div></main>
</body>
</html>
