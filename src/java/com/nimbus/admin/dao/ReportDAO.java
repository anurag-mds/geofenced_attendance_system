package com.nimbus.admin.dao;

import com.nimbus.admin.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

public class ReportDAO {
    
    private static final Logger LOGGER = Logger.getLogger(ReportDAO.class.getName());

    public List<Map<String, Object>> getLeaveReport(String startDate, String endDate) {
        List<Map<String, Object>> report = new ArrayList<>();
        String sql = "SELECT e.emp_code, e.full_name, l.leave_type, l.start_date, l.end_date, l.status " +
                     "FROM leaves l JOIN employees e ON l.emp_id = e.emp_id " +
                     "WHERE l.start_date >= ? AND l.end_date <= ? ORDER BY l.start_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, startDate);
            pstmt.setString(2, endDate);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("empCode", rs.getString("emp_code"));
                row.put("fullName", rs.getString("full_name"));
                row.put("leaveType", rs.getString("leave_type"));
                row.put("startDate", rs.getDate("start_date"));
                row.put("endDate", rs.getDate("end_date"));
                row.put("status", rs.getString("status"));
                report.add(row);
            }
            
        } catch (SQLException e) {
            LOGGER.severe("Error generating leave report: " + e.getMessage());
        }
        
        return report;
    }

    public List<Map<String, Object>> getAttendanceReport(String month, String year) {
        // Placeholder for attendance report
        LOGGER.info("Attendance report requested for: " + month + "/" + year);
        return new ArrayList<>();
    }
}
