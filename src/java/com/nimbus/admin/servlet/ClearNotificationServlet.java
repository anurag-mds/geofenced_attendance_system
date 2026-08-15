package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.NotificationDAO;
import com.nimbus.admin.model.Employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/ClearNotificationServlet")
public class ClearNotificationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }

        Employee employee =
                (Employee) session.getAttribute("employee");

        if (employee == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }

        int empId = employee.getEmpId();

        String action =
                request.getParameter("action");

        try {

            NotificationDAO notificationDAO =
                    new NotificationDAO();

            if ("clearAll".equals(action)) {

                notificationDAO.deleteAllNotifications(
                        empId
                );

            } else {

                String id =
                        request.getParameter(
                                "notificationId"
                        );

                if (id != null) {

                    int notificationId =
                            Integer.parseInt(id);

                    notificationDAO.deleteNotification(
                            notificationId,
                            empId
                    );
                }
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/NotificationServlet"
            );

        } catch (SQLException | NumberFormatException e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/NotificationServlet?error=clear"
            );
        }
    }
}