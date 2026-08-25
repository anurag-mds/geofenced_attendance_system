package com.nimbus.admin.dao;

import com.nimbus.admin.model.Notification;
import com.nimbus.admin.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public void addNotification(int employeeId, String message, String type)
            throws SQLException {
        addNotification(employeeId, message, type, null);
    }

    public void addNotification(int employeeId, String message, String type,
            String targetUrl) throws SQLException {
        ensureTargetColumn();
        String sql = "INSERT INTO notifications (emp_id, message, type, is_read, target_url) "
                + "VALUES (?, ?, ?, 0, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setString(2, message);
            ps.setString(3, type);
            ps.setString(4, targetUrl);
            ps.executeUpdate();
        }
    }

    private void ensureTargetColumn() throws SQLException {
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(
                "ALTER TABLE notifications ADD COLUMN target_url VARCHAR(500) NULL")) {
            ps.executeUpdate();
        } catch (SQLException exception) {
            if (exception.getErrorCode() != 1060) {
                throw exception;
            }
        }
    }

    /*
     * Get database connection using the same DBConnection
     * class used by the rest of the project.
     */
    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    /*
     * Get all notifications belonging to one employee.
     */
    public List<Notification> getNotifications(int empId)
            throws SQLException {

        List<Notification> notifications = new ArrayList<>();
        ensureTargetColumn();

        String sql =
                "SELECT notification_id, emp_id, message, type, "
                + "is_read, created_at, target_url "
                + "FROM notifications "
                + "WHERE emp_id = ? "
                + "ORDER BY created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, empId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Notification notification = new Notification();

                    notification.setNotificationId(
                            rs.getInt("notification_id"));

                    notification.setEmpId(
                            rs.getInt("emp_id"));

                    notification.setMessage(
                            rs.getString("message"));

                    notification.setType(
                            rs.getString("type"));

                    notification.setRead(
                            rs.getBoolean("is_read"));

                    notification.setCreatedAt(
                            rs.getTimestamp("created_at"));

                        notification.setTargetUrl(rs.getString("target_url"));
                            if (notification.getTargetUrl() == null
                                && "ACCOUNT".equals(notification.getType())
                                && notification.getMessage() != null
                                && notification.getMessage().startsWith("New message from ")) {
                            notification.setTargetUrl(resolveContactTarget(con,
                                notification.getMessage().substring("New message from ".length())));
                            }

                    notifications.add(notification);
                }
            }
        }

        return notifications;
    }

    private String resolveContactTarget(Connection connection, String senderName)
            throws SQLException {
        String sql = "SELECT emp_id FROM employees WHERE full_name = ? LIMIT 1";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, senderName.trim());
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? "/ContactServlet?contactWith=" + result.getInt("emp_id") : null;
            }
        }
    }

    /*
     * Count unread notifications for one employee.
     */
    public int getUnreadCount(int empId)
            throws SQLException {

        String sql =
                "SELECT COUNT(*) "
                + "FROM notifications "
                + "WHERE emp_id = ? "
                + "AND is_read = 0";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, empId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /*
     * Mark one notification as read.
     */
    public void markAsRead(int notificationId, int empId)
            throws SQLException {

        String sql =
                "UPDATE notifications "
                + "SET is_read = 1 "
                + "WHERE notification_id = ? "
                + "AND emp_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, notificationId);
            ps.setInt(2, empId);

            ps.executeUpdate();
        }
    }

    /*
     * Delete one notification.
     */
    public void deleteNotification(int notificationId, int empId)
            throws SQLException {

        String sql =
                "DELETE FROM notifications "
                + "WHERE notification_id = ? "
                + "AND emp_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, notificationId);
            ps.setInt(2, empId);

            ps.executeUpdate();
        }
    }

    /*
     * Delete all notifications belonging to one employee.
     */
    public void deleteAllNotifications(int empId)
            throws SQLException {

        String sql =
                "DELETE FROM notifications "
                + "WHERE emp_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, empId);

            ps.executeUpdate();
        }
    }
}