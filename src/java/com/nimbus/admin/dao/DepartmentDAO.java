package com.nimbus.admin.dao;

import com.nimbus.admin.model.Department;
import com.nimbus.admin.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class DepartmentDAO {
    
    private static final Logger LOGGER = Logger.getLogger(DepartmentDAO.class.getName());

    public DepartmentDAO() {
        ensureActiveColumn();
    }

    private void ensureActiveColumn() {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            try {
                stmt.executeUpdate("ALTER TABLE departments ADD COLUMN active TINYINT(1) NOT NULL DEFAULT 1");
            } catch (SQLException ignored) {
                // The column already exists on an upgraded database.
            }
        } catch (SQLException e) {
            LOGGER.severe("Unable to initialize department status: " + e.getMessage());
        }
    }

    public boolean addDepartment(Department dept) {
        String sql = "INSERT INTO departments (dept_name) VALUES (?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dept.getDeptName());
            
            int rowsAffected = pstmt.executeUpdate();
            LOGGER.info("Department added: " + dept.getDeptName());
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            LOGGER.severe("Error adding department: " + e.getMessage());
            return false;
        }
    }

    public boolean addDepartment(Department dept, int hrEmployeeId) {
        if (dept == null || dept.getDeptName() == null || dept.getDeptName().isBlank()
            || hrEmployeeId <= 0) {
            return false;
        }
        String insertSql = "INSERT INTO departments (dept_name) VALUES (?)";
        String assignHrSql = "UPDATE employees SET dept_id = ? "
            + "WHERE emp_id = ? AND role = 'HR' AND employment_status = 'ACTIVE' "
            + "AND (dept_id IS NULL OR dept_id = 0)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement insert = conn.prepareStatement(insertSql,
                    Statement.RETURN_GENERATED_KEYS)) {
                insert.setString(1, dept.getDeptName());
                if (insert.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
                try (ResultSet keys = insert.getGeneratedKeys()) {
                    if (!keys.next()) {
                        conn.rollback();
                        return false;
                    }
                    int departmentId = keys.getInt(1);
                    try (PreparedStatement assign = conn.prepareStatement(assignHrSql)) {
                        assign.setInt(1, departmentId);
                        assign.setInt(2, hrEmployeeId);
                        if (assign.executeUpdate() != 1) {
                            conn.rollback();
                            return false;
                        }
                    }
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.severe("Error adding department with HR representative: " + e.getMessage());
            return false;
        }
    }

    public List<Department> getAllDepartments() {
        List<Department> departments = new ArrayList<>();
        String sql = "SELECT d.dept_id, d.dept_name, "
            + "COUNT(CASE WHEN e.employment_status = 'ACTIVE' "
            + "THEN 1 END) AS active_employee_count "
            + ", d.active FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id "
            + "GROUP BY d.dept_id, d.dept_name, d.active ORDER BY d.dept_name";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Department dept = new Department();
                dept.setDeptId(rs.getInt("dept_id"));
                dept.setDeptName(rs.getString("dept_name"));
                dept.setDeptCode("DEPT-" + dept.getDeptId());
                dept.setActiveEmployeeCount(rs.getInt("active_employee_count"));
                dept.setActive(rs.getBoolean("active"));
                departments.add(dept);
            }
            
        } catch (SQLException e) {
            LOGGER.severe("Error fetching departments: " + e.getMessage());
        }
        
        return departments;
    }

    public Department getDepartmentById(int deptId) {
        String sql = "SELECT dept_id, dept_name FROM departments WHERE dept_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, deptId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Department dept = new Department();
                dept.setDeptId(rs.getInt("dept_id"));
                dept.setDeptName(rs.getString("dept_name"));
                dept.setDeptCode("DEPT-" + dept.getDeptId());
                return dept;
            }
            
        } catch (SQLException e) {
            LOGGER.severe("Error fetching department by ID: " + e.getMessage());
        }
        
        return null;
    }

    public boolean updateDepartment(Department dept) {
        String sql = "UPDATE departments SET dept_name = ? WHERE dept_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dept.getDeptName());
            pstmt.setInt(2, dept.getDeptId());
            
            int rowsAffected = pstmt.executeUpdate();
            LOGGER.info("Department updated: " + dept.getDeptName());
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            LOGGER.severe("Error updating department: " + e.getMessage());
            return false;
        }
    }

    public boolean setDepartmentActive(int deptId, boolean active) {
        String sql = "UPDATE departments SET active = ? WHERE dept_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, active);
            stmt.setInt(2, deptId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.severe("Error changing department status: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteDepartment(int deptId) {
        String sql = "DELETE FROM departments WHERE dept_id = ? "
            + "AND NOT EXISTS (SELECT 1 FROM employees WHERE dept_id = ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, deptId);
            pstmt.setInt(2, deptId);
            int rowsAffected = pstmt.executeUpdate();
            LOGGER.info("Department deleted: ID " + deptId);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            LOGGER.severe("Error deleting department: " + e.getMessage());
            return false;
        }
    }

    public boolean departmentCodeExists(String deptCode) {
        return false;
    }
}
