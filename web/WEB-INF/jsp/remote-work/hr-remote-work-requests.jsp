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


    List<RemoteWork> requests =
            (List<RemoteWork>)
            request.getAttribute("remoteRequests");


    String status =
            (String) request.getAttribute("status");


    if (status == null) {
        status = "ALL";
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Work From Home Requests</title>


    <style>

        * {
            box-sizing: border-box;
        }


        body {

            margin: 0;

            font-family:
                Arial,
                sans-serif;

            background: #f3f5f8;

            color: #222;
        }


        .container {

            max-width: 1200px;

            margin: 0 auto;

            padding: 45px 30px 60px;
        }


        /* =====================================================
           BACK
           ===================================================== */

        .back {

            display: inline-block;

            margin-bottom: 25px;

            color: #222;

            text-decoration: none;

            font-size: 16px;
        }


        .back:hover {

            text-decoration: underline;
        }


        /* =====================================================
           HEADER
           ===================================================== */

        .header {

            margin-bottom: 25px;
        }


        .header h1 {

            margin: 0 0 8px;

            font-size: 38px;

            color: #111;
        }


        .header p {

            margin: 0;

            color: #666;

            font-size: 17px;
        }


        /* =====================================================
           FILTERS
           ===================================================== */

        .filters {

            display: flex;

            gap: 10px;

            flex-wrap: wrap;

            margin-bottom: 22px;
        }


        .filter {

            text-decoration: none;

            padding: 10px 18px;

            border-radius: 8px;

            background: #e8ebee;

            color: #333;

            font-size: 14px;

            transition: 0.2s;
        }


        .filter:hover {

            background: #dce0e4;
        }


        .filter.active {

            background: #222;

            color: white;
        }


        /* =====================================================
           TABLE CARD
           ===================================================== */

        .card {

            background: white;

            border-radius: 15px;

            padding: 22px;

            box-shadow:
                0 4px 15px
                rgba(0,0,0,0.07);

            overflow-x: auto;
        }


        table {

            width: 100%;

            border-collapse: collapse;

            min-width: 850px;
        }


        th {

            background: #f4f5f6;

            padding: 15px;

            text-align: left;

            font-size: 14px;

            font-weight: 700;

            border-bottom:
                1px solid #ddd;
        }


        td {

            padding: 16px 15px;

            border-bottom:
                1px solid #e4e4e4;

            font-size: 14px;

            color: #444;
        }


        tr:last-child td {

            border-bottom: none;
        }


        .employee {

            font-weight: 600;

            color: #222;
        }


        /* =====================================================
           STATUS
           ===================================================== */

        .status {

            display: inline-block;

            padding: 6px 12px;

            border-radius: 20px;

            font-size: 12px;

            font-weight: 700;
        }


        .status.pending {

            background: #fff3cd;

            color: #8a6500;
        }


        .status.approved {

            background: #e7f6ec;

            color: #18753a;
        }


        .status.rejected {

            background: #fde8e8;

            color: #b42318;
        }


        /* =====================================================
           ACTION BUTTONS
           ===================================================== */

        .actions {

            display: flex;

            gap: 8px;

            align-items: center;
        }


        .action-btn {

            border: none;

            padding: 8px 14px;

            border-radius: 7px;

            font-size: 13px;

            cursor: pointer;
        }


        .approve {

            background: #222;

            color: white;
        }


        .approve:hover {

            background: #333;
        }


        .reject {

            background: #e9ecef;

            color: #222;
        }


        .reject:hover {

            background: #d9dcdf;
        }


        /* =====================================================
           EMPTY
           ===================================================== */

        .empty {

            text-align: center;

            padding: 60px 20px;

            color: #777;
        }


        .empty h2 {

            margin: 0 0 8px;

            font-size: 21px;

            color: #333;
        }


        .empty p {

            margin: 0;

            font-size: 14px;
        }


        /* =====================================================
           MOBILE
           ===================================================== */

        @media (max-width: 700px) {

            .container {

                padding:
                    30px 16px 45px;
            }


            .header h1 {

                font-size: 29px;
            }


            .header p {

                font-size: 15px;
            }
        }

    </style>

</head>


<body>


<div class="container">


    <!-- =====================================================
         BACK TO DASHBOARD
         ===================================================== -->

    <a href="<%= request.getContextPath() %>/HrDashboardServlet"
       class="back">

        &larr; Back to HR Dashboard

    </a>


    <!-- =====================================================
         HEADER
         ===================================================== -->

    <div class="header">

        <h1>
            Work From Home Requests
        </h1>

        <p>
            Review and manage employee work from home requests.
        </p>

    </div>


    <!-- =====================================================
         FILTERS
         ===================================================== -->

    <div class="filters">


        <!-- ALL -->

        <a href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet"
           class="filter <%= "ALL".equals(status)
                   ? "active"
                   : "" %>">

            All

        </a>


        <!-- PENDING -->

        <a href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet?status=PENDING"
           class="filter <%= "PENDING".equals(status)
                   ? "active"
                   : "" %>">

            Pending

        </a>


        <!-- APPROVED -->

        <a href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet?status=APPROVED"
           class="filter <%= "APPROVED".equals(status)
                   ? "active"
                   : "" %>">

            Approved

        </a>


        <!-- REJECTED -->

        <a href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet?status=REJECTED"
           class="filter <%= "REJECTED".equals(status)
                   ? "active"
                   : "" %>">

            Rejected

        </a>


    </div>


    <!-- =====================================================
         REQUEST TABLE
         ===================================================== -->

    <div class="card">


        <% if (requests == null ||
                requests.isEmpty()) { %>


            <div class="empty">

                <h2>
                    No WFH Requests Found
                </h2>

                <p>
                    There are no work from home requests
                    in this category.
                </p>

            </div>


        <% } else { %>


            <table>


                <thead>

                    <tr>

                        <th>
                            Employee
                        </th>

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

                        <th>
                            Action
                        </th>

                    </tr>

                </thead>


                <tbody>


                <% for (RemoteWork item : requests) { %>


                    <tr>


                        <!-- EMPLOYEE -->

                        <td>

                            <span class="employee">

                                Employee #<%= item.getEmpId() %>

                            </span>

                        </td>


                        <!-- START -->

                        <td>

                            <%= item.getStartDate() %>

                        </td>


                        <!-- END -->

                        <td>

                            <%= item.getEndDate() %>

                        </td>


                        <!-- REQUESTED ON -->

                        <td>

                            <%= item.getRequestedOn() %>

                        </td>


                        <!-- STATUS -->

                        <td>

                            <span class="status
                                <%= item.getStatus()
                                        .toLowerCase() %>">

                                <%= item.getStatus() %>

                            </span>

                        </td>


                        <!-- ACTION -->

                        <td>


                            <% if ("PENDING".equalsIgnoreCase(
                                    item.getStatus())) { %>


                                <div class="actions">


                                    <!-- APPROVE -->

                                    <form method="post"
                                          action="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet">

                                        <input type="hidden"
                                               name="remoteId"
                                               value="<%= item.getRemoteId() %>">


                                        <input type="hidden"
                                               name="action"
                                               value="APPROVE">


                                        <button type="submit"
                                                class="action-btn approve">

                                            Approve

                                        </button>

                                    </form>


                                    <!-- REJECT -->

                                    <form method="post"
                                          action="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet"
                                          onsubmit="return confirm('Reject this WFH request?');">

                                        <input type="hidden"
                                               name="remoteId"
                                               value="<%= item.getRemoteId() %>">


                                        <input type="hidden"
                                               name="action"
                                               value="REJECT">


                                        <button type="submit"
                                                class="action-btn reject">

                                            Reject

                                        </button>

                                    </form>


                                </div>


                            <% } else { %>


                                <span style="color:#999;">
                                    &mdash;
                                </span>


                            <% } %>


                        </td>


                    </tr>


                <% } %>


                </tbody>


            </table>


        <% } %>


    </div>


</div>


</body>

</html>