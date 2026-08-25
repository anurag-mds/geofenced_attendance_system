package com.nimbus.admin.dao;

import com.nimbus.admin.model.ContactMessage;
import com.nimbus.admin.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ContactMessageDAO {
    public static final int ADMIN_HR_GROUP_ID = 1;

    private static final String TABLE_SQL = "CREATE TABLE IF NOT EXISTS contact_messages ("
            + "message_id INT AUTO_INCREMENT PRIMARY KEY, sender_id INT NOT NULL, "
            + "recipient_id INT NOT NULL, message TEXT NOT NULL, attachment_name VARCHAR(255), "
            + "conversation_id INT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
            + "INDEX contact_pair (sender_id, recipient_id), INDEX conversation (conversation_id))";

    public ContactMessageDAO() {
        try (Connection connection = DBConnection.getConnection(); Statement statement = connection.createStatement()) {
            statement.executeUpdate(TABLE_SQL);
            try {
                statement.executeUpdate("ALTER TABLE contact_messages ADD COLUMN conversation_id INT NULL");
            } catch (SQLException ignored) {
                // The column already exists on an upgraded database.
            }
            try {
                statement.executeUpdate("ALTER TABLE contact_messages MODIFY recipient_id INT NULL");
            } catch (SQLException ignored) {
                // Existing installations may already allow group messages.
            }
        } catch (SQLException exception) {
            throw new IllegalStateException("Unable to initialize contact messages", exception);
        }
    }

    public List<ContactMessage> getConversation(int firstEmployeeId, int secondEmployeeId) throws SQLException {
        String sql = "SELECT cm.message_id, cm.sender_id, s.full_name AS sender_name, cm.recipient_id, "
                + "cm.message, cm.attachment_name, cm.created_at FROM contact_messages cm "
                + "JOIN employees s ON s.emp_id = cm.sender_id WHERE (cm.sender_id = ? AND cm.recipient_id = ?) "
                + "OR (cm.sender_id = ? AND cm.recipient_id = ?) ORDER BY cm.created_at ASC";
        List<ContactMessage> messages = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, firstEmployeeId);
            statement.setInt(2, secondEmployeeId);
            statement.setInt(3, secondEmployeeId);
            statement.setInt(4, firstEmployeeId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    ContactMessage message = new ContactMessage();
                    message.setMessageId(result.getInt("message_id"));
                    message.setSenderId(result.getInt("sender_id"));
                    message.setSenderName(result.getString("sender_name"));
                    message.setRecipientId(result.getInt("recipient_id"));
                    message.setMessage(result.getString("message"));
                    message.setAttachmentName(result.getString("attachment_name"));
                    message.setCreatedAt(result.getTimestamp("created_at"));
                    messages.add(message);
                }
            }
        }
        return messages;
    }

    public int addMessage(int senderId, int recipientId, String message, String attachmentName) throws SQLException {
        String sql = "INSERT INTO contact_messages (sender_id, recipient_id, message, attachment_name) VALUES (?, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, senderId);
            statement.setInt(2, recipientId);
            statement.setString(3, message);
            statement.setString(4, attachmentName);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    public List<ContactMessage> getGroupConversation() throws SQLException {
        String sql = "SELECT cm.message_id, cm.sender_id, s.full_name AS sender_name, "
                + "cm.recipient_id, cm.message, cm.attachment_name, cm.created_at "
                + "FROM contact_messages cm JOIN employees s ON s.emp_id = cm.sender_id "
                + "WHERE cm.conversation_id = ? ORDER BY cm.created_at ASC, cm.message_id ASC";
        return getMessages(sql, ADMIN_HR_GROUP_ID, false, 0);
    }

    public int addGroupMessage(int senderId, String message, String attachmentName) throws SQLException {
        String sql = "INSERT INTO contact_messages (sender_id, recipient_id, message, attachment_name, conversation_id) "
                + "VALUES (?, NULL, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, senderId);
            statement.setString(2, message);
            statement.setString(3, attachmentName);
            statement.setInt(4, ADMIN_HR_GROUP_ID);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    public boolean clearConversation(int firstEmployeeId, int secondEmployeeId) throws SQLException {
        String sql = "DELETE FROM contact_messages WHERE "
                + "(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)";
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, firstEmployeeId);
            statement.setInt(2, secondEmployeeId);
            statement.setInt(3, secondEmployeeId);
            statement.setInt(4, firstEmployeeId);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean clearGroupConversation() throws SQLException {
        String sql = "DELETE FROM contact_messages WHERE conversation_id = ?";
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, ADMIN_HR_GROUP_ID);
            return statement.executeUpdate() > 0;
        }
    }

    private List<ContactMessage> getMessages(String sql, int firstValue,
            boolean direct, int secondValue) throws SQLException {
        List<ContactMessage> messages = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, firstValue);
            if (direct) {
                statement.setInt(2, secondValue);
                statement.setInt(3, secondValue);
                statement.setInt(4, firstValue);
            }
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    ContactMessage item = new ContactMessage();
                    item.setMessageId(result.getInt("message_id"));
                    item.setSenderId(result.getInt("sender_id"));
                    item.setSenderName(result.getString("sender_name"));
                    item.setRecipientId(result.getInt("recipient_id"));
                    item.setMessage(result.getString("message"));
                    item.setAttachmentName(result.getString("attachment_name"));
                    item.setCreatedAt(result.getTimestamp("created_at"));
                    messages.add(item);
                }
            }
        }
        return messages;
    }

    public boolean isParticipant(int messageId, int employeeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM contact_messages WHERE message_id = ? "
                + "AND (sender_id = ? OR recipient_id = ? OR (conversation_id = ? "
                + "AND EXISTS (SELECT 1 FROM employees e WHERE e.emp_id = ? "
                + "AND e.role IN ('ADMIN', 'HR') AND e.employment_status = 'ACTIVE')))";
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, messageId);
            statement.setInt(2, employeeId);
            statement.setInt(3, employeeId);
            statement.setInt(4, ADMIN_HR_GROUP_ID);
            statement.setInt(5, employeeId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() && result.getInt(1) > 0;
            }
        }
    }
}