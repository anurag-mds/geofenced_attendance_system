package com.nimbus.admin.dao;

import com.nimbus.admin.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class HrDashboardDAO {

    public int getTotalEmployees(int departmentId) {

        String sql = "SELECT COUNT(*) FROM employees WHERE dept_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = executeCount(ps, departmentId)) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getActiveEmployees(int departmentId) {

        String sql = "SELECT COUNT(*) FROM employees "
                   + "WHERE employment_status = 'ACTIVE' AND dept_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }}

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getInactiveEmployees(int departmentId) {

        String sql = "SELECT COUNT(*) FROM employees "
               + "WHERE (employment_status <> 'ACTIVE' "
               + "OR employment_status IS NULL) AND dept_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }}

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    private ResultSet executeCount(PreparedStatement statement, int departmentId)
            throws Exception {
        statement.setInt(1, departmentId);
        return statement.executeQuery();
    }

    public int getPendingLeaveRequests(int departmentId) {

        String sql = "SELECT COUNT(*) FROM leave_requests lr "
                   + "JOIN employees e ON lr.emp_id = e.emp_id "
                   + "WHERE lr.status = 'PENDING' AND lr.reviewed_by IS NULL "
                   + "AND e.dept_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getPendingRemoteRequests(int departmentId) {

        String sql = "SELECT COUNT(*) FROM remote_work_approvals rwa "
                   + "JOIN employees e ON rwa.emp_id = e.emp_id "
                   + "WHERE rwa.status = 'PENDING' AND e.dept_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }}

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}