package com.nimbus.admin.servlet;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.util.DBConnection;
import com.nimbus.admin.util.CsrfToken;
import com.nimbus.admin.util.HtmlEscaper;
import com.nimbus.admin.dao.NotificationDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/HrRemoteWorkRequestsServlet")
public class HrRemoteWorkRequestsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HrRemoteWorkRequestsServlet.class.getName());
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        Employee employee =
                (Employee) session.getAttribute("employee");

        // Only HR can access this page
        if (employee == null || employee.getRole() != Role.HR) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied");
            return;
        }

        String status = request.getParameter("status");

        response.setContentType("text/html;charset=UTF-8");
        String csrfToken = CsrfToken.getToken(request);

        try (PrintWriter out = response.getWriter()) {

            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");

            out.println("<meta charset='UTF-8'>");
            out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");

            out.println("<title>Work From Home Requests</title>");
            out.println("<style>");
            out.println(".app-navbar { background: #222; color: #fff; padding: 18px 30px; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 1100; }");
            out.println(".app-navbar-left { display: flex; align-items: center; gap: 15px; }");
            out.println(".app-brand-block { display: flex; flex-direction: column; gap: 2px; }");
            out.println(".app-navbar h2 { font-size: 22px; font-weight: 600; margin: 0; line-height: 1.2; }");
            out.println(".app-dashboard-label { font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em; color: #dfe7f1; }");
            out.println(".app-menu-button { background: none; border: none; color: #fff; font-size: 28px; line-height: 1; cursor: pointer; padding: 4px 8px; border-radius: 6px; }");
            out.println(".app-navbar-right { display: flex; align-items: center; gap: 16px; font-size: 14px; }");
            out.println(".user-name { color: #fff; }");
            out.println(".app-logout-button { background-color: #e74c3c; color: #fff; padding: 9px 16px; border: none; border-radius: 5px; text-decoration: none; font-size: 14px; }");
            out.println(".app-sidebar { position: fixed; top: 70px; left: 0; width: 230px; height: calc(100vh - 70px); background-color: #fff; border-right: 1px solid #ddd; padding: 25px 15px; transform: translateX(-100%); transition: transform 0.3s ease; z-index: 1000; overflow-y: auto; }");
            out.println(".app-sidebar.open { transform: translateX(0); }");
            out.println(".app-sidebar-title { font-size: 13px; color: #888; text-transform: uppercase; margin-bottom: 15px; padding-left: 12px; }");
            out.println(".app-sidebar a { display: flex; align-items: center; gap: 12px; padding: 14px 12px; margin-bottom: 6px; border-radius: 7px; text-decoration: none; color: #333; font-size: 15px; transition: 0.2s; }");
            out.println(".page-content { transition: margin-left 0.3s ease; }");
            out.println(".page-content.sidebar-open { margin-left: 230px; }");

            out.println("* { box-sizing: border-box; }");

            out.println("body {");
            out.println("font-family: Arial, sans-serif;");
            out.println("background: #f2f4f7;");
            out.println("margin: 0;");
            out.println("color: #222;");
            out.println("}");

            out.println(".container {");
            out.println("max-width: 1100px;");
            out.println("margin: 40px auto;");
            out.println("padding: 0 20px;");
            out.println("}");

            out.println(".card {");
            out.println("background: white;");
            out.println("border-radius: 12px;");
            out.println("padding: 30px;");
            out.println("box-shadow: 0 3px 10px rgba(0,0,0,0.08);");
            out.println("}");

            out.println("h1 {");
            out.println("margin-bottom: 8px;");
            out.println("}");

            out.println(".subtitle {");
            out.println("color: #666;");
            out.println("margin-bottom: 25px;");
            out.println("}");

            out.println("table {");
            out.println("width: 100%;");
            out.println("border-collapse: collapse;");
            out.println("}");

            out.println("th, td {");
            out.println("padding: 14px;");
            out.println("border-bottom: 1px solid #ddd;");
            out.println("text-align: left;");
            out.println("}");

            out.println("th {");
            out.println("background: #f5f6f7;");
            out.println("}");

            out.println(".status {");
            out.println("font-weight: bold;");
            out.println("}");

            out.println(".pending { color: #555; }");
            out.println(".approved { color: #222; }");
            out.println(".rejected { color: #777; }");

            out.println(".btn {");
            out.println("border: none;");
            out.println("padding: 8px 12px;");
            out.println("border-radius: 6px;");
            out.println("cursor: pointer;");
            out.println("margin-right: 5px;");
            out.println("}");

            out.println(".approve {");
            out.println("background: #222;");
            out.println("color: white;");
            out.println("}");

            out.println(".reject {");
            out.println("background: #e9ecef;");
            out.println("color: #333;");
            out.println("}");

            out.println(".back {");
            out.println("display: inline-block;");
            out.println("margin-bottom: 20px;");
            out.println("text-decoration: none;");
            out.println("color: #333;");
            out.println("}");

            out.println("</style>");

            out.println("</head>");
            out.println("<body>");
            out.println("<nav class='app-navbar'>");
            out.println("<div class='app-navbar-left'>");
            out.println("<button type='button' class='app-menu-button' onclick=\"const sidebar=document.getElementById('appSidebar'); sidebar.classList.toggle('open'); document.querySelectorAll('.page-content').forEach(function(section){ section.classList.toggle('sidebar-open'); });\" aria-label='Open navigation menu'>&#9776;</button>");
            out.println("<div class='app-brand-block'><h2>Employee Attendance System</h2><span class='app-dashboard-label'>HR Dashboard</span></div>");
            out.println("</div>");
            String safeEmployeeName = HtmlEscaper.text(employee.getFullName());
            out.println("<div class='app-navbar-right'><span class='user-name'>" + safeEmployeeName + "</span><a href='" + request.getContextPath() + "/LogoutServlet' class='app-logout-button'>Logout</a></div>");
            out.println("</nav>");
            out.println("<aside class='app-sidebar' id='appSidebar'>");
            out.println("<div class='app-sidebar-title'>HR Menu</div>");
            String contextPath = request.getContextPath();
            out.println("<a href='" + contextPath + "/HrDashboardServlet'>&#127968; HR Dashboard</a>");
            out.println("<a href='" + contextPath + "/HrLeaveRequestsServlet'>&#128203; Leave Requests</a>");
            out.println("<a href='" + contextPath + "/HrRemoteWorkRequestsServlet'>&#127968; WFH Requests</a>");
            out.println("<a href='" + contextPath + "/SearchEmployeeServlet'>&#128100; My Employees</a>");
            out.println("<a href='" + contextPath + "/ContactServlet?role=ADMIN'>&#128222; Contact Admin</a>");
            out.println("<a href='" + contextPath + "/ProfileServlet'>&#128100; Profile</a>");
            out.println("<a href='" + contextPath + "/NotificationServlet'>&#128276; Notifications</a>");
            out.println("</aside>");

            out.println("<div class='page-content'><div class='container'>");

            out.println("<div class='card'>");

            out.println("<h1>Work From Home Requests</h1>");

            if ("PENDING".equalsIgnoreCase(status)) {

                out.println("<p class='subtitle'>");
                out.println("Pending work from home requests");
                out.println("</p>");

            } else {

                out.println("<p class='subtitle'>");
                out.println("Review employee work from home requests.");
                out.println("</p>");
            }

            String sql;

            if ("PENDING".equalsIgnoreCase(status)) {

                sql =
                    "SELECT r.remote_id, " +
                    "r.emp_id, " +
                    "e.full_name, " +
                    "r.start_date, " +
                    "r.end_date, " +
                    "r.status " +
                    "FROM remote_work_approvals r " +
                    "JOIN employees e ON r.emp_id = e.emp_id " +
                    "WHERE r.status = 'PENDING' AND e.dept_id = ? " +
                    "ORDER BY r.requested_on DESC";

            } else {

                sql =
                    "SELECT r.remote_id, " +
                    "r.emp_id, " +
                    "e.full_name, " +
                    "r.start_date, " +
                    "r.end_date, " +
                    "r.status " +
                    "FROM remote_work_approvals r " +
                    "JOIN employees e ON r.emp_id = e.emp_id " +
                    "WHERE e.dept_id = ? ORDER BY r.requested_on DESC";
            }

            try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, employee.getDeptId());
                try (ResultSet rs = ps.executeQuery()) {

                boolean hasRequests = false;

                out.println("<table>");

                out.println("<tr>");
                out.println("<th>Employee</th>");
                out.println("<th>Start Date</th>");
                out.println("<th>End Date</th>");
                out.println("<th>Status</th>");
                out.println("<th>Action</th>");
                out.println("</tr>");

                while (rs.next()) {

                    hasRequests = true;

                    int remoteId =
                            rs.getInt("remote_id");

                    String fullName =
                            rs.getString("full_name");

                    String startDate =
                            rs.getString("start_date");

                    String endDate =
                            rs.getString("end_date");

                        String requestStatus =
                            rs.getString("status");

                    out.println("<tr>");

                    out.println("<td>");
                    out.println(HtmlEscaper.text(fullName));
                    out.println("</td>");

                    out.println("<td>");
                    out.println(HtmlEscaper.text(startDate));
                    out.println("</td>");

                    out.println("<td>");
                    out.println(HtmlEscaper.text(endDate));
                    out.println("</td>");

                    out.println("<td class='status'>");
                    out.println(HtmlEscaper.text(requestStatus));
                    out.println("</td>");

                    out.println("<td>");

                    if ("PENDING".equalsIgnoreCase(requestStatus)) {

                        out.println("<form method='post' style='display:inline;'>");

                        out.println("<input type='hidden' name='csrfToken' value='" + csrfToken + "'>");

                        out.println("<input type='hidden' name='remoteId' value='"
                                + remoteId + "'>");

                        out.println("<input type='hidden' name='action' value='APPROVE'>");

                        out.println("<button class='btn approve' type='submit'>");
                        out.println("Approve");
                        out.println("</button>");

                        out.println("</form>");


                        out.println("<form method='post' style='display:inline;'>");

                        out.println("<input type='hidden' name='csrfToken' value='" + csrfToken + "'>");

                        out.println("<input type='hidden' name='remoteId' value='"
                                + remoteId + "'>");

                        out.println("<input type='hidden' name='action' value='REJECT'>");

                        out.println("<button class='btn reject' type='submit'>");
                        out.println("Reject");
                        out.println("</button>");

                        out.println("</form>");

                    } else {

                        out.println("—");
                    }

                    out.println("</td>");

                    out.println("</tr>");
                }

                out.println("</table>");

                if (!hasRequests) {

                    out.println("<p style='margin-top:25px;color:#777;'>");
                    out.println("No work from home requests found.");
                    out.println("</p>");
                }
                }

            } catch (Exception e) {

                LOGGER.log(Level.SEVERE, "Unable to load remote work requests", e);

                out.println("<p style='color:#777;margin-top:20px;'>");
                out.println("Unable to load work from home requests.");
                out.println("</p>");
            }

            out.println("</div>");
            out.println("</div></div>");

            out.println("</body>");
            out.println("</html>");
        }
    }


    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        Employee employee =
                (Employee) session.getAttribute("employee");

        // Only HR can approve/reject
        if (employee == null || employee.getRole() != Role.HR) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied");
            return;
        }

        String remoteIdParameter =
                request.getParameter("remoteId");

        String action =
                request.getParameter("action");

        if (remoteIdParameter == null || action == null) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/HrRemoteWorkRequestsServlet"
            );
            return;
        }

        int remoteId;
        try {
            remoteId = Integer.parseInt(remoteIdParameter);
        } catch (NumberFormatException exception) {
            response.sendRedirect(request.getContextPath()
                    + "/HrRemoteWorkRequestsServlet?error=invalid");
            return;
        }

        String newStatus = null;

        if ("APPROVE".equalsIgnoreCase(action)) {

            newStatus = "APPROVED";

        } else if ("REJECT".equalsIgnoreCase(action)) {

            newStatus = "REJECTED";

        }

        if (newStatus != null) {

                String sql =
                    "UPDATE remote_work_approvals r " +
                    "SET r.status = ?, r.approved_by = ? " +
                    "WHERE r.remote_id = ? AND r.status = 'PENDING' "
                    + "AND EXISTS (SELECT 1 FROM employees e WHERE e.emp_id = r.emp_id AND e.dept_id = ?)";

            try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
            ) {

                ps.setString(1, newStatus);

                // HR employee ID
                ps.setInt(2, employee.getEmpId());

                ps.setInt(3, remoteId);
                ps.setInt(4, employee.getDeptId());

                if (ps.executeUpdate() > 0) {
                    int recipientId = getRequestEmployeeId(con, remoteId);
                    if (recipientId > 0) {
                        notificationDAO.addNotification(recipientId,
                                "Your work from home request was " + newStatus.toLowerCase() + ".",
                                "WFH", "/ApplyRemoteWorkServlet");
                    }
                }

            } catch (Exception e) {

                LOGGER.log(Level.SEVERE, "Unable to update remote work request", e);
            }
        }

        response.sendRedirect(
                request.getContextPath()
                + "/HrRemoteWorkRequestsServlet"
        );
    }

    private int getRequestEmployeeId(Connection connection, int remoteId) throws Exception {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT emp_id FROM remote_work_approvals WHERE remote_id = ?")) {
            statement.setInt(1, remoteId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? result.getInt("emp_id") : 0;
            }
        }
    }
}