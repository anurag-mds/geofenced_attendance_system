<%-- This page shows a single leave request for HR review and action.
     HR can move a request under review, approve it, or reject it with remarks,
     while the backend enforces that only authorized HR users may act. --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.leave.model.*" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Employee hr = (Employee) session.getAttribute("employee");
    if (hr == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    Leave leave = (Leave) request.getAttribute("selectedLeave");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("errorMsg");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd MMM yyyy");
    DateTimeFormatter dateTimeFmt = DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Request</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f2f4f7; color: #222; }
        .navbar {
            background: #222; color: #fff; padding: 18px 30px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .navbar a { color: #fff; text-decoration: none; }
        .container { max-width: 820px; margin: 30px auto; padding: 0 20px; }
        .card {
            background: #fff; border-radius: 10px; padding: 28px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }
        h1 { font-size: 26px; margin-bottom: 8px; }
        .subtitle { color: #666; margin-bottom: 20px; font-size: 14px; }
        .detail-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;
        }
        .detail-item label { display: block; font-size: 12px; color: #777; margin-bottom: 4px; }
        .detail-item div { font-size: 15px; }
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
        textarea {
            width: 100%; min-height: 90px; padding: 10px 12px;
            border: 1px solid #ccc; border-radius: 6px; font-size: 14px;
        }
        .actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 16px; }
        .btn {
            padding: 10px 16px; border: none; border-radius: 6px;
            font-size: 14px; cursor: pointer; text-decoration: none;
            display: inline-block;
        }
        .btn-secondary { background: #e9ecef; color: #333; }
        .btn-review { background: #fff4d6; color: #9a6b00; }
        .btn-approve { background: #1f7a3f; color: #fff; }
        .btn-reject { background: #e74c3c; color: #fff; }
        .section { margin-top: 24px; padding-top: 20px; border-top: 1px solid #eee; }
        @media (max-width: 700px) { .detail-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>

    <div class="page-content">
    <div class="container">
        <div class="card">
            <h1>Leave Request</h1>
            <p class="subtitle">Review request details and record an HR decision.</p>

            <% if ("under_review".equals(success)) { %>
                <div class="alert alert-success">Request marked as under review.</div>
            <% } else if ("approved".equals(success)) { %>
                <div class="alert alert-success">Leave request approved.</div>
            <% } else if ("rejected".equals(success)) { %>
                <div class="alert alert-success">Leave request rejected.</div>
            <% } %>
            <% if (error != null) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } else if (errorMsg != null && !errorMsg.isBlank()) { %>
                <div class="alert alert-error"><%= errorMsg %></div>
            <% } %>

            <% if (leave == null) { %>
                <div class="alert alert-error">Leave request not found.</div>
            <% } else { %>
                <div class="detail-grid">
                    <div class="detail-item">
                        <label>Employee</label>
                        <div>
                            <%= leave.getEmployeeName() %>
                            <% if (leave.getEmpCode() != null) { %>
                                (<%= leave.getEmpCode() %>)
                            <% } %>
                        </div>
                    </div>
                    <div class="detail-item">
                        <label>Leave Type</label>
                        <div><%= leave.getLeaveType().getDisplayName() %></div>
                    </div>
                    <div class="detail-item">
                        <label>From</label>
                        <div><%= leave.getFromDate().format(dateFmt) %></div>
                    </div>
                    <div class="detail-item">
                        <label>To</label>
                        <div><%= leave.getToDate().format(dateFmt) %></div>
                    </div>
                    <div class="detail-item">
                        <label>Duration</label>
                        <div><%= leave.getNumDays() %> day(s)</div>
                    </div>
                    <div class="detail-item">
                        <label>Submitted</label>
                        <div>
                            <%= leave.getSubmittedAt() != null
                                ? leave.getSubmittedAt().format(dateTimeFmt) : "-" %>
                        </div>
                    </div>
                    <div class="detail-item">
                        <label>Status</label>
                        <div>
                            <span class="status status-<%= leave.getStatus().name() %>">
                                <%= leave.getStatus().getDisplayName() %>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="detail-item">
                    <label>Reason</label>
                    <div><%= leave.getReason() %></div>
                </div>

                <% if (leave.getHrRemark() != null && !leave.getHrRemark().isBlank()) { %>
                    <div class="detail-item" style="margin-top: 16px;">
                        <label>Previous HR Remark</label>
                        <div><%= leave.getHrRemark() %></div>
                    </div>
                <% } %>

                <% if (leave.getStatus().isHrActionable()) { %>
                    <div class="section">
                        <form method="post" action="<%= request.getContextPath() %>/MarkUnderReviewServlet">
                            <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                            <input type="hidden" name="leaveId" value="<%= leave.getLeaveId() %>">
                            <label for="reviewRemark">HR Remark</label>
                            <textarea name="hrRemark" id="reviewRemark"
                                      placeholder="Optional remark before marking under review"></textarea>
                            <div class="actions">
                                <button type="submit" class="btn btn-review">Put Under Review</button>
                            </div>
                        </form>

                        <form method="post" action="<%= request.getContextPath() %>/ApproveLeaveServlet"
                              style="margin-top: 18px;">
                            <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                            <input type="hidden" name="leaveId" value="<%= leave.getLeaveId() %>">
                            <label for="approveRemark">Approval Remark</label>
                            <textarea name="hrRemark" id="approveRemark"
                                      placeholder="Optional approval remark"></textarea>
                            <div class="actions">
                                <button type="submit" class="btn btn-approve">Approve</button>
                            </div>
                        </form>

                        <form method="post" action="<%= request.getContextPath() %>/RejectLeaveServlet"
                              style="margin-top: 18px;"
                              onsubmit="return document.getElementById('rejectRemark').value.trim() !== '';">
                            <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">
                            <input type="hidden" name="leaveId" value="<%= leave.getLeaveId() %>">
                            <label for="rejectRemark">Rejection Reason</label>
                            <textarea name="hrRemark" id="rejectRemark"
                                      placeholder="Rejection reason is required" required></textarea>
                            <div class="actions">
                                <button type="submit" class="btn btn-reject">Confirm Rejection</button>
                            </div>
                        </form>
                    </div>
                <% } %>

                <div class="actions" style="margin-top: 24px;">
                    <a class="btn btn-secondary"
                       href="<%= request.getContextPath() %>/HrLeaveRequestsServlet">Back to List</a>
                </div>
            <% } %>
        </div>
    </div>
    </div>
</body>
</html>
