<%-- This page shows an employee's own leave history and request details.
     Employees can filter records, view HR remarks, and cancel or edit only
     requests that LeaveService still considers eligible for those actions. --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.leave.model.*" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd MMM yyyy");
    List<Leave> leaveHistory = (List<Leave>) request.getAttribute("leaveHistory");
    Leave selectedLeave = (Leave) request.getAttribute("selectedLeave");
    LeaveStatus statusFilter = (LeaveStatus) request.getAttribute("statusFilter");
    Integer leaveTypeIdFilter = (Integer) request.getAttribute("leaveTypeIdFilter");
    LeaveStatus[] leaveStatuses = (LeaveStatus[]) request.getAttribute("leaveStatuses");
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
    String success = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Leave History</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .navbar {
            background: #222; color: #fff; padding: 18px 30px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .navbar a { color: #fff; text-decoration: none; }
        .container { max-width: 980px; margin: 30px auto; padding: 0 20px; }
        .card {
            background: #fff; border-radius: 10px; padding: 28px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08); margin-bottom: 20px;
        }
        h1 { font-size: 26px; margin-bottom: 8px; }
        .subtitle { color: #666; margin-bottom: 20px; font-size: 14px; }
        .toolbar {
            display: flex; flex-wrap: wrap; gap: 12px; align-items: end;
            margin-bottom: 20px;
        }
        .toolbar label { font-size: 13px; color: #555; display: block; margin-bottom: 4px; }
        select, input, textarea {
            padding: 8px 10px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px;
        }
        .btn {
            padding: 9px 16px; border: none; border-radius: 6px;
            font-size: 14px; cursor: pointer; text-decoration: none;
            display: inline-block;
        }
        .btn-primary { background: #222; color: #fff; }
        .btn-secondary { background: #e9ecef; color: #333; }
        .btn-danger { background: #e74c3c; color: #fff; }
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
        .alert {
            padding: 12px 14px; border-radius: 6px; margin-bottom: 16px; font-size: 14px;
        }
        .alert-success { background: #e7f7ec; color: #1f7a3f; }
        .alert-error { background: #fdecea; color: #c0392b; }
        .detail-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 10px;
        }
        .detail-item label { display: block; font-size: 12px; color: #777; margin-bottom: 4px; }
        .detail-item div { font-size: 15px; }
        .actions { display: flex; gap: 10px; margin-top: 18px; flex-wrap: wrap; }
        .empty { color: #777; padding: 20px 0; }
        @media (max-width: 700px) {
            .detail-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <div class="page-content">
    <div class="container">
        <div class="card">
            <h1>My Leave History</h1>
            <p class="subtitle">View the status of your leave requests and HR remarks.</p>

            <% if ("applied".equals(success)) { %>
                <div class="alert alert-success">Leave request submitted successfully.</div>
            <% } else if ("cancelled".equals(success)) { %>
                <div class="alert alert-success">Leave request cancelled successfully.</div>
            <% } else if ("modified".equals(success)) { %>
                <div class="alert alert-success">Leave request updated successfully.</div>
            <% } %>
            <% if (errorMsg != null && !errorMsg.isBlank()) { %>
                <div class="alert alert-error"><%= errorMsg %></div>
            <% } %>

            <form class="toolbar" method="get" action="<%= request.getContextPath() %>/LeaveHistoryServlet">
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
                <button type="submit" class="btn btn-primary">Filter</button>
                <a class="btn btn-secondary"
                   href="<%= request.getContextPath() %>/ApplyLeaveServlet">Apply for Leave</a>
            </form>

            <% if (leaveHistory == null || leaveHistory.isEmpty()) { %>
                <div class="empty">No leave requests found.</div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Type</th>
                            <th>Dates</th>
                            <th>Days</th>
                            <th>Status</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Leave leave : leaveHistory) { %>
                            <tr>
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
                                    <a href="<%= request.getContextPath() %>/LeaveHistoryServlet?id=<%= leave.getLeaveId() %>">
                                        View
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>

        <% if (selectedLeave != null) { %>
            <div class="card">
                <h2 style="margin-bottom: 16px;">Leave Request Details</h2>
                <div class="detail-grid">
                    <div class="detail-item">
                        <label>Leave Type</label>
                        <div><%= selectedLeave.getLeaveType().getDisplayName() %></div>
                    </div>
                    <div class="detail-item">
                        <label>Status</label>
                        <div>
                            <span class="status status-<%= selectedLeave.getStatus().name() %>">
                                <%= selectedLeave.getStatus().getDisplayName() %>
                            </span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <label>From</label>
                        <div><%= selectedLeave.getFromDate().format(dateFmt) %></div>
                    </div>
                    <div class="detail-item">
                        <label>To</label>
                        <div><%= selectedLeave.getToDate().format(dateFmt) %></div>
                    </div>
                    <div class="detail-item">
                        <label>Duration</label>
                        <div><%= selectedLeave.getNumDays() %> day(s)</div>
                    </div>
                    <div class="detail-item">
                        <label>Submitted</label>
                        <div>
                            <%= selectedLeave.getSubmittedAt() != null
                                ? selectedLeave.getSubmittedAt().format(dateFmt) : "-" %>
                        </div>
                    </div>
                </div>
                <div class="detail-item" style="margin-top: 16px;">
                    <label>Reason</label>
                    <div><%= selectedLeave.getReason() %></div>
                </div>
                <% if (selectedLeave.getHrRemark() != null && !selectedLeave.getHrRemark().isBlank()) { %>
                    <div class="detail-item" style="margin-top: 16px;">
                        <label>HR Remark</label>
                        <div><%= selectedLeave.getHrRemark() %></div>
                    </div>
                <% } %>

                <div class="actions">
                    <% if (selectedLeave.getStatus().isEmployeeCancellable()) { %>
                        <form method="post" action="<%= request.getContextPath() %>/CancelLeaveServlet"
                              onsubmit="return confirm('Cancel this leave request?');">
                            <input type="hidden" name="leaveId" value="<%= selectedLeave.getLeaveId() %>">
                            <button type="submit" class="btn btn-danger">Cancel Request</button>
                        </form>
                    <% } %>
                    <a class="btn btn-secondary"
                       href="<%= request.getContextPath() %>/LeaveHistoryServlet">Back to List</a>
                </div>

                <% if (selectedLeave.getStatus().isEmployeeModifiable()) { %>
                    <hr style="margin: 24px 0; border: none; border-top: 1px solid #eee;">
                    <h3 style="margin-bottom: 14px;">Edit Request</h3>
                    <form method="post" action="<%= request.getContextPath() %>/ModifyLeaveServlet">
                        <input type="hidden" name="leaveId" value="<%= selectedLeave.getLeaveId() %>">
                        <div class="toolbar">
                            <div>
                                <label for="editLeaveTypeId">Leave Type</label>
                                <select name="leaveTypeId" id="editLeaveTypeId" required>
                                    <% if (leaveTypes != null) {
                                           for (LeaveType type : leaveTypes) { %>
                                        <option value="<%= type.getLeaveTypeId() %>"
                                            <%= type.getLeaveTypeId() == selectedLeave.getLeaveType().getLeaveTypeId() ? "selected" : "" %>>
                                            <%= type.getDisplayName() %>
                                        </option>
                                    <%   }
                                       } %>
                                </select>
                            </div>
                            <div>
                                <label for="editFromDate">From Date</label>
                                <input type="date" name="fromDate" id="editFromDate"
                                       value="<%= selectedLeave.getFromDate() %>" required>
                            </div>
                            <div>
                                <label for="editToDate">To Date</label>
                                <input type="date" name="toDate" id="editToDate"
                                       value="<%= selectedLeave.getToDate() %>" required>
                            </div>
                        </div>
                        <div style="margin-top: 12px;">
                            <label for="editReason">Reason</label>
                            <textarea name="reason" id="editReason" required><%= selectedLeave.getReason() %></textarea>
                        </div>
                        <div class="actions">
                            <button type="submit" class="btn btn-primary">Save Changes</button>
                        </div>
                    </form>
                <% } %>
            </div>
        <% } %>
    </div>
    </div>
</body>
</html>
