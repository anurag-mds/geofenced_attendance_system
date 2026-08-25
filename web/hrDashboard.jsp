<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="com.nimbus.admin.model.Employee" %>

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


    Integer totalEmployees =
            (Integer) request.getAttribute(
                    "totalEmployees"
            );


    Integer activeEmployees =
            (Integer) request.getAttribute(
                    "activeEmployees"
            );


    Integer inactiveEmployees =
            (Integer) request.getAttribute(
                    "inactiveEmployees"
            );


    Integer pendingLeaveRequests =
            (Integer) request.getAttribute(
                    "pendingLeaveRequests"
            );


    Integer pendingRemoteRequests =
            (Integer) request.getAttribute(
                    "pendingRemoteRequests"
            );


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


    <style>

        * {
            box-sizing: border-box;
        }


        body {

            margin: 0;

            font-family:
                Arial,
                sans-serif;

            background: #f2f4f7;

            color: #222;

        }


        /* =====================================================
           HR NAVBAR
           ===================================================== */

        .hr-navbar {

            height: 70px;

            background: #222;

            color: #fff;

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding: 0 32px;

        }


        .hr-brand {

            font-size: 22px;

            font-weight: 600;

            letter-spacing: -0.3px;

        }


        .hr-navbar-right {

            display: flex;

            align-items: center;

            gap: 20px;

        }


        .hr-user-name {

            font-size: 14px;

            color: #fff;

        }


        .logout-btn {

            display: inline-block;

            padding: 10px 18px;

            background: #e74c3c;

            color: #fff;

            text-decoration: none;

            border-radius: 6px;

            font-size: 14px;

            transition: 0.2s;

        }


        .logout-btn:hover {

            background: #c0392b;

        }


        /* =====================================================
           PAGE
           ===================================================== */

        .page {

            max-width: 1200px;

            margin: 0 auto;

            padding: 38px 28px 50px;

        }


        /* =====================================================
           WELCOME
           ===================================================== */

        .welcome {

            margin-bottom: 30px;

        }


        .welcome h1 {

            margin: 0 0 8px;

            font-size: 32px;

            font-weight: 700;

            color: #111;

        }


        .welcome p {

            margin: 0;

            font-size: 15px;

            color: #6b7280;

        }


        /* =====================================================
           STAT CARDS
           ===================================================== */

        .stats-grid {

            display: grid;

            grid-template-columns:
                repeat(3, 1fr);

            gap: 20px;

            margin-bottom: 28px;

        }


        .stat-card {

            background: #fff;

            border-radius: 14px;

            padding: 25px 27px;

            box-shadow:
                0 3px 12px
                rgba(0, 0, 0, 0.07);

            border: 1px solid #eee;

        }


        .stat-label {

            color: #6b7280;

            font-size: 14px;

            margin-bottom: 12px;

        }


        .stat-number {

            font-size: 34px;

            font-weight: 700;

            color: #111;

        }


        /* =====================================================
           MANAGEMENT GRID
           ===================================================== */

        .management-grid {

            display: grid;

            grid-template-columns:
                repeat(2, 1fr);

            gap: 22px;

        }


        .management-card {

            background: #fff;

            border-radius: 14px;

            padding: 28px;

            border: 1px solid #eee;

            box-shadow:
                0 3px 12px
                rgba(0, 0, 0, 0.07);

        }


        .card-top {

            display: flex;

            align-items: flex-start;

            justify-content: space-between;

            gap: 20px;

            margin-bottom: 18px;

        }


        .card-title {

            margin: 0 0 7px;

            font-size: 21px;

            color: #111;

        }


        .card-description {

            margin: 0;

            color: #6b7280;

            font-size: 14px;

            line-height: 1.55;

        }


        /* =====================================================
           PENDING BOX
           ===================================================== */

        .pending-box {

            background: #f7f8fa;

            border: 1px solid #e6e8eb;

            border-radius: 10px;

            padding: 18px 20px;

            margin-bottom: 20px;

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 15px;

        }


        .pending-number {

            font-size: 30px;

            font-weight: 700;

            color: #111;

        }


        .pending-label {

            margin-top: 3px;

            font-size: 13px;

            color: #6b7280;

        }


        .pending-icon {

            width: 44px;

            height: 44px;

            border-radius: 10px;

            background: #e9ecef;

            display: flex;

            align-items: center;

            justify-content: center;

            font-size: 21px;

        }


        /* =====================================================
           BUTTONS
           ===================================================== */

        .card-actions {

            display: flex;

            flex-wrap: wrap;

            gap: 10px;

        }


        .btn {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 11px 17px;

            border-radius: 7px;

            text-decoration: none;

            font-size: 14px;

            font-weight: 500;

            transition: 0.2s;

        }


        .btn-primary {

            background: #222;

            color: #fff;

        }


        .btn-primary:hover {

            background: #333;

        }


        .btn-secondary {

            background: #edf0f2;

            color: #333;

        }


        .btn-secondary:hover {

            background: #e0e4e7;

        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 850px) {

            .stats-grid {

                grid-template-columns: 1fr;

            }


            .management-grid {

                grid-template-columns: 1fr;

            }

        }


        @media (max-width: 600px) {

            .hr-navbar {

                padding: 0 18px;

            }


            .hr-brand {

                font-size: 18px;

            }


            .hr-user-name {

                display: none;

            }


            .page {

                padding: 25px 18px 40px;

            }


            .welcome h1 {

                font-size: 26px;

            }


            .card-top {

                flex-direction: column;

            }

        }

    </style>

</head>


<body>


<!-- =========================================================
     SIMPLE HR NAVBAR
     No sidebar
     No hamburger
     No notifications
     ========================================================= -->

<header class="hr-navbar">

    <div class="hr-brand">

        Employee Attendance System

    </div>


    <div class="hr-navbar-right">

        <span class="hr-user-name">

            <%= employee.getFullName() %>

        </span>


        <a href="<%= request.getContextPath() %>/LogoutServlet"
           class="logout-btn"
           onclick="return confirm('Are you sure you want to logout?');">

            Logout

        </a>

    </div>

</header>



<!-- =========================================================
     DASHBOARD
     ========================================================= -->

<main class="page">


    <!-- =====================================================
         WELCOME
         ===================================================== -->

    <section class="welcome">

        <h1>

            Welcome,
            <%= employee.getFullName() %>

        </h1>


        <p>

            HR / Manager Dashboard

        </p>

    </section>



    <!-- =====================================================
         STATISTICS
         ===================================================== -->

    <section class="stats-grid">


        <div class="stat-card">

            <div class="stat-label">

                Total Employees

            </div>


            <div class="stat-number">

                <%= totalEmployees %>

            </div>

        </div>



        <div class="stat-card">

            <div class="stat-label">

                Active Employees

            </div>


            <div class="stat-number">

                <%= activeEmployees %>

            </div>

        </div>



        <div class="stat-card">

            <div class="stat-label">

                Inactive Employees

            </div>


            <div class="stat-number">

                <%= inactiveEmployees %>

            </div>

        </div>


    </section>



    <!-- =====================================================
         MANAGEMENT
         ===================================================== -->

    <section class="management-grid">


        <!-- =================================================
             LEAVE MANAGEMENT
             ================================================= -->

        <div class="management-card">


            <div class="card-top">

                <div>

                    <h2 class="card-title">

                        Leave Management

                    </h2>


                    <p class="card-description">

                        Review employee leave requests,
                        check their details and approve
                        or reject them.

                    </p>

                </div>


                <div class="pending-icon">

                    &#128203;

                </div>

            </div>



            <div class="pending-box">

                <div>

                    <div class="pending-number">

                        <%= pendingLeaveRequests %>

                    </div>


                    <div class="pending-label">

                        Pending Leave Request<%= pendingLeaveRequests == 1 ? "" : "s" %>

                    </div>

                </div>


                <div class="pending-icon">

                    &#9203;

                </div>

            </div>



            <div class="card-actions">


                <a href="<%= request.getContextPath() %>/HrLeaveRequestsServlet"
                   class="btn btn-primary">

                    View Leave Requests

                </a>


                <a href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=SUBMITTED"
                   class="btn btn-secondary">

                    Pending Requests

                </a>


            </div>


        </div>



        <!-- =================================================
             WFH MANAGEMENT
             ================================================= -->

        <div class="management-card">


            <div class="card-top">

                <div>

                    <h2 class="card-title">

                        Work From Home

                    </h2>


                    <p class="card-description">

                        Review employee work from home
                        requests and approve or reject them.

                    </p>

                </div>


                <div class="pending-icon">

                    &#127968;

                </div>

            </div>



            <div class="pending-box">

                <div>

                    <div class="pending-number">

                        <%= pendingRemoteRequests %>

                    </div>


                    <div class="pending-label">

                        Pending WFH Request<%= pendingRemoteRequests == 1 ? "" : "s" %>

                    </div>

                </div>


                <div class="pending-icon">

                    &#9203;

                </div>

            </div>



            <div class="card-actions">


                <a href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet"
                   class="btn btn-primary">

                    View WFH Requests

                </a>


    <a href="<%= request.getContextPath() %>/HrRemoteWorkRequestsServlet?status=PENDING"
   class="btn btn-secondary">
    Pending Requests
</a>


            </div>


        </div>


    </section>


</main>


</body>

</html>