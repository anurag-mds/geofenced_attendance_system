package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.LoginDAO;
import com.nimbus.admin.dao.LoginDAO.LoginResponse;
import com.nimbus.admin.dao.LoginResult;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import java.util.logging.Logger;

/**
 * Enhanced LoginServlet with detailed error reporting
 * Provides specific feedback for different login failure scenarios
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String empCode = request.getParameter("empCode");
        String password = request.getParameter("password");

        // Validate input
        if (empCode == null || empCode.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            redirectWithError(request, response, "empty_fields");
            return;
        }

        LoginDAO loginDAO = new LoginDAO();
        LoginResponse loginResponse = loginDAO.authenticate(empCode.trim(), password);

        if (loginResponse.getResult() == LoginResult.SUCCESS) {
            Employee employee = loginResponse.getEmployee();

            // Replace any pre-authentication session with a fresh authenticated session.
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = request.getSession(true);
            session.setAttribute("employee", employee);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes of inactivity
            Cookie authMarker = new Cookie("ATTENDANCE_AUTHENTICATED", "1");
            authMarker.setHttpOnly(true);
            authMarker.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
            response.addCookie(authMarker);

            // Log successful login
            LOGGER.info("Successful login: " + empCode + " (" + employee.getRole() + ")");

            // Route by role
            routeByRole(request, response, employee.getRole());

        } else {
            // Handle login failures with specific error codes
            String errorCode = getErrorCode(loginResponse.getResult());
            LOGGER.warning("Failed login attempt: " + empCode + " - " + errorCode);
            redirectWithError(request, response, errorCode);
        }
    }

    /**
     * Route user to appropriate dashboard based on role
     */
    private void routeByRole(HttpServletRequest request,
                             HttpServletResponse response,
                             Role role) throws IOException {
        String contextPath = request.getContextPath();

        switch (role) {
            case ADMIN:
                response.sendRedirect(contextPath + "/adminDashboard.jsp");
                break;
            case HR:
                response.sendRedirect(contextPath + "/HrDashboardServlet");
                break;
            case EMPLOYEE:
                response.sendRedirect(contextPath + "/EmployeeDashboardServlet");
                break;
            default:
                redirectWithError(request, response, "invalid_role");
        }
    }

    /**
     * Map LoginResult to error code
     */
    private String getErrorCode(LoginResult result) {
        switch (result) {
            case WRONG_PASSWORD:
                return "wrong_password";
            case USER_NOT_FOUND:
                return "user_not_found";
            case INACTIVE_USER:
                return "inactive_user";
            case DB_ERROR:
                return "db_error";
            default:
                return "unknown_error";
        }
    }

    /**
     * Redirect to login page with error parameter
     */
    private void redirectWithError(HttpServletRequest request,
                                    HttpServletResponse response,
                                    String errorCode) throws IOException {
        response.sendRedirect(request.getContextPath() + "/index.html?error=" + errorCode);
    }
}
