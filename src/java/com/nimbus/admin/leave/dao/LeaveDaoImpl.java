//This class implements all leave-related database access for the module.
//It uses the project's default leave_requests and leave_types tables so the
//Leave module works with the existing nimbus_tech_attendance schema.

package com.nimbus.admin.leave.dao;

import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveStatus;
import com.nimbus.admin.leave.model.LeaveType;
import com.nimbus.admin.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class LeaveDaoImpl implements LeaveDao {

    private static final String BASE_SELECT =
            "SELECT lr.leave_id, lr.emp_id, e.full_name, e.emp_code, "
            + "lr.leave_type_id, lt.type_name, "
            + "lr.start_date, lr.end_date, lr.reason, lr.status, "
            + "lr.applied_on, lr.reviewed_by "
            + "FROM leave_requests lr "
            + "JOIN employees e ON lr.emp_id = e.emp_id "
            + "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id ";

    @Override
    public List<LeaveType> findAllLeaveTypes() {
        String sql = "SELECT leave_type_id, type_name FROM leave_types "
                + "ORDER BY type_name";
        List<LeaveType> types = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                types.add(mapLeaveType(rs));
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.findAllLeaveTypes:");
            e.printStackTrace();
        }
        return types;
    }

    @Override
    public LeaveType findLeaveTypeById(int leaveTypeId) {
        String sql = "SELECT leave_type_id, type_name FROM leave_types "
                + "WHERE leave_type_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, leaveTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapLeaveType(rs);
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.findLeaveTypeById:");
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public int insertLeave(Leave leave) {
        String sql = "INSERT INTO leave_requests "
                + "(emp_id, leave_type_id, start_date, end_date, reason, status) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql,
                        Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, leave.getEmpId());
            ps.setInt(2, leave.getLeaveType().getLeaveTypeId());
            ps.setDate(3, java.sql.Date.valueOf(leave.getFromDate()));
            ps.setDate(4, java.sql.Date.valueOf(leave.getToDate()));
            ps.setString(5, leave.getReason());
            ps.setString(6, leave.getStatus().toDatabaseValue());

            int rows = ps.executeUpdate();
            if (rows == 0) {
                return -1;
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.insertLeave:");
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public Leave findById(int leaveId) {
        String sql = BASE_SELECT + "WHERE lr.leave_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, leaveId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapLeave(rs);
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.findById:");
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Leave> findByEmployeeId(int empId, LeaveStatus statusFilter,
            Integer leaveTypeIdFilter) {
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append("WHERE lr.emp_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(empId);

        appendFilters(sql, params, statusFilter, null, leaveTypeIdFilter, null, null);
        sql.append("ORDER BY lr.applied_on DESC, lr.leave_id DESC");

        return executeQuery(sql.toString(), params);
    }

    @Override
    public List<Leave> findRecentByEmployeeId(int empId, int limit) {
        String sql = BASE_SELECT
                + "WHERE lr.emp_id = ? "
                + "ORDER BY lr.applied_on DESC, lr.leave_id DESC LIMIT ?";

        List<Object> params = new ArrayList<>();
        params.add(empId);
        params.add(limit);

        return executeQuery(sql, params);
    }

    @Override
    public List<Leave> findAll(LeaveStatus statusFilter, String employeeSearch,
            Integer leaveTypeIdFilter, LocalDate fromDate, LocalDate toDate) {
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        appendFilters(sql, params, statusFilter, employeeSearch, leaveTypeIdFilter,
                fromDate, toDate);
        sql.append("ORDER BY lr.applied_on DESC, lr.leave_id DESC");

        return executeQuery(sql.toString(), params);
    }

    @Override
    public List<Leave> findRecentActivity(int limit) {
        String sql = BASE_SELECT + "ORDER BY lr.applied_on DESC, lr.leave_id DESC LIMIT ?";
        List<Object> params = new ArrayList<>();
        params.add(limit);
        return executeQuery(sql, params);
    }

    @Override
    public boolean updateStatus(int leaveId, LeaveStatus status, Integer reviewedBy) {
        String sql = "UPDATE leave_requests SET status = ?, reviewed_by = ? "
                + "WHERE leave_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status.toDatabaseValue());
            if (reviewedBy != null) {
                ps.setInt(2, reviewedBy);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setInt(3, leaveId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.updateStatus:");
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateLeave(Leave leave) {
        String sql = "UPDATE leave_requests SET leave_type_id = ?, start_date = ?, "
                + "end_date = ?, reason = ? "
                + "WHERE leave_id = ? AND emp_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, leave.getLeaveType().getLeaveTypeId());
            ps.setDate(2, java.sql.Date.valueOf(leave.getFromDate()));
            ps.setDate(3, java.sql.Date.valueOf(leave.getToDate()));
            ps.setString(4, leave.getReason());
            ps.setInt(5, leave.getLeaveId());
            ps.setInt(6, leave.getEmpId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.updateLeave:");
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean hasOverlappingLeave(int empId, LocalDate fromDate,
            LocalDate toDate, Integer excludeLeaveId) {
        String sql = "SELECT COUNT(*) FROM leave_requests "
                + "WHERE emp_id = ? "
                + "AND status IN ('PENDING', 'APPROVED') "
                + "AND start_date <= ? AND end_date >= ? ";

        if (excludeLeaveId != null) {
            sql += "AND leave_id <> ?";
        }

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, empId);
            ps.setDate(2, java.sql.Date.valueOf(toDate));
            ps.setDate(3, java.sql.Date.valueOf(fromDate));

            if (excludeLeaveId != null) {
                ps.setInt(4, excludeLeaveId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.hasOverlappingLeave:");
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int countByStatus(LeaveStatus status) {
        String sql = buildStatusCountSql(status);

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            if (status == LeaveStatus.SUBMITTED || status == LeaveStatus.UNDER_REVIEW) {
                // No extra parameters required.
            } else {
                ps.setString(1, status.toDatabaseValue());
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.countByStatus:");
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int sumApprovedDaysForYear(int empId, int year) {
        String sql = "SELECT COALESCE(SUM(DATEDIFF(end_date, start_date) + 1), 0) "
                + "FROM leave_requests "
                + "WHERE emp_id = ? AND status = 'APPROVED' "
                + "AND YEAR(start_date) = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, empId);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.sumApprovedDaysForYear:");
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int sumPendingDays(int empId) {
        String sql = "SELECT COALESCE(SUM(DATEDIFF(end_date, start_date) + 1), 0) "
                + "FROM leave_requests "
                + "WHERE emp_id = ? AND status = 'PENDING'";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, empId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.sumPendingDays:");
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public void insertNotification(int empId, String message) {
        String sql = "INSERT INTO notifications (emp_id, message, type) "
                + "VALUES (?, ?, 'LEAVE')";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, empId);
            ps.setString(2, message);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.insertNotification:");
            e.printStackTrace();
        }
    }

    private String buildStatusCountSql(LeaveStatus status) {
        if (status == LeaveStatus.SUBMITTED) {
            return "SELECT COUNT(*) FROM leave_requests "
                    + "WHERE status = 'PENDING' AND reviewed_by IS NULL";
        }
        if (status == LeaveStatus.UNDER_REVIEW) {
            return "SELECT COUNT(*) FROM leave_requests "
                    + "WHERE status = 'PENDING' AND reviewed_by IS NOT NULL";
        }
        return "SELECT COUNT(*) FROM leave_requests WHERE status = ?";
    }

    private void appendFilters(StringBuilder sql, List<Object> params,
            LeaveStatus statusFilter, String employeeSearch,
            Integer leaveTypeIdFilter, LocalDate fromDate, LocalDate toDate) {

        if (statusFilter != null) {
            appendStatusFilter(sql, statusFilter);
        }

        if (employeeSearch != null && !employeeSearch.trim().isEmpty()) {
            sql.append("AND (e.full_name LIKE ? OR e.emp_code LIKE ?) ");
            String pattern = "%" + employeeSearch.trim() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        if (leaveTypeIdFilter != null) {
            sql.append("AND lr.leave_type_id = ? ");
            params.add(leaveTypeIdFilter);
        }

        if (fromDate != null) {
            sql.append("AND lr.start_date >= ? ");
            params.add(java.sql.Date.valueOf(fromDate));
        }

        if (toDate != null) {
            sql.append("AND lr.end_date <= ? ");
            params.add(java.sql.Date.valueOf(toDate));
        }
    }

    private void appendStatusFilter(StringBuilder sql, LeaveStatus statusFilter) {
        if (statusFilter == LeaveStatus.SUBMITTED) {
            sql.append("AND lr.status = 'PENDING' AND lr.reviewed_by IS NULL ");
            return;
        }
        if (statusFilter == LeaveStatus.UNDER_REVIEW) {
            sql.append("AND lr.status = 'PENDING' AND lr.reviewed_by IS NOT NULL ");
            return;
        }
        sql.append("AND lr.status = '").append(statusFilter.toDatabaseValue()).append("' ");
    }

    private List<Leave> executeQuery(String sql, List<Object> params) {
        List<Leave> leaves = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                setParameter(ps, i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    leaves.add(mapLeave(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR IN LeaveDaoImpl.executeQuery:");
            e.printStackTrace();
        }
        return leaves;
    }

    private void setParameter(PreparedStatement ps, int index, Object value)
            throws SQLException {
        if (value instanceof Integer) {
            ps.setInt(index, (Integer) value);
        } else if (value instanceof java.sql.Date) {
            ps.setDate(index, (java.sql.Date) value);
        } else if (value instanceof String) {
            ps.setString(index, (String) value);
        }
    }

    private LeaveType mapLeaveType(ResultSet rs) throws SQLException {
        return new LeaveType(
                rs.getInt("leave_type_id"),
                rs.getString("type_name"));
    }

    private Leave mapLeave(ResultSet rs) throws SQLException {
        Leave leave = new Leave();
        leave.setLeaveId(rs.getInt("leave_id"));
        leave.setEmpId(rs.getInt("emp_id"));
        leave.setEmployeeName(rs.getString("full_name"));
        leave.setEmpCode(rs.getString("emp_code"));
        leave.setLeaveType(mapLeaveType(rs));

        java.sql.Date from = rs.getDate("start_date");
        java.sql.Date to = rs.getDate("end_date");
        leave.setFromDate(from.toLocalDate());
        leave.setToDate(to.toLocalDate());
        leave.setNumDays(Leave.calculateNumDays(
                leave.getFromDate(), leave.getToDate()));

        leave.setReason(rs.getString("reason"));

        Integer reviewedBy = null;
        int reviewer = rs.getInt("reviewed_by");
        if (!rs.wasNull()) {
            reviewedBy = reviewer;
            leave.setReviewedBy(reviewer);
        }

        leave.setStatus(LeaveStatus.fromDatabase(rs.getString("status"), reviewedBy));

        java.sql.Date appliedOn = rs.getDate("applied_on");
        if (appliedOn != null) {
            leave.setSubmittedAt(appliedOn.toLocalDate().atStartOfDay());
        }

        return leave;
    }
}
