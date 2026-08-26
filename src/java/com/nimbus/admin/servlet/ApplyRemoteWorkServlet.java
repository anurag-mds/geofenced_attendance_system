package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.RemoteWorkDAO;
import com.nimbus.admin.dao.NotificationDAO;
import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.model.Role;
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
import java.time.temporal.ChronoUnit;

@WebServlet("/ApplyRemoteWorkServlet")
public class ApplyRemoteWorkServlet extends HttpServlet {

    private RemoteWorkDAO remoteWorkDAO;
        private final EmployeeDAO employeeDAO = new EmployeeDAO();
        private final NotificationDAO notificationDAO = new NotificationDAO();

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

            LocalDate today = LocalDate.now();
            if (startDate.toLocalDate().isBefore(today)) {
                forwardWithError(request, response, employee,
                        "Work from home cannot start in the past.");
                return;
            }

            // Make sure end date is not before start date
            if (endDate.before(startDate)) {
                forwardWithError(request, response, employee,
                        "End date cannot be before start date.");
                return;
            }

            long requestedDays = ChronoUnit.DAYS.between(
                    startDate.toLocalDate(), endDate.toLocalDate()) + 1;
            if (requestedDays > 15) {
                forwardWithError(request, response, employee,
                        "A work from home request cannot exceed 15 calendar days.");
                return;
            }

            if (remoteWorkDAO.hasOverlappingRequest(employee.getEmpId(), startDate, endDate)) {
                forwardWithError(request, response, employee,
                        "These dates overlap an existing pending or approved request.");
                return;
            }

                        if (remoteWorkDAO.hasOverlappingLeave(employee.getEmpId(), startDate, endDate)) {
                                forwardWithError(request, response, employee,
                                                "These dates overlap an existing leave request.");
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
                                for (Employee hr : employeeDAO.getEmployeesByRole(Role.HR)) {
                                        if (hr.getDeptId() == employee.getDeptId()) {
                                                try {
                                                        notificationDAO.addNotification(hr.getEmpId(),
                                                                        employee.getFullName() + " submitted a work from home request.",
                                                                        "WFH", "/HrRemoteWorkRequestsServlet?status=PENDING");
                                                } catch (java.sql.SQLException notificationException) {
                                                        notificationException.printStackTrace();
                                                }
                                        }
                                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/RemoteWorkHistoryServlet?success=1"
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

        private void forwardWithError(HttpServletRequest request,
                        HttpServletResponse response, Employee employee, String message)
                        throws ServletException, IOException {
                request.setAttribute("error", message);
                request.setAttribute("remoteRequests",
                                remoteWorkDAO.getEmployeeRequests(employee.getEmpId()));
                request.getRequestDispatcher(
                                "/WEB-INF/jsp/remote-work/apply-remote-work.jsp")
                                .forward(request, response);
        }
}