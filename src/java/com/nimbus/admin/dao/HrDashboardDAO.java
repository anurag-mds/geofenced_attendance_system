package com.nimbus.admin.dao;

import com.nimbus.admin.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class HrDashboardDAO {

    // =========================================================
    // TOTAL EMPLOYEES
    // =========================================================

    public int getTotalEmployees() {

        String sql =
                "SELECT COUNT(*) " +
                "FROM employees";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    // =========================================================
    // ACTIVE EMPLOYEES
    // =========================================================

    public int getActiveEmployees() {

        String sql =
                "SELECT COUNT(*) " +
                "FROM employees " +
                "WHERE employment_status = 'ACTIVE'";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    // =========================================================
    // INACTIVE EMPLOYEES
    // =========================================================

    public int getInactiveEmployees() {

        String sql =
                "SELECT COUNT(*) " +
                "FROM employees " +
                "WHERE employment_status <> 'ACTIVE' " +
                "OR employment_status IS NULL";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    // =========================================================
    // PENDING LEAVE REQUESTS
    // =========================================================

    /*
     * IMPORTANT:
     *
     * The HR leave system considers SUBMITTED requests
     * as pending/actionable requests.
     *
     * HrLeaveRequestsServlet also uses:
     *
     * ?status=SUBMITTED
     *
     * Therefore the dashboard must count SUBMITTED,
     * not PENDING.
     */

    public int getPendingLeaveRequests() {

        String sql =
                "SELECT COUNT(*) " +
                "FROM leave_requests " +
                "WHERE status = 'SUBMITTED'";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


  

    public int getPendingRemoteRequests() {

        String sql =
                "SELECT COUNT(*) " +
                "FROM remote_work_approvals " +
                "WHERE status = 'PENDING'";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}