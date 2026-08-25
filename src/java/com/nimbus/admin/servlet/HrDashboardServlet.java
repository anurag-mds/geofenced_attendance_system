package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.HrDashboardDAO;
import com.nimbus.admin.model.Employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/HrDashboardServlet")
public class HrDashboardServlet extends HttpServlet {

    private final HrDashboardDAO dashboardDAO = new HrDashboardDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
                        response.sendRedirect(request.getContextPath() + "/session-expired.jsp");
            return;
        }

        Employee employee =
                (Employee) session.getAttribute("employee");

        if (employee == null) {
                        response.sendRedirect(request.getContextPath() + "/session-expired.jsp");
            return;
        }

        // Make sure only HR can access this dashboard
        if (employee.getRole() == null ||
                !"HR".equalsIgnoreCase(
                        employee.getRole().name())) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int departmentId = employee.getDeptId();

        int totalEmployees =
                dashboardDAO.getTotalEmployees(departmentId);

        int activeEmployees =
                dashboardDAO.getActiveEmployees(departmentId);

        int inactiveEmployees =
                dashboardDAO.getInactiveEmployees(departmentId);

        int pendingLeaveRequests =
                dashboardDAO.getPendingLeaveRequests(departmentId);

        int pendingRemoteRequests =
                dashboardDAO.getPendingRemoteRequests(departmentId);

        request.setAttribute(
                "totalEmployees",
                totalEmployees);

        request.setAttribute(
                "activeEmployees",
                activeEmployees);

        request.setAttribute(
                "inactiveEmployees",
                inactiveEmployees);

        request.setAttribute(
                "pendingLeaveRequests",
                pendingLeaveRequests);

        request.setAttribute(
                "pendingRemoteRequests",
                pendingRemoteRequests);

        request.getRequestDispatcher(
        "/hrDashboard.jsp")
        .forward(request, response);
    }
}