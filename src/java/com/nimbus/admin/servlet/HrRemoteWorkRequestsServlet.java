package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.RemoteWorkDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.RemoteWork;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet("/HrRemoteWorkRequestsServlet")
public class HrRemoteWorkRequestsServlet extends HttpServlet {

    private RemoteWorkDAO remoteWorkDAO;

    @Override
    public void init() throws ServletException {

        remoteWorkDAO = new RemoteWorkDAO();
    }


    // =========================================================
    // GET
    // SHOW WFH REQUESTS
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }


        Employee employee =
                (Employee) session.getAttribute("employee");


        // Only HR can access this page

        if (employee == null ||
                employee.getRole() != Role.HR) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied"
            );

            return;
        }


        // =====================================================
        // GET STATUS FILTER
        // =====================================================

        String status =
                request.getParameter("status");


        if (status == null ||
                status.trim().isEmpty()) {

            status = "ALL";
        }


        status = status.toUpperCase();


        // Allow only valid filters

        if (!status.equals("ALL")
                && !status.equals("PENDING")
                && !status.equals("APPROVED")
                && !status.equals("REJECTED")) {

            status = "ALL";
        }


        // =====================================================
        // GET REQUESTS
        // =====================================================

        List<RemoteWork> requests;


        if ("PENDING".equals(status)) {

            /*
             * Use the existing method from your DAO.
             */
            requests =
                    remoteWorkDAO.getPendingRequests();

        }

        else if ("APPROVED".equals(status)) {

            requests =
                    remoteWorkDAO.getRequestsByStatus(
                            "APPROVED"
                    );

        }

        else if ("REJECTED".equals(status)) {

            requests =
                    remoteWorkDAO.getRequestsByStatus(
                            "REJECTED"
                    );

        }

        else {

            /*
             * ALL requests.
             */
            requests =
                    remoteWorkDAO.getAllRequests();
        }


        request.setAttribute(
                "remoteRequests",
                requests
        );


        request.setAttribute(
                "status",
                status
        );


        // =====================================================
        // OPEN JSP
        // =====================================================

        request.getRequestDispatcher(
                "/WEB-INF/jsp/remote-work/hr-remote-work-requests.jsp"
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // POST
    // APPROVE / REJECT WFH REQUEST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        HttpSession session =
                request.getSession(false);


        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }


        Employee hr =
                (Employee) session.getAttribute("employee");


        // Only HR can approve/reject

        if (hr == null ||
                hr.getRole() != Role.HR) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied"
            );

            return;
        }


        // =====================================================
        // GET PARAMETERS
        // =====================================================

        String remoteIdParam =
                request.getParameter("remoteId");


        String action =
                request.getParameter("action");


        if (remoteIdParam == null ||
                action == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/HrRemoteWorkRequestsServlet"
            );

            return;
        }


        int remoteId;


        try {

            remoteId =
                    Integer.parseInt(remoteIdParam);

        }

        catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/HrRemoteWorkRequestsServlet"
            );

            return;
        }


        // =====================================================
        // FIND THE REQUEST
        // =====================================================

        RemoteWork remoteWork =
                remoteWorkDAO.getRequestById(
                        remoteId
                );


        if (remoteWork == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/HrRemoteWorkRequestsServlet"
            );

            return;
        }


        int employeeId =
                remoteWork.getEmpId();


        boolean updated = false;


        // =====================================================
        // APPROVE
        // =====================================================

        if ("APPROVE".equalsIgnoreCase(action)) {


            updated =
                    remoteWorkDAO.approveRequest(
                            remoteId,
                            hr.getEmpId()
                    );


            if (updated) {

                createNotification(
                        employeeId,
                        "Your work from home request has been approved."
                );
            }
        }


        // =====================================================
        // REJECT
        // =====================================================

        else if ("REJECT".equalsIgnoreCase(action)) {


            updated =
                    remoteWorkDAO.rejectRequest(
                            remoteId,
                            hr.getEmpId()
                    );


            if (updated) {

                createNotification(
                        employeeId,
                        "Your work from home request has been rejected."
                );
            }
        }


        // =====================================================
        // RETURN TO WFH PAGE
        // =====================================================

        response.sendRedirect(
                request.getContextPath()
                + "/HrRemoteWorkRequestsServlet"
        );
    }


    // =========================================================
    // CREATE EMPLOYEE NOTIFICATION
    // =========================================================

    private void createNotification(
            int employeeId,
            String message) {


        /*
         * Your current notifications table supports:
         *
         * LEAVE
         * PERMISSION
         * ATTENDANCE
         * ACCOUNT
         *
         * It does not currently have WFH as an enum value.
         *
         * Therefore we use LEAVE as the existing notification
         * category while the actual message clearly says
         * Work From Home.
         *
         * This avoids changing your database structure.
         */

        String sql =
                "INSERT INTO notifications "
              + "(emp_id, message, type) "
              + "VALUES (?, ?, 'LEAVE')";


        try (
                Connection con =
                        DBConnection.getConnection();

                PreparedStatement ps =
                        con.prepareStatement(sql)
        ) {


            ps.setInt(
                    1,
                    employeeId
            );


            ps.setString(
                    2,
                    message
            );


            ps.executeUpdate();


        }

        catch (Exception e) {

            System.out.println(
                    "ERROR CREATING WFH NOTIFICATION:"
            );

            e.printStackTrace();
        }
    }
}