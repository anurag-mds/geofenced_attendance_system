package com.nimbus.admin.dao;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.model.EmploymentStatus;
import com.nimbus.admin.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Employee CRUD operations
 * Handles all database interactions for employee management
 */
public class EmployeeDAO {

    private static final Logger LOGGER = Logger.getLogger(EmployeeDAO.class.getName());
    private static final String PASSWORD_PATTERN = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,50}$";

    /**
     * Add a new employee to the database
     * @param employee Employee object with all required fields
     * @return true if employee was added successfully
     */
    public boolean addEmployee(Employee employee) {
        if (employee == null || employee.getEmpCode() == null
                || employee.getEmpCode().isBlank() || employee.getFullName() == null
                || employee.getFullName().isBlank() || employee.getEmail() == null
                || employee.getEmail().isBlank() || employee.getPassword() == null
                || employee.getPassword().isBlank() || employee.getDesignation() == null
                || employee.getDesignation().isBlank()
                || (employee.getRole() != Role.HR && employee.getDeptId() <= 0)
                || employee.getJoiningDate() == null || employee.getRole() == null
                || employee.getEmploymentStatus() == null
                || !employee.getPassword().matches(PASSWORD_PATTERN)) {
            LOGGER.warning("Rejected employee insert because required fields were missing");
            return false;
        }
        if (!employee.getEmpCode().matches("^NT[0-9]{1,3}$")) {
            LOGGER.warning("Rejected employee insert because employee code contained special characters");
            return false;
        }

        String sql = "INSERT INTO employees "
                + "(emp_code, full_name, email, password, role, designation, "
                + "dept_id, joining_date, employment_status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, employee.getEmpCode());
            statement.setString(2, employee.getFullName());
            statement.setString(3, employee.getEmail());
            statement.setString(4, employee.getPassword());
            statement.setString(5, employee.getRole().name());
            statement.setString(6, employee.getDesignation());

            if (employee.getDeptId() > 0) {
                statement.setInt(7, employee.getDeptId());
            } else {
                statement.setNull(7, java.sql.Types.INTEGER);
            }

            statement.setDate(8, Date.valueOf(employee.getJoiningDate()));
            statement.setString(9, employee.getEmploymentStatus().name());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding employee: " + employee.getEmpCode(), e);
            return false;
        }
    }

    /**
     * Get all active employees
     * @return List of all employees with ACTIVE status
     */
    public List<Employee> getAllEmployees() {
        List<Employee> employees = new ArrayList<>();

        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
                + "role, designation, dept_id, joining_date, employment_status "
                + "FROM employees "
                + "WHERE employment_status = 'ACTIVE' "
                + "ORDER BY emp_code ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                employees.add(mapResultSetToEmployee(resultSet));
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all employees", e);
        }

        return employees;
    }

    public List<Employee> getEmployeesForAdmin(String keyword, Role role,
            EmploymentStatus status, Integer departmentId) {
        List<Employee> employees = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT e.emp_id, e.emp_code, e.full_name, e.email, NULL AS password, "
                + "e.role, e.designation, e.dept_id, d.dept_name, e.joining_date, "
                + "e.employment_status FROM employees e LEFT JOIN departments d "
                + "ON e.dept_id = d.dept_id WHERE 1=1");
        List<Object> values = new ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (e.emp_code LIKE ? OR e.full_name LIKE ? OR e.email LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            values.add(pattern);
            values.add(pattern);
            values.add(pattern);
        }
        if (role != null) {
            sql.append(" AND e.role = ?");
            values.add(role.name());
        }
        if (status != null) {
            sql.append(" AND e.employment_status = ?");
            values.add(status.name());
        }
        if (departmentId != null && departmentId > 0) {
            sql.append(" AND e.dept_id = ?");
            values.add(departmentId);
        }
        sql.append(" ORDER BY e.emp_code ASC");

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int index = 0; index < values.size(); index++) {
                statement.setObject(index + 1, values.get(index));
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Employee employee = mapResultSetToEmployee(resultSet);
                    employee.setDepartmentName(resultSet.getString("dept_name"));
                    employees.add(employee);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching filtered admin employee list", e);
        }
        return employees;
    }

    /**
     * Get employee by ID
     * @param empId Employee ID
     * @return Employee object or null if not found
     */
    public Employee getEmployeeById(int empId) {
        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
                + "role, designation, dept_id, joining_date, employment_status "
                + "FROM employees "
                + "WHERE emp_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, empId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapResultSetToEmployee(resultSet);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching employee by ID: " + empId, e);
        }

        return null;
    }

    /**
     * Update existing employee
     * @param employee Employee object with updated values
     * @return true if update was successful
     */
    public boolean updateEmployee(Employee employee) {
        String sql = "UPDATE employees SET "
                + "emp_code = ?, "
                + "full_name = ?, "
                + "email = ?, "
                + "password = ?, "
                + "role = ?, "
                + "designation = ?, "
                + "dept_id = ?, "
                + "joining_date = ?, "
                + "employment_status = ? "
                + "WHERE emp_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, employee.getEmpCode());
            statement.setString(2, employee.getFullName());
            statement.setString(3, employee.getEmail());
            statement.setString(4, employee.getPassword());
            statement.setString(5, employee.getRole().name());
            statement.setString(6, employee.getDesignation());

            if (employee.getDeptId() > 0) {
                statement.setInt(7, employee.getDeptId());
            } else {
                statement.setNull(7, java.sql.Types.INTEGER);
            }

            statement.setDate(8, Date.valueOf(employee.getJoiningDate()));
            statement.setString(9, employee.getEmploymentStatus().name());
            statement.setInt(10, employee.getEmpId());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating employee: " + employee.getEmpId(), e);
            return false;
        }
    }

    /**
     * Soft delete - set employment status to INACTIVE
     * @param empId Employee ID to deactivate
     * @return true if deactivation was successful
     */
    public boolean deactivateEmployee(int empId) {
        String sql = "UPDATE employees "
                + "SET employment_status = 'INACTIVE' "
                + "WHERE emp_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, empId);
            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deactivating employee: " + empId, e);
            return false;
        }
    }

    /**
     * Search employees by keyword (matches emp_code, full_name, or email)
     * @param keyword Search keyword
     * @return List of matching employees
     */
    public List<Employee> searchEmployees(String keyword) {
        List<Employee> employees = new ArrayList<>();

        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
                + "role, designation, dept_id, joining_date, employment_status "
                + "FROM employees "
                + "WHERE (emp_code LIKE ? "
                + "OR full_name LIKE ? "
                + "OR email LIKE ?) "
                + "AND employment_status = 'ACTIVE' "
                + "ORDER BY emp_code ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            statement.setString(1, searchPattern);
            statement.setString(2, searchPattern);
            statement.setString(3, searchPattern);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    employees.add(mapResultSetToEmployee(resultSet));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error searching employees with keyword: " + keyword, e);
        }

        return employees;
    }

    public List<Employee> getEmployeesByDepartment(int departmentId) {
        return searchEmployeesByDepartment(departmentId, null);
    }

    public List<Employee> searchEmployeesByDepartment(int departmentId,
            String keyword) {
        List<Employee> employees = new ArrayList<>();
        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
                + "role, designation, dept_id, joining_date, employment_status "
                + "FROM employees WHERE dept_id = ? AND employment_status = 'ACTIVE' ";
        if (keyword != null && !keyword.isBlank()) {
            sql += "AND (emp_code LIKE ? OR full_name LIKE ? OR email LIKE ?) ";
        }
        sql += "ORDER BY emp_code ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, departmentId);
            if (keyword != null && !keyword.isBlank()) {
                String pattern = "%" + keyword.trim() + "%";
                statement.setString(2, pattern);
                statement.setString(3, pattern);
                statement.setString(4, pattern);
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    employees.add(mapResultSetToEmployee(resultSet));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching department employees", e);
        }
        return employees;
    }

    /**
     * Get employees by role
     * @param role Role to filter by
     * @return List of employees with specified role
     */
    public List<Employee> getEmployeesByRole(Role role) {
        List<Employee> employees = new ArrayList<>();

        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
                + "role, designation, dept_id, joining_date, employment_status "
                + "FROM employees "
                + "WHERE role = ? AND employment_status = 'ACTIVE' "
                + "ORDER BY emp_code ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, role.name());

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    employees.add(mapResultSetToEmployee(resultSet));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching employees by role: " + role, e);
        }

        return employees;
    }

    public List<Employee> getUnassignedEmployeesByRole(Role role) {
        List<Employee> employees = new ArrayList<>();
        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
                + "role, designation, dept_id, joining_date, employment_status "
                + "FROM employees WHERE role = ? AND employment_status = 'ACTIVE' "
                + "AND (dept_id IS NULL OR dept_id = 0) ORDER BY emp_code ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, role.name());
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    employees.add(mapResultSetToEmployee(resultSet));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching unassigned employees by role: " + role, e);
        }
        return employees;
    }

    /**
     * Check if employee code already exists
     * @param empCode Employee code to check
     * @return true if code exists
     */
    public boolean employeeCodeExists(String empCode) {
        String sql = "SELECT COUNT(*) FROM employees WHERE emp_code = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, empCode);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking employee code: " + empCode, e);
        }

        return false;
    }

    public boolean emailExists(String email) {
        return emailExists(email, 0);
    }

    public boolean emailExists(String email, int excludedEmployeeId) {
        String sql = "SELECT COUNT(*) FROM employees WHERE email = ? AND emp_id <> ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            statement.setInt(2, excludedEmployeeId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() && resultSet.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking email: " + email, e);
        }
        return false;
    }

    /**
     * Helper method to map ResultSet to Employee object
     */
    private Employee mapResultSetToEmployee(ResultSet resultSet) throws SQLException {
        Employee employee = new Employee();

        employee.setEmpId(resultSet.getInt("emp_id"));
        employee.setEmpCode(resultSet.getString("emp_code"));
        employee.setFullName(resultSet.getString("full_name"));
        employee.setEmail(resultSet.getString("email"));
        employee.setPassword(resultSet.getString("password"));
        employee.setRole(Role.valueOf(resultSet.getString("role")));
        employee.setDesignation(resultSet.getString("designation"));

        int deptId = resultSet.getInt("dept_id");
        employee.setDeptId(resultSet.wasNull() ? 0 : deptId);

        Date joiningDate = resultSet.getDate("joining_date");
        if (joiningDate != null) {
            employee.setJoiningDate(joiningDate.toLocalDate());
        }

        employee.setEmploymentStatus(
                EmploymentStatus.valueOf(resultSet.getString("employment_status"))
        );

        return employee;
    }
}
