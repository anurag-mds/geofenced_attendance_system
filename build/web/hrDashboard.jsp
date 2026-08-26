<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>

<%
    Employee employee =
            (Employee) session.getAttribute("employee");

    if (employee == null) {
        response.sendRedirect("index.html");
        return;
    }

    Integer totalEmployees =
            (Integer) request.getAttribute("totalEmployees");

    Integer activeEmployees =
            (Integer) request.getAttribute("activeEmployees");

    Integer inactiveEmployees =
            (Integer) request.getAttribute("inactiveEmployees");

    Integer pendingLeaveRequests =
            (Integer) request.getAttribute("pendingLeaveRequests");

    Integer pendingRemoteRequests =
            (Integer) request.getAttribute("pendingRemoteRequests");


    if (totalEmployees == null) {
        totalEmployees = 0;
    }

    if (activeEmployees == null) {
        activeEmployees = 0;
    }

    if (inactiveEmployees == null) {
        inactiveEmployees = 0;
    }

    if (pendingLeaveRequests == null) {
        pendingLeaveRequests = 0;
    }

    if (pendingRemoteRequests == null) {
        pendingRemoteRequests = 0;
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>HR Dashboard</title>

    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>


    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }


        body {
            font-family: Arial, sans-serif;
            background: #f2f4f7;
            color: #222;
        }


        .page-content {
            padding: 30px 20px;
        }


        .container {
            max-width: 1150px;
            margin: auto;
        }


        /* =========================
           WELCOME
           ========================= */

        .welcome {
            margin-bottom: 25px;
        }


        .welcome h1 {
            font-size: 30px;
            margin-bottom: 8px;
        }


        .welcome p {
            color: #666;
            font-size: 15px;
        }


        /* =========================
           STATISTICS
           ========================= */

        .stats-grid {
            display: grid;

            grid-template-columns:
                repeat(3, 1fr);

            gap: 18px;

            margin-bottom: 30px;
        }


        .stat-card {
            background: white;

            border-radius: 12px;

            padding: 25px;

            box-shadow:
                0 3px 10px rgba(0,0,0,0.08);
        }


        .stat-title {
            color: #666;

            font-size: 14px;

            margin-bottom: 10px;
        }


        .stat-number {
            font-size: 32px;

            font-weight: bold;
        }


        /* =========================
           MANAGEMENT SECTIONS
           ========================= */

        .section-grid {
            display: grid;

            grid-template-columns:
                repeat(2, 1fr);

            gap: 20px;
        }


        .card {
            background: white;

            border-radius: 12px;

            padding: 25px;

            box-shadow:
                0 3px 10px rgba(0,0,0,0.08);
        }


        .card h2 {
            font-size: 21px;

            margin-bottom: 8px;
        }


        .card p {
            color: #666;

            line-height: 1.5;

            margin-bottom: 20px;
        }


        .request-count {
            font-size: 28px;

            font-weight: bold;

            margin-bottom: 15px;
        }


        /* =========================
           BUTTONS
           ========================= */

        .links {
            display: flex;

            flex-wrap: wrap;

            gap: 10px;
        }


        .btn {
            display: inline-block;

            padding: 11px 16px;

            border-radius: 7px;

            text-decoration: none;

            background: #222;

            color: white;

            font-size: 14px;
        }


        .btn:hover {
            background: #333;
        }


        .btn-secondary {
            background: #e9ecef;

            color: #333;
        }


        .btn-secondary:hover {
            background: #dfe3e6;
        }


        @media (max-width: 800px) {

            .stats-grid {
                grid-template-columns: 1fr;
            }


            .section-grid {
                grid-template-columns: 1fr;
            }

        }

    </style>

</head>


<body>


    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>


    <div class="page-content">

        <div class="container">


            <!-- =========================
                 WELCOME
                 ========================= -->

            <div class="welcome">

                <h1>
                    Welcome, <%= employee.getFullName() %>
                </h1>

                <p>
                    HR / Manager Dashboard
                </p>

            </div>



            <!-- =========================
                 EMPLOYEE STATISTICS
                 ========================= -->

            <div class="stats-grid">


                <div class="stat-card">

                    <div class="stat-title">
                        Total Employees
                    </div>

                    <div class="stat-number">
                        <%= totalEmployees %>
                    </div>

                </div>



                <div class="stat-card">

                    <div class="stat-title">
                        Active Employees
                    </div>

                    <div class="stat-number">
                        <%= activeEmployees %>
                    </div>

                </div>



                <div class="stat-card">

                    <div class="stat-title">
                        Inactive Employees
                    </div>

                    <div class="stat-number">
                        <%= inactiveEmployees %>
                    </div>

                </div>


            </div>



            <!-- =========================
                 MANAGEMENT
                 ========================= -->

            <div class="section-grid">


                <!-- =========================
                     LEAVE MANAGEMENT
                     ========================= -->

                <div class="card">

                    <h2>
                        Leave Management
                    </h2>


                    <p>
                        Review employee leave requests,
                        check their reasons and approve
                        or reject requests.
                    </p>


                    <div class="request-count">

                        <%= pendingLeaveRequests %>
                        Pending Request(s)

                    </div>


                    <div class="links">

                        <a class="btn"
                           href="<%= request.getContextPath() %>/HrLeaveRequestsServlet">

                            View Leave Requests

                        </a>


                        <a class="btn btn-secondary"
                           href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=SUBMITTED">

                            Pending Requests

                        </a>

                    </div>

                </div>



                <!-- =========================
                     WORK FROM HOME MANAGEMENT
                     ========================= -->

                <div class="card">

                    <h2>
                        Work From Home Management
                    </h2>


                    <p>
                        Review employee work from home
                        requests and approve or reject them.
                    </p>


                    <div class="request-count">

                        <%= pendingRemoteRequests %>
                        Pending Request(s)

                    </div>


                    <div class="links">

                        <a class="btn"
                           href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet">

                            View WFH Requests

                        </a>


                        <a class="btn btn-secondary"
                           href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet?status=PENDING">

                            Pending Requests

                        </a>

                    </div>

                </div>


            </div>


        </div>

    </div>


</body>

</html>