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

@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // Get existing session
        HttpSession session =
                request.getSession(false);

        // No session → login
        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }

        // Get logged-in employee
        Employee employee =
                (Employee) session.getAttribute("employee");

        // No employee → login
        if (employee == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }

        // Get employee ID
        int empId = employee.getEmpId();

        try {

            NotificationDAO notificationDAO =
                    new NotificationDAO();

            // Get employee's notifications
            List<Notification> notifications =
                    notificationDAO.getNotifications(empId);

            // Get unread notification count
            int unreadCount =
                    notificationDAO.getUnreadCount(empId);

            // Send to JSP
            request.setAttribute(
                    "notifications",
                    notifications
            );

            request.setAttribute(
                    "unreadCount",
                    unreadCount
            );

            // Open notification page
            request.getRequestDispatcher(
                    "/notifications.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to load notifications."
            );

            request.getRequestDispatcher(
                    "/notifications.jsp"
            ).forward(request, response);
        }
    }
}