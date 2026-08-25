package com.nimbus.admin.dao;

import com.nimbus.admin.util.DBConnection;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

public class DashboardDAO {
    
    private static final Logger LOGGER = Logger.getLogger(DashboardDAO.class.getName());

    public Map<String, Integer> getAdminStats() {
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DBConnection.getConnection()) {
            // Total employees
            stats.put("totalEmployees", getCount(conn, "SELECT COUNT(*) FROM employees WHERE employment_status = 'ACTIVE'"));
            
            // Total departments
            stats.put("totalDepartments", getCount(conn, "SELECT COUNT(*) FROM departments"));
            
            // Pending leaves
            stats.put("pendingLeaves", getCount(conn, "SELECT COUNT(*) FROM leaves WHERE status = 'PENDING'"));
            
            // Pending WFH
            stats.put("pendingWFH", getCount(conn, "SELECT COUNT(*) FROM remote_work_requests WHERE status = 'PENDING'"));
            
        } catch (SQLException e) {
            LOGGER.severe("Error fetching admin stats: " + e.getMessage());
        }
        
        return stats;
    }

    private int getCount(Connection conn, String sql) {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.warning("Error executing count query: " + e.getMessage());
        }
        return 0;
    }
}
