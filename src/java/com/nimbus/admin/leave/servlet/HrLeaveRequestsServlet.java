// This servlet is the HR entry point for listing and reviewing leave requests.
// HR users can filter requests and open details.
// Approval/rejection is still handled by the dedicated action servlets.

package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveStatus;
import com.nimbus.admin.leave.service.LeaveService;
import com.nimbus.admin.leave.service.LeaveServiceImpl;
import com.nimbus.admin.leave.util.LeaveAuthUtil;
import com.nimbus.admin.model.Employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;


@WebServlet("/HrLeaveRequestsServlet")
public class HrLeaveRequestsServlet extends HttpServlet {


    private final LeaveService leaveService =
            new LeaveServiceImpl();


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        /* ========================================================
           HR AUTHENTICATION
           ======================================================== */

        Employee hr =
                LeaveAuthUtil.requireHrRole(
                        request,
                        response
                );


        if (hr == null) {

            return;

        }



        /* ========================================================
           FILTERS
           ======================================================== */

        LeaveStatus statusFilter =
                parseStatus(
                        request.getParameter("status")
                );


        Integer leaveTypeIdFilter =
                parseLeaveTypeId(
                        request.getParameter("leaveTypeId")
                );


        String employeeSearch =
                request.getParameter("search");


        LocalDate fromDate =
                parseDate(
                        request.getParameter("fromDate")
                );


        LocalDate toDate =
                parseDate(
                        request.getParameter("toDate")
                );



        /* ========================================================
           OPEN INDIVIDUAL REQUEST
           ======================================================== */

        String viewId =
                request.getParameter("id");


        if (viewId != null &&
                !viewId.trim().isEmpty()) {


            try {


                int leaveId =
                        Integer.parseInt(viewId);


                Leave leave =
                        leaveService.getLeaveById(
                                leaveId
                        );


                if (leave == null) {

                    request.setAttribute(
                            "error",
                            "Leave request not found."
                    );

                } else {

                    request.setAttribute(
                            "selectedLeave",
                            leave
                    );

                }


            } catch (NumberFormatException e) {


                request.setAttribute(
                        "error",
                        "Invalid leave request ID."
                );

            }


            request.setAttribute(
                    "success",
                    request.getParameter("success")
            );


            request.setAttribute(
                    "errorMsg",
                    request.getParameter("error")
            );


            request.getRequestDispatcher(
                    "/WEB-INF/jsp/leave/leave-request-details.jsp"
            ).forward(
                    request,
                    response
            );


            return;
        }



        /* ========================================================
           GET REQUESTS
           ======================================================== */

        List<Leave> requests =
                leaveService.getLeaveRequests(
                        statusFilter,
                        employeeSearch,
                        leaveTypeIdFilter,
                        fromDate,
                        toDate
                );



        /* ========================================================
           SEND DATA TO JSP
           ======================================================== */

        request.setAttribute(
                "leaveRequests",
                requests
        );


        request.setAttribute(
                "statusFilter",
                statusFilter
        );


        request.setAttribute(
                "leaveTypeIdFilter",
                leaveTypeIdFilter
        );


        request.setAttribute(
                "employeeSearch",
                employeeSearch
        );


        request.setAttribute(
                "fromDate",
                request.getParameter("fromDate")
        );


        request.setAttribute(
                "toDate",
                request.getParameter("toDate")
        );


        request.setAttribute(
                "leaveStatuses",
                LeaveStatus.values()
        );


        request.setAttribute(
                "leaveTypes",
                leaveService.getLeaveTypes()
        );


        request.setAttribute(
                "success",
                request.getParameter("success")
        );


        request.setAttribute(
                "errorMsg",
                request.getParameter("error")
        );



        /* ========================================================
           OPEN JSP
           ======================================================== */

        request.getRequestDispatcher(
                "/WEB-INF/jsp/leave/leave-requests.jsp"
        ).forward(
                request,
                response
        );

    }



    /* ============================================================
       STATUS
       ============================================================ */

    private LeaveStatus parseStatus(
            String value) {


        if (value == null ||
                value.isBlank()) {

            return null;

        }


        /*
         * The URL can also receive:
         *
         * status=PENDING
         *
         * But PENDING is a DATABASE status.
         *
         * The application represents it as:
         *
         * SUBMITTED     -> PENDING + reviewed_by IS NULL
         *
         * UNDER_REVIEW  -> PENDING + reviewed_by IS NOT NULL
         *
         * Therefore PENDING defaults to SUBMITTED.
         */

        if ("PENDING".equalsIgnoreCase(value)) {

            return LeaveStatus.SUBMITTED;

        }


        try {

            return LeaveStatus.valueOf(
                    value.toUpperCase()
            );

        } catch (IllegalArgumentException e) {

            return null;

        }

    }



    /* ============================================================
       LEAVE TYPE
       ============================================================ */

    private Integer parseLeaveTypeId(
            String value) {


        if (value == null ||
                value.isBlank()) {

            return null;

        }


        try {

            return Integer.valueOf(value);

        } catch (NumberFormatException e) {

            return null;

        }

    }



    /* ============================================================
       DATE
       ============================================================ */

    private LocalDate parseDate(
            String value) {


        if (value == null ||
                value.isBlank()) {

            return null;

        }


        try {

            return LocalDate.parse(value);

        } catch (DateTimeParseException e) {

            return null;

        }

    }

}