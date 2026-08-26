<%-- This page gives admin users a read-only leave overview and record browser.
     Admin can monitor statistics and recent activity but does not approve leave;
     HR remains responsible for review, approval, and rejection decisions. --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.leave.model.*" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%
    Employee admin = (Employee) session.getAttribute("employee");
    if (admin == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    String viewMode = (String) request.getAttribute("viewMode");
    boolean recordsView = "records".equals(viewMode);
    LeaveStatistics stats = (LeaveStatistics) request.getAttribute("leaveStats");
    List<Leave> recentActivity = (List<Leave>) request.getAttribute("recentActivity");
    List<Leave> leaveRecords = (List<Leave>) request.getAttribute("leaveRecords");
    LeaveStatus statusFilter = (LeaveStatus) request.getAttribute("statusFilter");
    Integer leaveTypeIdFilter = (Integer) request.getAttribute("leaveTypeIdFilter");
    String employeeSearch = (String) request.getAttribute("employeeSearch");
    String fromDate = (String) request.getAttribute("fromDate");
    String toDate = (String) request.getAttribute("toDate");
    LeaveStatus[] leaveStatuses = (LeaveStatus[]) request.getAttribute("leaveStatuses");
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd MMM");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Overview</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: var(--app-font, Georgia, 'Times New Roman', serif); background: #f2f4f7; color: #222; }
        .container { max-width: 1100px; margin: 30px auto; padding: 0 20px; }
        .card {
            background: #fff; border-radius: 10px; padding: 28px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08); margin-bottom: 20px;
        }
        h1 { font-size: 26px; margin-bottom: 8px; }
        .subtitle { color: #666; margin-bottom: 20px; font-size: 14px; }
        .stats {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 16px; margin-bottom: 24px;
        }
        .stat-box {
            background: #fafbfc; border: 1px solid #eceff3; border-radius: 8px;
            padding: 18px;
        }
        .stat-label { font-size: 13px; color: #666; margin-bottom: 8px; }
        .stat-value { font-size: 28px; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; }
        th, td {
            padding: 12px 10px; border-bottom: 1px solid #eee; text-align: left; font-size: 14px;
        }
        th { color: #666; font-weight: 600; }
        .status {
            display: inline-block; padding: 4px 10px; border-radius: 999px;
            font-size: 12px; font-weight: 600;
        }
        .status-SUBMITTED { background: #e8f1ff; color: #1f5fbf; }
        .status-UNDER_REVIEW { background: #fff4d6; color: #9a6b00; }
        .status-APPROVED { background: #e7f7ec; color: #1f7a3f; }
        .status-REJECTED { background: #fdecea; color: #b42318; }
        .status-CANCELLED { background: #f1f3f5; color: #5f6368; }
        .btn {
            padding: 9px 16px; border: none; border-radius: 6px;
            font-size: 14px; cursor: pointer; text-decoration: none;
            display: inline-block; background: #222; color: #fff;
        }
        .btn-secondary { background: #e9ecef; color: #333; }
        .filters {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px; margin-bottom: 20px;
        }
        label { display: block; font-size: 12px; color: #666; margin-bottom: 4px; }
        input, select {
            width: 100%; padding: 8px 10px; border: 1px solid #ccc;
            border-radius: 6px; font-size: 14px;
        }
        .empty { color: #777; padding: 16px 0; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <div class="page-content">
    <div class="container">
        <div class="card">
            <h1><%= recordsView ? "Leave Records" : "Leave Overview" %></h1>
            <p class="subtitle">
                <%= recordsView
                    ? "Search and inspect leave records across the organization."
                    : "Monitor leave workflow activity without performing HR approvals." %>
            </p>

            <% if (!recordsView && stats != null) { %>
                <div class="stats">
                    <div class="stat-box">
                        <div class="stat-label">Total Requests</div>
                        <div class="stat-value"><%= stats.getTotalRequests() %></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-label">Pending</div>
                        <div class="stat-value"><%= stats.getPending() %></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-label">Approved</div>
                        <div class="stat-value"><%= stats.getApproved() %></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-label">Rejected</div>
                        <div class="stat-value"><%= stats.getRejected() %></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-label">Cancelled</div>
                        <div class="stat-value"><%= stats.getCancelled() %></div>
                    </div>
                </div>

                <h2 style="font-size:18px; margin-bottom: 12px;">Recent Leave Activity</h2>
                <% if (recentActivity == null || recentActivity.isEmpty()) { %>
                    <div class="empty">No recent leave activity found.</div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Leave Type</th>
                                <th>Dates</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Leave leave : recentActivity) { %>
                                <tr>
                                    <td><%= leave.getEmployeeName() %></td>
                                    <td><%= leave.getLeaveType().getDisplayName() %></td>
                                    <td>
                                        <%= leave.getFromDate().format(dateFmt) %>
                                        <% if (!leave.getFromDate().equals(leave.getToDate())) { %>
                                            - <%= leave.getToDate().format(dateFmt) %>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="status status-<%= leave.getStatus().name() %>">
                                            <%= leave.getStatus().getDisplayName() %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>

                <div style="margin-top: 20px;">
                    <a class="btn"
                       href="<%= request.getContextPath() %>/AdminLeaveOverviewServlet?view=records">
                        View Leave Records
                    </a>
                </div>
            <% } else { %>
                <form class="filters" method="get"
                      action="<%= request.getContextPath() %>/AdminLeaveOverviewServlet">
                    <input type="hidden" name="view" value="records">
                    <div>
                        <label for="search">Search Employee</label>
                        <input type="text" name="search" id="search"
                               value="<%= employeeSearch != null ? employeeSearch : "" %>">
                    </div>
                    <div>
                        <label for="status">Status</label>
                        <select name="status" id="status">
                            <option value="">All statuses</option>
                            <% for (LeaveStatus status : leaveStatuses) { %>
                                <option value="<%= status.name() %>"
                                    <%= status == statusFilter ? "selected" : "" %>>
                                    <%= status.getDisplayName() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    <div>
                        <label for="leaveTypeId">Leave Type</label>
                        <select name="leaveTypeId" id="leaveTypeId">
                            <option value="">All types</option>
                            <% if (leaveTypes != null) {
                                   for (LeaveType type : leaveTypes) { %>
                                <option value="<%= type.getLeaveTypeId() %>"
                                    <%= type.getLeaveTypeId() == (leaveTypeIdFilter != null ? leaveTypeIdFilter : -1) ? "selected" : "" %>>
                                    <%= type.getDisplayName() %>
                                </option>
                            <%   }
                               } %>
                        </select>
                    </div>
                    <div>
                        <label for="fromDate">From Date</label>
                        <input type="date" name="fromDate" id="fromDate"
                               value="<%= fromDate != null ? fromDate : "" %>">
                    </div>
                    <div>
                        <label for="toDate">To Date</label>
                        <input type="date" name="toDate" id="toDate"
                               value="<%= toDate != null ? toDate : "" %>">
                    </div>
                    <div style="display:flex; align-items:end; gap:10px;">
                        <button type="submit" class="btn">Search</button>
                        <a class="btn btn-secondary"
                           href="<%= request.getContextPath() %>/AdminLeaveOverviewServlet">
                            Back to Overview
                        </a>
                    </div>
                </form>

                <% if (leaveRecords == null || leaveRecords.isEmpty()) { %>
                    <div class="empty">No leave records found.</div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Type</th>
                                <th>Dates</th>
                                <th>Days</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Leave leave : leaveRecords) { %>
                                <tr>
                                    <td><%= leave.getEmployeeName() %></td>
                                    <td><%= leave.getLeaveType().getDisplayName() %></td>
                                    <td>
                                        <%= leave.getFromDate().format(dateFmt) %>
                                        <% if (!leave.getFromDate().equals(leave.getToDate())) { %>
                                            - <%= leave.getToDate().format(dateFmt) %>
                                        <% } %>
                                    </td>
                                    <td><%= leave.getNumDays() %></td>
                                    <td>
                                        <span class="status status-<%= leave.getStatus().name() %>">
                                            <%= leave.getStatus().getDisplayName() %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            <% } %>
        </div>
    </div>
    </div>
</body>
</html>
