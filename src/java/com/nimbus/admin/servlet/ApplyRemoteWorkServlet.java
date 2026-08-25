package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.RemoteWorkDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.RemoteWork;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

@WebServlet("/ApplyRemoteWorkServlet")
public class ApplyRemoteWorkServlet extends HttpServlet {

    private RemoteWorkDAO remoteWorkDAO;


    @Override
    public void init() throws ServletException {

        remoteWorkDAO =
                new RemoteWorkDAO();
    }


    // =========================================================
    // SHOW APPLY WFH PAGE
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


        if (employee == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }


        /*
         * IMPORTANT:
         *
         * We are NOT loading old WFH requests here anymore.
         *
         * History has its own separate page.
         */


        request.setAttribute(
                "today",
                LocalDate.now().toString()
        );


        request.getRequestDispatcher(
                "/WEB-INF/jsp/remote-work/apply-remote-work.jsp"
        ).forward(request, response);
    }


    // =========================================================
    // SUBMIT WFH REQUEST
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


        Employee employee =
                (Employee) session.getAttribute("employee");


        if (employee == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }


        String startDateString =
                request.getParameter("startDate");


        String endDateString =
                request.getParameter("endDate");


        // =====================================================
        // CHECK EMPTY DATES
        // =====================================================

        if (startDateString == null
                || startDateString.isBlank()
                || endDateString == null
                || endDateString.isBlank()) {

            showError(
                    request,
                    response,
                    "Please select both start and end dates."
            );

            return;
        }


        try {

            Date startDate =
                    Date.valueOf(startDateString);


            Date endDate =
                    Date.valueOf(endDateString);


            Date today =
                    Date.valueOf(
                            LocalDate.now().toString()
                    );


            // =================================================
            // DO NOT ALLOW PAST DATES
            // =================================================

            if (startDate.before(today)) {

                showError(
                        request,
                        response,
                        "Start date cannot be in the past."
                );

                return;
            }


            if (endDate.before(today)) {

                showError(
                        request,
                        response,
                        "End date cannot be in the past."
                );

                return;
            }


            // =================================================
            // END DATE CANNOT BE BEFORE START DATE
            // =================================================

            if (endDate.before(startDate)) {

                showError(
                        request,
                        response,
                        "End date cannot be before start date."
                );

                return;
            }


            // =================================================
            // CREATE REQUEST
            // =================================================

            RemoteWork remoteWork =
                    new RemoteWork();


            remoteWork.setEmpId(
                    employee.getEmpId()
            );


            remoteWork.setStartDate(
                    startDate
            );


            remoteWork.setEndDate(
                    endDate
            );


            /*
             * DAO inserts status as PENDING.
             */

            boolean success =
                    remoteWorkDAO.applyRemoteWork(
                            remoteWork
                    );


            if (success) {

                /*
                 * After successful application,
                 * directly show WFH history.
                 *
                 * This lets the employee immediately
                 * see the new PENDING request.
                 */

                response.sendRedirect(
                        request.getContextPath()
                        + "/RemoteWorkHistoryServlet?success=1"
                );

            } else {

                showError(
                        request,
                        response,
                        "Unable to submit your work from home request."
                );
            }


        } catch (IllegalArgumentException e) {

            showError(
                    request,
                    response,
                    "Please enter valid dates."
            );
        }
    }


    // =========================================================
    // SHOW ERROR
    // =========================================================

    private void showError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws ServletException, IOException {

        request.setAttribute(
                "error",
                message
        );


        request.setAttribute(
                "today",
                LocalDate.now().toString()
        );


        request.getRequestDispatcher(
                "/WEB-INF/jsp/remote-work/apply-remote-work.jsp"
        ).forward(request, response);
    }
}