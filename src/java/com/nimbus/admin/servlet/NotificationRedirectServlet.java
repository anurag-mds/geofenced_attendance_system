package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.NotificationDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Notification;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/NotificationRedirectServlet")
public class NotificationRedirectServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Employee employee = session == null ? null : (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        try {
            int notificationId = Integer.parseInt(request.getParameter("notificationId"));
            NotificationDAO dao = new NotificationDAO();
            List<Notification> notifications = dao.getNotifications(employee.getEmpId());
            Notification selected = notifications.stream()
                    .filter(notification -> notification.getNotificationId() == notificationId)
                    .findFirst().orElse(null);
            if (selected == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            dao.markAsRead(notificationId, employee.getEmpId());
            String target = selected.getTargetUrl();
            response.sendRedirect(request.getContextPath()
                    + (target != null && target.startsWith("/") ? target : "/NotificationServlet"));
        } catch (NumberFormatException exception) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException exception) {
            throw new ServletException("Unable to open notification", exception);
        }
    }
}