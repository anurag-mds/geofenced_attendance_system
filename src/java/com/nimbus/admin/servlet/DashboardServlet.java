package com.nimbus.admin.servlet;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/session-expired.jsp");
            return;
        }

        Employee employee = (Employee) session.getAttribute("employee");
        Role role = employee.getRole();

        // Redirect to appropriate dashboard based on role
        switch (role) {
            case ADMIN:
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
                break;
            case HR:
                response.sendRedirect(request.getContextPath() + "/HrDashboardServlet");
                break;
            case EMPLOYEE:
                response.sendRedirect(request.getContextPath() + "/EmployeeDashboardServlet");
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/");
        }
    }
}
