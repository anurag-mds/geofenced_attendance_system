package com.nimbus.admin.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session.getAttribute("employee"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        // Placeholder for report generation
        request.setAttribute("message", "Report functionality coming soon");
        request.getRequestDispatcher("/WEB-INF/jsp/reports/report-dashboard.jsp")
                .forward(request, response);
    }

    private boolean isAdmin(Object value) {
        return value instanceof com.nimbus.admin.model.Employee employee
                && employee.getRole() == com.nimbus.admin.model.Role.ADMIN;
    }
}
