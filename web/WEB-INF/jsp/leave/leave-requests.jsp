<%-- This page is the HR leave request management list.
     HR can search and filter requests here, then open a request for review,
     approval, or rejection through the dedicated detail workflow page. --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.leave.model.*" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%
    Employee hr = (Employee) session.getAttribute("employee");
    if (hr == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd MMM");
    List<Leave> leaveRequests = (List<Leave>) request.getAttribute("leaveRequests");
    LeaveStatus statusFilter = (LeaveStatus) request.getAttribute("statusFilter");
    Integer leaveTypeIdFilter = (Integer) request.getAttribute("leaveTypeIdFilter");
    String employeeSearch = (String) request.getAttribute("employeeSearch");
    String fromDate = (String) request.getAttribute("fromDate");
    String toDate = (String) request.getAttribute("toDate");
    LeaveStatus[] leaveStatuses = (LeaveStatus[]) request.getAttribute("leaveStatuses");
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Requests</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .navbar {
            background: #222; color: #fff; padding: 18px 30px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .navbar a { color: #fff; text-decoration: none; }
        .container { max-width: 1100px; margin: 30px auto; padding: 0 20px; }
        .card {
            background: #fff; border-radius: 10px; padding: 28px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }
        h1 { font-size: 26px; margin-bottom: 8px; }
        .subtitle { color: #666; margin-bottom: 20px; font-size: 14px; }
        .tabs { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; }
        .tab {
            padding: 8px 14px; border-radius: 999px; text-decoration: none;
            font-size: 13px; background: #f1f3f5; color: #333;
        }
        .tab.active { background: #222; color: #fff; }
        .filters {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px; margin-bottom: 20px;
        }
        label { display: block; font-size: 12px; color: #666; margin-bottom: 4px; }
        input, select {
            width: 100%; padding: 8px 10px; border: 1px solid #ccc;
            border-radius: 6px; font-size: 14px;
        }
        .btn {
            padding: 9px 16px; border: none; border-radius: 6px;
            font-size: 14px; cursor: pointer; text-decoration: none;
            display: inline-block; background: #222; color: #fff;
        }
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
        .empty { color: #777; padding: 20px 0; }
    </style>
</head>
<body>
    <div class="navbar">
        <a href="<%= request.getContextPath() %>/hrDashboard.jsp">HR Dashboard</a>
        <span><%= hr.getFullName() %></span>
    </div>

    <div class="container">
        <div class="card">
            <h1>Leave Requests</h1>
            <p class="subtitle">Review employee leave requests and take HR action.</p>

            <div class="tabs">
                <a class="tab <%= statusFilter == null ? "active" : "" %>"
                   href="<%= request.getContextPath() %>/HrLeaveRequestsServlet">All</a>
                <% for (LeaveStatus status : new LeaveStatus[] {
                        LeaveStatus.SUBMITTED, LeaveStatus.UNDER_REVIEW,
                        LeaveStatus.APPROVED, LeaveStatus.REJECTED, LeaveStatus.CANCELLED }) { %>
                    <a class="tab <%= status == statusFilter ? "active" : "" %>"
                       href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=<%= status.name() %>">
                        <%= status.getDisplayName() %>
                    </a>
                <% } %>
            </div>

            <form class="filters" method="get" action="<%= request.getContextPath() %>/HrLeaveRequestsServlet">
                <% if (statusFilter != null) { %>
                    <input type="hidden" name="status" value="<%= statusFilter.name() %>">
                <% } %>
                <div>
                    <label for="search">Search Employee</label>
                    <input type="text" name="search" id="search"
                           value="<%= employeeSearch != null ? employeeSearch : "" %>"
                           placeholder="Name or employee code">
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
                <div style="display:flex; align-items:end;">
                    <button type="submit" class="btn">Apply Filters</button>
                </div>
            </form>

            <% if (leaveRequests == null || leaveRequests.isEmpty()) { %>
                <div class="empty">No leave requests found.</div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Employee</th>
                            <th>Type</th>
                            <th>Dates</th>
                            <th>Days</th>
                            <th>Status</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Leave leave : leaveRequests) { %>
                            <tr>
                                <td>
                                    <%= leave.getEmployeeName() %>
                                    <% if (leave.getEmpCode() != null) { %>
                                        <div style="font-size:12px;color:#777;"><%= leave.getEmpCode() %></div>
                                    <% } %>
                                </td>
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
                                <td>
                                    <a href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?id=<%= leave.getLeaveId() %>">
                                        Open
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
</body>
</html>
