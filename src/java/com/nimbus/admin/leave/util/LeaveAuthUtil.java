//This utility enforces authentication and role checks for leave endpoints.
//Security must not rely on hidden JSP buttons alone, so every leave servlet
//uses these helpers to reject unauthorized employee, HR, or admin access.

package com.nimbus.admin.leave.util;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public final class LeaveAuthUtil {

    private LeaveAuthUtil() {
    }

    public static Employee requireAuthenticatedEmployee(
            HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return null;
        }
        return (Employee) session.getAttribute("employee");
    }

    public static Employee requireRole(HttpServletRequest request,
            HttpServletResponse response, Role requiredRole)
            throws IOException {

        Employee employee = requireAuthenticatedEmployee(request, response);
        if (employee == null) {
            return null;
        }
        if (employee.getRole() != requiredRole) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You are not authorized to access this resource.");
            return null;
        }
        return employee;
    }

    public static Employee requireEmployeeRole(HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        return requireRole(request, response, Role.EMPLOYEE);
    }

    public static Employee requireHrRole(HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        return requireRole(request, response, Role.HR);
    }

    public static Employee requireAdminRole(HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        return requireRole(request, response, Role.ADMIN);
    }
}
