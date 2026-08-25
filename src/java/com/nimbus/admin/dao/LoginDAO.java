package com.nimbus.admin.dao;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.model.EmploymentStatus;
import com.nimbus.admin.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Enhanced LoginDAO with detailed error differentiation
 * Provides specific feedback for different login failure scenarios
 */
public class LoginDAO {

    private static final Logger LOGGER = Logger.getLogger(LoginDAO.class.getName());

    /**
     * Container class to hold login result and employee data
     */
    public static class LoginResponse {
        private final LoginResult result;
        private final Employee employee;

        public LoginResponse(LoginResult result, Employee employee) {
            this.result = result;
            this.employee = employee;
        }

        public LoginResult getResult() {
            return result;
        }

        public Employee getEmployee() {
            return employee;
        }
    }

    /**
     * Authenticate user with detailed error reporting
     * @param empCode Employee code
     * @param password Password
     * @return LoginResponse containing result code and employee (if successful)
     */
    public LoginResponse authenticate(String empCode, String password) {
        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
                + "role, designation, dept_id, joining_date, employment_status "
                + "FROM employees "
                + "WHERE emp_code = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, empCode);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // User found - check employment status
                    String status = rs.getString("employment_status");
                    if (!"ACTIVE".equals(status)) {
                        return new LoginResponse(LoginResult.INACTIVE_USER, null);
                    }

                    // Check password
                    String storedPassword = rs.getString("password");
                    if (!password.equals(storedPassword)) {
                        return new LoginResponse(LoginResult.WRONG_PASSWORD, null);
                    }

                    // Success - build employee object
                    Employee employee = buildEmployeeFromResultSet(rs);
                    return new LoginResponse(LoginResult.SUCCESS, employee);

                } else {
                    // User not found
                    return new LoginResponse(LoginResult.USER_NOT_FOUND, null);
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error during login attempt for: " + empCode, e);
            return new LoginResponse(LoginResult.DB_ERROR, null);
        }
    }

    /**
     * Legacy method for backward compatibility
     * @deprecated Use authenticate() instead for better error handling
     */
    @Deprecated
    public Employee login(String empCode, String password) {
        LoginResponse response = authenticate(empCode, password);
        return response.getResult() == LoginResult.SUCCESS ? response.getEmployee() : null;
    }

    /**
     * Build Employee object from ResultSet
     */
    private Employee buildEmployeeFromResultSet(ResultSet rs) throws Exception {
        Employee employee = new Employee();
        employee.setEmpId(rs.getInt("emp_id"));
        employee.setEmpCode(rs.getString("emp_code"));
        employee.setFullName(rs.getString("full_name"));
        employee.setEmail(rs.getString("email"));
        employee.setPassword(rs.getString("password"));
        employee.setRole(Role.valueOf(rs.getString("role")));
        employee.setDesignation(rs.getString("designation"));
        employee.setDeptId(rs.getInt("dept_id"));
        employee.setJoiningDate(rs.getDate("joining_date").toLocalDate());
        employee.setEmploymentStatus(
                EmploymentStatus.valueOf(rs.getString("employment_status"))
        );
        return employee;
    }
}
