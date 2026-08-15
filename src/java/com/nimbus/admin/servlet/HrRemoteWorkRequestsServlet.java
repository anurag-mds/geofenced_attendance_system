package com.nimbus.admin.servlet;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.util.DBConnection;

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

@WebServlet("/HrRemoteWorkRequestsServlet")
public class HrRemoteWorkRequestsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("index.html");
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

        try (PrintWriter out = response.getWriter()) {

            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");

            out.println("<meta charset='UTF-8'>");
            out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");

            out.println("<title>Work From Home Requests</title>");

            out.println("<style>");

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

            out.println("<div class='container'>");

            out.println("<a class='back' href='hrDashboard.jsp'>");
            out.println("← Back to HR Dashboard");
            out.println("</a>");

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
                    "WHERE r.status = 'PENDING' " +
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
                    "ORDER BY r.requested_on DESC";
            }

            try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
            ) {

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
                    out.println(fullName);
                    out.println("</td>");

                    out.println("<td>");
                    out.println(startDate);
                    out.println("</td>");

                    out.println("<td>");
                    out.println(endDate);
                    out.println("</td>");

                    out.println("<td class='status'>");
                    out.println(requestStatus);
                    out.println("</td>");

                    out.println("<td>");

                    if ("PENDING".equals(requestStatus)) {

                        out.println("<form method='post' style='display:inline;'>");

                        out.println("<input type='hidden' name='remoteId' value='"
                                + remoteId + "'>");

                        out.println("<input type='hidden' name='action' value='APPROVE'>");

                        out.println("<button class='btn approve' type='submit'>");
                        out.println("Approve");
                        out.println("</button>");

                        out.println("</form>");


                        out.println("<form method='post' style='display:inline;'>");

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

            } catch (Exception e) {

                e.printStackTrace();

                out.println("<p style='color:#777;margin-top:20px;'>");
                out.println("Unable to load work from home requests.");
                out.println("</p>");
            }

            out.println("</div>");
            out.println("</div>");

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
            response.sendRedirect("index.html");
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

        int remoteId =
                Integer.parseInt(remoteIdParameter);

        String newStatus = null;

        if ("APPROVE".equalsIgnoreCase(action)) {

            newStatus = "APPROVED";

        } else if ("REJECT".equalsIgnoreCase(action)) {

            newStatus = "REJECTED";

        }

        if (newStatus != null) {

            String sql =
                    "UPDATE remote_work_approvals " +
                    "SET status = ?, approved_by = ? " +
                    "WHERE remote_id = ?";

            try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
            ) {

                ps.setString(1, newStatus);

                // HR employee ID
                ps.setInt(2, employee.getEmpId());

                ps.setInt(3, remoteId);

                ps.executeUpdate();

            } catch (Exception e) {

                e.printStackTrace();
            }
        }

        response.sendRedirect(
                request.getContextPath()
                + "/HrRemoteWorkRequestsServlet"
        );
    }
}