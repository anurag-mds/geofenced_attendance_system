<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.RemoteWork" %>

<%
    Employee employee =
            (Employee) session.getAttribute("employee");

    if (employee == null) {
        response.sendRedirect(
                request.getContextPath() + "/index.html"
        );
        return;
    }

    List<RemoteWork> remoteRequests =
            (List<RemoteWork>)
            request.getAttribute("remoteRequests");

    String error =
            (String) request.getAttribute("error");

    String success =
            request.getParameter("success");
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Work From Home</title>

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
        padding: 38px;
    }

    .container {
        max-width: 950px;
        margin: 0 auto;
    }

    /* =========================
       CARDS
       ========================= */

    .card {
        background: #ffffff;
        border-radius: 10px;
        padding: 30px;
        margin-bottom: 25px;
        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
    }

    h1 {
        margin: 0 0 8px 0;
        font-size: 30px;
        color: #111;
    }

    h2 {
        margin: 0;
        font-size: 25px;
        color: #111;
    }

    .subtitle {
        color: #666;
        margin: 0 0 28px 0;
        font-size: 16px;
    }

    .date-note {
        color: #777;
        font-size: 13px;
        margin: 10px 0 0;
    }

    /* =========================
       FORM
       ========================= */

    .form-row {
        display: flex;
        gap: 20px;
    }

    .form-group {
        flex: 1;
    }

    label {
        display: block;
        font-weight: bold;
        margin-bottom: 8px;
        color: #222;
    }

    input[type="date"] {
        width: 100%;
        padding: 12px;
        border: 1px solid #d5d9dd;
        border-radius: 6px;
        font-size: 14px;
        background: #fff;
        color: #222;
    }

    input[type="date"]:focus {
        outline: none;
        border-color: #222;
    }

    /* =========================
       BUTTON
       ========================= */

    .apply-btn {
        margin-top: 22px;
        padding: 12px 20px;
        border: none;
        border-radius: 6px;
        background: #222;
        color: #fff;
        font-size: 14px;
        cursor: pointer;
    }

    .apply-btn:hover {
        background: #333;
    }

    /* =========================
       MESSAGES
       ========================= */

    .success {
        background: #f0f0f0;
        color: #333;
        border-left: 4px solid #222;
        padding: 12px 15px;
        border-radius: 5px;
        margin-bottom: 20px;
    }

    .error {
        background: #f8f8f8;
        color: #333;
        border-left: 4px solid #555;
        padding: 12px 15px;
        border-radius: 5px;
        margin-bottom: 20px;
    }

    /* =========================
       REQUEST TABLE
       ========================= */

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
    }

    th,
    td {
        padding: 14px;
        border-bottom: 1px solid #e5e5e5;
        text-align: left;
    }

    th {
        background: #f5f6f7;
        color: #333;
        font-weight: 600;
    }

    td {
        color: #444;
    }

    /* =========================
       STATUS
       ========================= */

    .status {
        display: inline-block;
        padding: 5px 10px;
        border-radius: 5px;
        font-size: 13px;
        font-weight: 600;
    }

    .pending {
        background: #f1f1f1;
        color: #555;
    }

    .approved {
        background: #e8e8e8;
        color: #222;
    }

    .rejected {
        background: #eeeeee;
        color: #444;
    }

    .empty {
        color: #777;
        text-align: center;
        padding: 30px 20px;
    }

    /* =========================
       SIDEBAR WFH LINK
       ========================= */

    .app-sidebar .wfh-link {
        color: inherit !important;
        font-weight: normal;
    }

    .app-sidebar .wfh-link:hover {
        color: inherit !important;
    }

    /* =========================
       MOBILE
       ========================= */

    @media (max-width: 700px) {

        .page-content {
            padding: 20px;
        }

        .form-row {
            flex-direction: column;
            gap: 15px;
        }

        .card {
            padding: 22px;
        }

        h1 {
            font-size: 25px;
        }

        h2 {
            font-size: 22px;
        }

        table {
            font-size: 13px;
        }

    }

</style>

</head>

<body>

    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>

    <div class="page-content">

        <div class="container">

            <div class="card">

                <h1>Apply for Work From Home</h1>

                <p class="subtitle">
                    Select the dates for which you would like to work from home.
                </p>

                <% if ("1".equals(success)) { %>

                    <div class="success">
                        Your work from home request has been submitted successfully.
                    </div>

                <% } %>


                <% if (error != null) { %>

                    <div class="error">
                        <%= error %>
                    </div>

                <% } %>


                  <form method="post"
                      id="remoteWorkForm"
                      action="<%= request.getContextPath() %>/ApplyRemoteWorkServlet">
                    <input type="hidden" name="csrfToken" value="<%= com.nimbus.admin.util.CsrfToken.getToken(request) %>">

                    <div class="form-row">

                        <div class="form-group">

                            <label for="startDate">
                                Start Date
                            </label>

                            <input type="date"
                                   id="startDate"
                                   name="startDate"
                                min="<%= java.time.LocalDate.now() %>"
                                              value="<%= request.getParameter("startDate") == null ? "" : request.getParameter("startDate") %>"
                                   required>

                        </div>


                        <div class="form-group">

                            <label for="endDate">
                                End Date
                            </label>

                            <input type="date"
                                   id="endDate"
                                   name="endDate"
                                min="<%= java.time.LocalDate.now() %>"
                                              value="<%= request.getParameter("endDate") == null ? "" : request.getParameter("endDate") %>"
                                   required>

                        </div>

                    </div>

                    <p class="date-note">Requests can cover today or a future date, up to 15 calendar days.</p>

                    <button type="submit"
                            class="apply-btn">

                        Apply for Work From Home

                    </button>

                </form>

            </div>


            <div class="card">

                <h2>My Work From Home Requests</h2>

                <br>

                <% if (remoteRequests == null
                        || remoteRequests.isEmpty()) { %>

                    <div class="empty">
                        You have not submitted any work from home requests.
                    </div>

                <% } else { %>

                    <table>

                        <thead>

                            <tr>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Requested On</th>
                                <th>Status</th>
                            </tr>

                        </thead>

                        <tbody>

                            <% for (RemoteWork requestItem
                                    : remoteRequests) { %>

                                <tr>

                                    <td>
                                        <%= requestItem.getStartDate() %>
                                    </td>

                                    <td>
                                        <%= requestItem.getEndDate() %>
                                    </td>

                                    <td>
                                        <%= requestItem.getRequestedOn() %>
                                    </td>

                                    <td>

                                        <span class="status
                                            <%= requestItem.getStatus()
                                                    .toLowerCase() %>">

                                            <%= requestItem.getStatus() %>

                                        </span>

                                    </td>

                                </tr>

                            <% } %>

                        </tbody>

                    </table>

                <% } %>

            </div>

        </div>

    </div>

</body>

<script>
    (function () {
        const form = document.getElementById('remoteWorkForm');
        const start = document.getElementById('startDate');
        const end = document.getElementById('endDate');

        function updateEndLimit() {
            if (!start.value) {
                end.removeAttribute('max');
                return;
            }
            const latest = new Date(start.value + 'T00:00:00');
            latest.setDate(latest.getDate() + 14);
            end.max = latest.toISOString().slice(0, 10);
            if (end.value && end.value > end.max) {
                end.value = end.max;
            }
        }

        start.addEventListener('change', function () {
            end.min = start.value || '<%= java.time.LocalDate.now() %>';
            updateEndLimit();
        });
        updateEndLimit();

        form.addEventListener('submit', function (event) {
            if (end.value < start.value) {
                event.preventDefault();
                end.setCustomValidity('End date cannot be before start date.');
                end.reportValidity();
                end.setCustomValidity('');
            } else {
                end.setCustomValidity('');
            }
        });
    })();
</script>

</html>