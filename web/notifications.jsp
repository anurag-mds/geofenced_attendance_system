<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.nimbus.admin.model.Notification" %>
<%@ page import="com.nimbus.admin.model.Employee" %>

<%
    Employee employee =
            (Employee) session.getAttribute("employee");

    if (employee == null) {
        response.sendRedirect("index.html");
        return;
    }

    List<Notification> notifications =
            (List<Notification>)
            request.getAttribute("notifications");

    Integer unreadCount =
            (Integer)
            request.getAttribute("unreadCount");

    if (unreadCount == null) {
        unreadCount = 0;
    }
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Notifications</title>

    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f2f4f7;
            color: #222;
        }

        .page-content {
            padding: 30px;
        }

        .notification-container {
            max-width: 950px;
            margin: 0 auto;
        }

        .notification-header {
            background: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);

            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .notification-header h1 {
            margin: 0 0 6px 0;
            font-size: 26px;
        }

        .notification-header p {
            margin: 0;
            color: #777;
        }

        .clear-all-btn {
            border: none;
            background: #222;
            color: white;
            padding: 10px 16px;
            border-radius: 6px;
            cursor: pointer;
        }

        .clear-all-btn:hover {
            opacity: 0.85;
        }

        .notification-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 12px;

            box-shadow: 0 2px 8px rgba(0,0,0,0.06);

            display: flex;
            justify-content: space-between;
            align-items: center;

            border-left: 5px solid #999;
            text-decoration: none;
            color: inherit;
        }

        .notification-card:hover { background: #f6f8fa; }

        .notification-card.unread {
            background: #fafafa;
        }

        .notification-card.LEAVE {
            border-left-color: #222;
        }

        .notification-card.PERMISSION {
            border-left-color: #555;
        }

        .notification-card.ATTENDANCE {
            border-left-color: #888;
        }

        .notification-card.ACCOUNT {
            border-left-color: #aaa;
        }

        .notification-message {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .notification-date {
            font-size: 13px;
            color: #777;
        }

        .unread-label {
            display: inline-block;
            font-size: 11px;
            background: #222;
            color: white;
            padding: 3px 7px;
            border-radius: 10px;
            margin-left: 8px;
        }

        .clear-btn {
            border: 1px solid #ddd;
            background: white;
            color: #444;
            padding: 8px 13px;
            border-radius: 5px;
            cursor: pointer;
        }

        .clear-btn:hover {
            background: #f1f1f1;
        }

        .empty-notifications {
            background: white;
            padding: 50px;
            text-align: center;
            border-radius: 10px;
            color: #777;
            box-shadow: 0 3px 10px rgba(0,0,0,0.06);
        }

        .empty-notifications h2 {
            color: #333;
            margin-bottom: 8px;
        }

        @media (max-width: 700px) {

            .notification-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

            .notification-card {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

        }

    </style>

</head>

<body>

    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>

    <div class="page-content">

        <div class="notification-container">

            <div class="notification-header">

                <div>

                    <h1>
                        🔔 Notifications
                    </h1>

                    <p>
                        You have
                        <strong><%= unreadCount %></strong>
                        unread notification(s).
                    </p>

                </div>

                <% if (notifications != null
                        && !notifications.isEmpty()) { %>

                      <form method="post"
                          action="<%= request.getContextPath() %>/ClearNotificationServlet">
                        <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">

                        <input type="hidden"
                               name="action"
                               value="clearAll">

                        <button class="clear-all-btn"
                                type="submit">

                            Clear All

                        </button>

                    </form>

                <% } %>

            </div>


            <% if (notifications == null
                    || notifications.isEmpty()) { %>

                <div class="empty-notifications">

                    <h2>No Notifications</h2>

                    <p>
                        You don't have any notifications right now.
                    </p>

                </div>

            <% } else { %>


                <% for (Notification notification
                        : notifications) { %>

                          <div class="notification-card
                        <%= notification.getType() %>
                        <%= notification.isRead()
                              ? ""
                                          : "unread" %>"
                              role="link" tabindex="0"
                              onclick="window.location.href='<%= request.getContextPath() %>/NotificationRedirectServlet?notificationId=<%= notification.getNotificationId() %>'"
                              onkeydown="if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); this.click(); }">

                        <div>

                            <div class="notification-message">

                                <%= notification.getMessage() %>

                                <% if (!notification.isRead()) { %>

                                    <span class="unread-label">
                                        NEW
                                    </span>

                                <% } %>

                            </div>

                            <div class="notification-date">

                                <%= notification.getCreatedAt() %>

                            </div>

                        </div>


                        <form method="post"
                            action="<%= request.getContextPath() %>/ClearNotificationServlet">
                            <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">

                            <input type="hidden"
                                   name="notificationId"
                                   value="<%= notification.getNotificationId() %>">

                            <button class="clear-btn"
                                    type="submit"
                                    onclick="event.preventDefault(); event.stopPropagation(); this.form.submit();">

                                Clear

                            </button>

                        </form>

                    </div>

                <% } %>

            <% } %>

        </div>

    </div>

</body>

</html>