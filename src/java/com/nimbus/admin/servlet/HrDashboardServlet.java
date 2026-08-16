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
            response.sendRedirect("index.html");
            return;
        }

        Employee employee =
                (Employee) session.getAttribute("employee");

        if (employee == null) {
            response.sendRedirect("index.html");
            return;
        }

        // Make sure only HR can access this dashboard
        if (employee.getRole() == null ||
                !"HR".equalsIgnoreCase(
                        employee.getRole().name())) {

            response.sendRedirect("index.html");
            return;
        }

        int totalEmployees =
                dashboardDAO.getTotalEmployees();

        int activeEmployees =
                dashboardDAO.getActiveEmployees();

        int inactiveEmployees =
                dashboardDAO.getInactiveEmployees();

        int pendingLeaveRequests =
                dashboardDAO.getPendingLeaveRequests();

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

        request.getRequestDispatcher(
        "/hrDashboard.jsp")
        .forward(request, response);
    }
}