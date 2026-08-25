package com.nimbus.admin.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/AttendanceSettingsServlet")
public class AttendanceSettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session.getAttribute("employee"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        // Placeholder for attendance settings
        request.setAttribute("message", "Attendance settings functionality coming soon");
        request.getRequestDispatcher("/WEB-INF/jsp/admin/attendance-settings.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session.getAttribute("employee"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        // Handle settings update
        response.sendRedirect(request.getContextPath() + "/AttendanceSettingsServlet?success=true");
    }

    private boolean isAdmin(Object value) {
        return value instanceof com.nimbus.admin.model.Employee employee
                && employee.getRole() == com.nimbus.admin.model.Role.ADMIN;
    }
}
