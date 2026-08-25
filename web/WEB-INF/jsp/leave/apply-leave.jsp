<%-- This page lets an employee submit a new leave request.
     The form collects leave details, while validation and day calculation
     are enforced on the server through ApplyLeaveServlet and LeaveService. --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.leave.model.LeaveType" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.List" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    String today = LocalDate.now().toString();
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
    String error = (String) request.getAttribute("error");
    String selectedLeaveTypeId = (String) request.getAttribute("selectedLeaveTypeId");
    String fromDate = (String) request.getAttribute("fromDate");
    String toDate = (String) request.getAttribute("toDate");
    String reason = (String) request.getAttribute("reason");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Leave</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .navbar {
            background: #222; color: #fff; padding: 18px 30px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .navbar a { color: #fff; text-decoration: none; }
        .container { max-width: 720px; margin: 30px auto; padding: 0 20px; }
        .card {
            background: #fff; border-radius: 10px; padding: 30px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }
        h1 { font-size: 26px; margin-bottom: 8px; }
        .subtitle { color: #666; margin-bottom: 24px; font-size: 14px; }
        .alert {
            padding: 12px 14px; border-radius: 6px; margin-bottom: 18px; font-size: 14px;
        }
        .alert-error { background: #fdecea; color: #c0392b; border: 1px solid #f5c6cb; }
        .form-group { margin-bottom: 18px; }
        label { display: block; font-size: 14px; margin-bottom: 6px; color: #444; }
        input, select, textarea {
            width: 100%; padding: 10px 12px; border: 1px solid #ccc;
            border-radius: 6px; font-size: 14px;
        }
        textarea { min-height: 90px; resize: vertical; }
        .days-hint { margin-top: 6px; font-size: 13px; color: #666; }
        .actions {
            display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px;
        }
        .btn {
            padding: 10px 18px; border: none; border-radius: 6px;
            font-size: 14px; cursor: pointer; text-decoration: none;
            display: inline-block;
        }
        .btn-secondary { background: #e9ecef; color: #333; }
        .btn-primary { background: #222; color: #fff; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <div class="page-content">
    <div class="container">
        <div class="card">
            <h1>Apply for Leave</h1>
            <p class="subtitle">Submit a new leave request for HR review.</p>

            <% if (error != null) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/ApplyLeaveServlet" method="post" id="leaveForm">
                <div class="form-group">
                    <label for="leaveTypeId">Leave Type</label>
                    <select name="leaveTypeId" id="leaveTypeId" required>
                        <option value="">Select leave type</option>
                        <% if (leaveTypes != null) {
                               for (LeaveType type : leaveTypes) { %>
                            <option value="<%= type.getLeaveTypeId() %>"
                                <%= String.valueOf(type.getLeaveTypeId()).equals(selectedLeaveTypeId) ? "selected" : "" %>>
                                <%= type.getDisplayName() %>
                            </option>
                        <%   }
                           } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="fromDate">From Date</label>
                    <input type="date" name="fromDate" id="fromDate"
                           value="<%= fromDate != null ? fromDate : "" %>"
                           min="<%= today %>" required>
                </div>

                <div class="form-group">
                    <label for="toDate">To Date</label>
                    <input type="date" name="toDate" id="toDate"
                           value="<%= toDate != null ? toDate : "" %>"
                           min="<%= today %>" required>
                </div>

                <div class="days-hint" id="daysHint">Number of days will be calculated automatically.</div>

                <div class="form-group" style="margin-top: 18px;">
                    <label for="reason">Reason</label>
                    <textarea name="reason" id="reason" required><%= reason != null ? reason : "" %></textarea>
                </div>

                <div class="actions">
                    <a class="btn btn-secondary"
                       href="<%= request.getContextPath() %>/EmployeeDashboardServlet">Cancel</a>
                    <button type="submit" class="btn btn-primary">Submit</button>
                </div>
            </form>
                      <a href="<%= request.getContextPath() %>/EmployeeLeaveMenuServlet"
                   class="back-link">

                    &larr; Back to Leave

                </a>
        </div>
                    
    </div>

    <script>
        function updateDaysHint() {
            const from = document.getElementById('fromDate').value;
            const to = document.getElementById('toDate').value;
            const hint = document.getElementById('daysHint');
            if (!from || !to) {
                hint.textContent = 'Number of days will be calculated automatically.';
                return;
            }
            const start = new Date(from);
            const end = new Date(to);
            if (end < start) {
                hint.textContent = 'To date cannot be before from date.';
                return;
            }
            const diff = Math.floor((end - start) / (1000 * 60 * 60 * 24)) + 1;
            hint.textContent = diff + (diff === 1 ? ' day' : ' days');
        }
        document.getElementById('fromDate').addEventListener('change', updateDaysHint);
        document.getElementById('toDate').addEventListener('change', updateDaysHint);
        updateDaysHint();
    </script>
    </div>
</body>
</html>
