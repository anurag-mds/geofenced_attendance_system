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

@WebServlet("/ApplyRemoteWorkServlet")
public class ApplyRemoteWorkServlet extends HttpServlet {

    private RemoteWorkDAO remoteWorkDAO;

    @Override
    public void init() throws ServletException {
        remoteWorkDAO = new RemoteWorkDAO();
    }

    // =========================================================
    // SHOW WFH PAGE
    // =========================================================

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        Employee employee =
                (Employee) session.getAttribute("employee");

        if (employee == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        // Get this employee's previous WFH requests
        request.setAttribute(
                "remoteRequests",
                remoteWorkDAO.getEmployeeRequests(
                        employee.getEmpId()
                )
        );

        request.getRequestDispatcher(
                "/WEB-INF/jsp/remote-work/apply-remote-work.jsp"
        ).forward(request, response);
    }


    // =========================================================
    // SUBMIT WFH REQUEST
    // =========================================================

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        Employee employee =
                (Employee) session.getAttribute("employee");

        if (employee == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        String startDateString =
                request.getParameter("startDate");

        String endDateString =
                request.getParameter("endDate");

        // Check that both dates were entered
        if (startDateString == null
                || startDateString.isBlank()
                || endDateString == null
                || endDateString.isBlank()) {

            request.setAttribute(
                    "error",
                    "Please select both start and end dates."
            );

            request.setAttribute(
                    "remoteRequests",
                    remoteWorkDAO.getEmployeeRequests(
                            employee.getEmpId()
                    )
            );

            request.getRequestDispatcher(
                    "/WEB-INF/jsp/remote-work/apply-remote-work.jsp"
            ).forward(request, response);

            return;
        }

        try {

            Date startDate =
                    Date.valueOf(startDateString);

            Date endDate =
                    Date.valueOf(endDateString);

            // Make sure end date is not before start date
            if (endDate.before(startDate)) {

                request.setAttribute(
                        "error",
                        "End date cannot be before start date."
                );

                request.setAttribute(
                        "remoteRequests",
                        remoteWorkDAO.getEmployeeRequests(
                                employee.getEmpId()
                        )
                );

                request.getRequestDispatcher(
                        "/WEB-INF/jsp/remote-work/apply-remote-work.jsp"
                ).forward(request, response);

                return;
            }

            RemoteWork remoteWork =
                    new RemoteWork();

            // Logged-in employee
            remoteWork.setEmpId(
                    employee.getEmpId()
            );

            remoteWork.setStartDate(
                    startDate
            );

            remoteWork.setEndDate(
                    endDate
            );

            // Status will be PENDING in database
            // approved_by will be NULL
            boolean success =
                    remoteWorkDAO.applyRemoteWork(
                            remoteWork
                    );

            if (success) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/ApplyRemoteWorkServlet?success=1"
                );

            } else {

                request.setAttribute(
                        "error",
                        "Unable to submit your work from home request."
                );

                request.setAttribute(
                        "remoteRequests",
                        remoteWorkDAO.getEmployeeRequests(
                                employee.getEmpId()
                        )
                );

                request.getRequestDispatcher(
                        "/WEB-INF/jsp/remote-work/apply-remote-work.jsp"
                ).forward(request, response);
            }

        } catch (IllegalArgumentException e) {

            request.setAttribute(
                    "error",
                    "Please enter valid dates."
            );

            request.setAttribute(
                    "remoteRequests",
                    remoteWorkDAO.getEmployeeRequests(
                            employee.getEmpId()
                    )
            );

            request.getRequestDispatcher(
                    "/WEB-INF/jsp/remote-work/apply-remote-work.jsp"
            ).forward(request, response);

        }
    }
}