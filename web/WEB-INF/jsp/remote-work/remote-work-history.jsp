<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="com.nimbus.admin.model.RemoteWork" %>

<%
    Employee employee =
            (Employee) session.getAttribute("employee");


    if (employee == null) {

        response.sendRedirect(
                request.getContextPath()
                + "/index.html"
        );

        return;
    }


    List<RemoteWork> remoteRequests =
            (List<RemoteWork>)
            request.getAttribute("remoteRequests");


    String success =
            (String) request.getAttribute("success");
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Work From Home History</title>


    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>


    <style>

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

            max-width: 1000px;

            margin: 0 auto;

        }


        .header {

            margin-bottom: 25px;

        }


        .header h1 {

            margin: 0 0 8px 0;

            font-size: 30px;

            color: #111;

        }


        .header p {

            margin: 0;

            color: #666;

            font-size: 15px;

        }


        /* =====================================================
           SUCCESS
           ===================================================== */

        .success {

            background: #f0f0f0;

            color: #333;

            border-left: 4px solid #222;

            padding: 12px 15px;

            border-radius: 5px;

            margin-bottom: 20px;

        }


        /* =====================================================
           TABLE CARD
           ===================================================== */

        .table-card {

            background: #fff;

            border-radius: 12px;

            padding: 25px;

            box-shadow:
                0 3px 12px
                rgba(0, 0, 0, 0.07);

            overflow-x: auto;

        }


        table {

            width: 100%;

            border-collapse: collapse;

        }


        th,
        td {

            padding: 15px;

            border-bottom:
                1px solid #e5e5e5;

            text-align: left;

            white-space: nowrap;

        }


        th {

            background: #f5f6f7;

            color: #333;

            font-weight: 600;

            font-size: 14px;

        }


        td {

            color: #444;

            font-size: 14px;

        }


        tr:last-child td {

            border-bottom: none;

        }


        /* =====================================================
           STATUS
           ===================================================== */

        .status {

            display: inline-block;

            padding: 5px 10px;

            border-radius: 5px;

            font-size: 12px;

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


        /* =====================================================
           EMPTY
           ===================================================== */

        .empty {

            text-align: center;

            padding: 50px 20px;

            color: #777;

        }


        .empty h2 {

            margin: 0 0 8px 0;

            color: #333;

        }


        /* =====================================================
           BUTTON
           ===================================================== */

        .apply-link {

            display: inline-block;

            margin-top: 22px;

            padding: 11px 17px;

            background: #222;

            color: #fff;

            border-radius: 6px;

            text-decoration: none;

            font-size: 14px;

        }


        .apply-link:hover {

            background: #333;

        }


        .back-link {

            display: inline-block;

            margin-top: 15px;

            margin-left: 10px;

            color: #444;

            text-decoration: none;

            font-size: 14px;

        }


        .back-link:hover {

            text-decoration: underline;

        }


        @media (max-width: 700px) {

            .page-content {

                padding: 20px;

            }


            .header h1 {

                font-size: 25px;

            }


            .table-card {

                padding: 15px;

            }

        }

    </style>

</head>


<body>


    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>


    <div class="page-content">

        <div class="container">


            <div class="header">

                <h1>
                    Work From Home History
                </h1>

                <p>
                    View all your submitted work from home requests.
                </p>

            </div>


            <% if ("1".equals(success)) { %>

                <div class="success">

                    Your work from home request has been
                    submitted successfully and is now
                    waiting for approval.

                </div>

            <% } %>


            <div class="table-card">


                <% if (remoteRequests == null
                        || remoteRequests.isEmpty()) { %>


                    <div class="empty">

                        <h2>
                            No WFH Requests
                        </h2>

                        <p>
                            You have not submitted any
                            work from home requests yet.
                        </p>

                    </div>


                <% } else { %>


                    <table>

                        <thead>

                            <tr>

                                <th>
                                    Start Date
                                </th>

                                <th>
                                    End Date
                                </th>

                                <th>
                                    Requested On
                                </th>

                                <th>
                                    Status
                                </th>

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


            <a href="<%= request.getContextPath() %>/ApplyRemoteWorkServlet"
               class="apply-link">

                + Apply for Work From Home

            </a>


            <a href="<%= request.getContextPath() %>/EmployeeLeaveMenuServlet"
               class="back-link">

                &larr; Back to Leave

            </a>


        </div>

    </div>


</body>

</html>