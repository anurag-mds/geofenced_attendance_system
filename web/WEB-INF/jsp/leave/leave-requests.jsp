<%--
    HR Leave Request Management Page

    HR can:
    - View all leave requests
    - View pending/submitted requests
    - View under-review requests
    - View approved requests
    - View rejected requests
    - View cancelled requests
    - Search employees
    - Filter by leave type
    - Filter by dates
    - Open an individual request

    NOTE:
    The application represents database PENDING requests as:
        SUBMITTED
        UNDER_REVIEW

    Therefore the "Pending" tab uses SUBMITTED.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="com.nimbus.admin.leave.model.*" %>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>


<%
    /* ============================================================
       SESSION
       ============================================================ */

    Employee hr =
            (Employee) session.getAttribute("employee");

    if (hr == null) {

        response.sendRedirect(
                request.getContextPath() + "/index.html"
        );

        return;
    }


    /* ============================================================
       DATA FROM SERVLET
       ============================================================ */

    DateTimeFormatter dateFmt =
            DateTimeFormatter.ofPattern("dd MMM");


    List<Leave> leaveRequests =
            (List<Leave>) request.getAttribute(
                    "leaveRequests"
            );


    LeaveStatus statusFilter =
            (LeaveStatus) request.getAttribute(
                    "statusFilter"
            );


    Integer leaveTypeIdFilter =
            (Integer) request.getAttribute(
                    "leaveTypeIdFilter"
            );


    String employeeSearch =
            (String) request.getAttribute(
                    "employeeSearch"
            );


    String fromDate =
            (String) request.getAttribute(
                    "fromDate"
            );


    String toDate =
            (String) request.getAttribute(
                    "toDate"
            );


    List<LeaveType> leaveTypes =
            (List<LeaveType>) request.getAttribute(
                    "leaveTypes"
            );


    String success =
            (String) request.getAttribute(
                    "success"
            );


    String errorMsg =
            (String) request.getAttribute(
                    "errorMsg"
            );


    /* ============================================================
       PAGE TITLE
       ============================================================ */

    String pageTitle = "Leave Requests";

    String pageSubtitle =
            "Review employee leave requests and take HR action.";


    if (statusFilter == LeaveStatus.SUBMITTED) {

        pageTitle = "Pending Leave Requests";

        pageSubtitle =
                "Leave requests waiting for HR action.";

    } else if (statusFilter == LeaveStatus.UNDER_REVIEW) {

        pageTitle = "Leave Requests Under Review";

        pageSubtitle =
                "Leave requests currently being reviewed by HR.";

    } else if (statusFilter == LeaveStatus.APPROVED) {

        pageTitle = "Approved Leave Requests";

        pageSubtitle =
                "Leave requests that have been approved.";

    } else if (statusFilter == LeaveStatus.REJECTED) {

        pageTitle = "Rejected Leave Requests";

        pageSubtitle =
                "Leave requests that have been rejected.";

    } else if (statusFilter == LeaveStatus.CANCELLED) {

        pageTitle = "Cancelled Leave Requests";

        pageSubtitle =
                "Leave requests cancelled by employees.";
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= pageTitle %></title>


    <style>

        /* ========================================================
           RESET
           ======================================================== */

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }


        /* ========================================================
           BODY
           ======================================================== */

        body {

            font-family:
                Arial,
                Helvetica,
                sans-serif;

            background: #f3f5f7;

            color: #222;

            min-height: 100vh;

        }


        /* ========================================================
           MAIN PAGE
           ======================================================== */

        .page {

            width: 100%;

            max-width: 1200px;

            margin: 0 auto;

            padding: 35px 25px 50px;

        }


        /* ========================================================
           BACK TO DASHBOARD
           ======================================================== */

        .back-wrapper {

            margin-bottom: 22px;

        }


        .back-dashboard {

            display: inline-flex;

            align-items: center;

            gap: 7px;

            color: #555;

            text-decoration: none;

            font-size: 14px;

            font-weight: 500;

            transition: 0.2s;

        }


        .back-dashboard:hover {

            color: #111;

        }


        /* ========================================================
           PAGE HEADER
           ======================================================== */

        .page-header {

            margin-bottom: 25px;

        }


        .page-header h1 {

            font-size: 30px;

            font-weight: 700;

            color: #111;

            margin-bottom: 7px;

        }


        .page-header p {

            color: #6b7280;

            font-size: 14px;

            line-height: 1.5;

        }


        /* ========================================================
           ALERTS
           ======================================================== */

        .alert {

            padding: 13px 16px;

            border-radius: 8px;

            margin-bottom: 18px;

            font-size: 14px;

        }


        .alert-success {

            background: #e8f7ed;

            color: #1f7a3f;

            border: 1px solid #ccebd6;

        }


        .alert-error {

            background: #fdecea;

            color: #b42318;

            border: 1px solid #f5c7c3;

        }


        /* ========================================================
           FILTER CARD
           ======================================================== */

        .filter-card {

            background: #fff;

            border: 1px solid #e5e7eb;

            border-radius: 14px;

            padding: 20px;

            margin-bottom: 22px;

            box-shadow:
                0 3px 12px
                rgba(0, 0, 0, 0.05);

        }


        .filter-title {

            font-size: 14px;

            font-weight: 600;

            color: #333;

            margin-bottom: 13px;

        }


        /* ========================================================
           STATUS TABS
           ======================================================== */

        .tabs {

            display: flex;

            flex-wrap: wrap;

            gap: 8px;

            margin-bottom: 20px;

        }


        .tab {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 9px 15px;

            border-radius: 7px;

            text-decoration: none;

            font-size: 13px;

            font-weight: 500;

            background: #f0f2f4;

            color: #444;

            border: 1px solid #e1e4e7;

            transition: 0.2s;

        }


        .tab:hover {

            background: #e4e7ea;

            color: #111;

        }


        .tab.active {

            background: #222;

            color: #fff;

            border-color: #222;

        }


        /* ========================================================
           SEARCH FILTERS
           ======================================================== */

        .filters {

            display: grid;

            grid-template-columns:
                repeat(4, 1fr);

            gap: 13px;

            align-items: end;

        }


        .filter-field label {

            display: block;

            font-size: 12px;

            color: #666;

            margin-bottom: 6px;

        }


        input,
        select {

            width: 100%;

            height: 40px;

            padding: 0 11px;

            border: 1px solid #d2d5d8;

            border-radius: 7px;

            background: #fff;

            font-size: 13px;

            color: #333;

            outline: none;

        }


        input:focus,
        select:focus {

            border-color: #777;

        }


        .filter-actions {

            display: flex;

            gap: 8px;

        }


        .btn {

            height: 40px;

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 0 16px;

            border: none;

            border-radius: 7px;

            font-size: 13px;

            font-weight: 500;

            text-decoration: none;

            cursor: pointer;

            transition: 0.2s;

        }


        .btn-primary {

            background: #222;

            color: #fff;

        }


        .btn-primary:hover {

            background: #3a3a3a;

        }


        .btn-reset {

            background: #edf0f2;

            color: #333;

        }


        .btn-reset:hover {

            background: #e0e3e6;

        }


        /* ========================================================
           REQUEST CARD
           ======================================================== */

        .request-card {

            background: #fff;

            border: 1px solid #e5e7eb;

            border-radius: 14px;

            overflow: hidden;

            box-shadow:
                0 3px 14px
                rgba(0, 0, 0, 0.06);

        }


        /* ========================================================
           REQUEST CARD HEADER
           ======================================================== */

        .request-header {

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 15px;

            padding: 20px 22px;

            border-bottom: 1px solid #eee;

        }


        .request-header h2 {

            font-size: 18px;

            color: #111;

        }


        .request-count {

            font-size: 13px;

            color: #777;

        }


        /* ========================================================
           TABLE
           ======================================================== */

        .table-wrapper {

            width: 100%;

            overflow-x: auto;

        }


        table {

            width: 100%;

            border-collapse: collapse;

            min-width: 850px;

        }


        th {

            background: #f8f9fa;

            color: #666;

            font-size: 11px;

            font-weight: 600;

            text-align: left;

            padding: 13px 18px;

            border-bottom: 1px solid #e5e7eb;

            white-space: nowrap;

        }


        td {

            padding: 16px 18px;

            border-bottom: 1px solid #f0f1f2;

            font-size: 13px;

            color: #333;

            vertical-align: middle;

        }


        tbody tr:hover {

            background: #fafafa;

        }


        tbody tr:last-child td {

            border-bottom: none;

        }


        /* ========================================================
           EMPLOYEE
           ======================================================== */

        .employee-name {

            font-weight: 600;

            color: #222;

        }


        .employee-code {

            display: block;

            margin-top: 4px;

            font-size: 11px;

            color: #888;

        }


        /* ========================================================
           DATE
           ======================================================== */

        .date-text {

            white-space: nowrap;

            color: #444;

        }


        /* ========================================================
           STATUS
           ======================================================== */

        .status {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 5px 11px;

            border-radius: 999px;

            font-size: 11px;

            font-weight: 600;

            white-space: nowrap;

        }


        .status-SUBMITTED {

            background: #fff4d6;

            color: #9a6b00;

        }


        .status-UNDER_REVIEW {

            background: #e8f1ff;

            color: #1f5fbf;

        }


        .status-APPROVED {

            background: #e7f7ec;

            color: #1f7a3f;

        }


        .status-REJECTED {

            background: #fdecea;

            color: #b42318;

        }


        .status-CANCELLED {

            background: #f1f3f5;

            color: #5f6368;

        }


        /* ========================================================
           OPEN BUTTON
           ======================================================== */

        .open-btn {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 8px 14px;

            border-radius: 6px;

            background: #222;

            color: #fff;

            text-decoration: none;

            font-size: 12px;

            font-weight: 500;

            transition: 0.2s;

        }


        .open-btn:hover {

            background: #444;

        }


        /* ========================================================
           EMPTY STATE
           ======================================================== */

        .empty-state {

            padding: 65px 25px;

            text-align: center;

        }


        .empty-icon {

            width: 55px;

            height: 55px;

            margin: 0 auto 15px;

            border-radius: 50%;

            background: #f0f2f4;

            display: flex;

            align-items: center;

            justify-content: center;

            font-size: 24px;

        }


        .empty-state h3 {

            margin-bottom: 7px;

            font-size: 17px;

            color: #222;

        }


        .empty-state p {

            color: #777;

            font-size: 13px;

        }


        /* ========================================================
           RESPONSIVE
           ======================================================== */

        @media (max-width: 900px) {

            .filters {

                grid-template-columns:
                    repeat(2, 1fr);

            }

        }


        @media (max-width: 600px) {

            .page {

                padding: 25px 16px 40px;

            }


            .page-header h1 {

                font-size: 25px;

            }


            .filters {

                grid-template-columns: 1fr;

            }


            .filter-actions {

                width: 100%;

            }


            .filter-actions .btn {

                flex: 1;

            }


            .request-header {

                align-items: flex-start;

                flex-direction: column;

            }

        }

    </style>

</head>


<body>


<main class="page">


    <!-- ========================================================
         BACK TO HR DASHBOARD
         ======================================================== -->

    <div class="back-wrapper">

        <a href="<%= request.getContextPath() %>/HrDashboardServlet"
           class="back-dashboard">

            &larr; Back to HR Dashboard

        </a>

    </div>



    <!-- ========================================================
         PAGE HEADER
         ======================================================== -->

    <div class="page-header">

        <h1>

            <%= pageTitle %>

        </h1>


        <p>

            <%= pageSubtitle %>

        </p>

    </div>



    <!-- ========================================================
         ALERTS
         ======================================================== -->

    <% if ("approved".equalsIgnoreCase(success)) { %>

        <div class="alert alert-success">

            Leave request approved successfully.

        </div>

    <% } else if ("rejected".equalsIgnoreCase(success)) { %>

        <div class="alert alert-success">

            Leave request rejected successfully.

        </div>

    <% } else if ("under_review".equalsIgnoreCase(success)) { %>

        <div class="alert alert-success">

            Leave request marked as under review.

        </div>

    <% } %>


    <% if (errorMsg != null && !errorMsg.isBlank()) { %>

        <div class="alert alert-error">

            <%= errorMsg %>

        </div>

    <% } %>



    <!-- ========================================================
         FILTER CARD
         ======================================================== -->

    <div class="filter-card">


        <div class="filter-title">

            Request Status

        </div>


        <div class="tabs">


            <!-- ALL -->

            <a class="tab
               <%= statusFilter == null ? "active" : "" %>"
               href="<%= request.getContextPath() %>/HrLeaveRequestsServlet">

                All

            </a>



            <!-- PENDING / SUBMITTED -->

            <a class="tab
               <%= statusFilter == LeaveStatus.SUBMITTED
                       ? "active"
                       : "" %>"
               href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=SUBMITTED">

                Pending

            </a>



            <!-- UNDER REVIEW -->

            <a class="tab
               <%= statusFilter == LeaveStatus.UNDER_REVIEW
                       ? "active"
                       : "" %>"
               href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=UNDER_REVIEW">

                Under Review

            </a>



            <!-- APPROVED -->

            <a class="tab
               <%= statusFilter == LeaveStatus.APPROVED
                       ? "active"
                       : "" %>"
               href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=APPROVED">

                Approved

            </a>



            <!-- REJECTED -->

            <a class="tab
               <%= statusFilter == LeaveStatus.REJECTED
                       ? "active"
                       : "" %>"
               href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=REJECTED">

                Rejected

            </a>



            <!-- CANCELLED -->

            <a class="tab
               <%= statusFilter == LeaveStatus.CANCELLED
                       ? "active"
                       : "" %>"
               href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?status=CANCELLED">

                Cancelled

            </a>


        </div>



        <!-- ====================================================
             SEARCH / FILTER
             ==================================================== -->

        <form class="filters"
              method="get"
              action="<%= request.getContextPath() %>/HrLeaveRequestsServlet">


            <!-- KEEP CURRENT STATUS -->

            <% if (statusFilter != null) { %>

                <input type="hidden"
                       name="status"
                       value="<%= statusFilter.name() %>">

            <% } %>



            <!-- SEARCH EMPLOYEE -->

            <div class="filter-field">

                <label for="search">

                    Employee

                </label>


                <input type="text"
                       name="search"
                       id="search"
                       value="<%= employeeSearch != null
                               ? employeeSearch
                               : "" %>"
                       placeholder="Name or employee code">

            </div>



            <!-- LEAVE TYPE -->

            <div class="filter-field">

                <label for="leaveTypeId">

                    Leave Type

                </label>


                <select name="leaveTypeId"
                        id="leaveTypeId">


                    <option value="">

                        All types

                    </option>


                    <% if (leaveTypes != null) {

                        for (LeaveType type : leaveTypes) {
                    %>


                        <option value="<%= type.getLeaveTypeId() %>"
                            <%= type.getLeaveTypeId()
                                    == (leaveTypeIdFilter != null
                                    ? leaveTypeIdFilter
                                    : -1)
                                    ? "selected"
                                    : "" %>>

                            <%= type.getDisplayName() %>

                        </option>


                    <%
                        }

                    }
                    %>


                </select>

            </div>



            <!-- FROM DATE -->

            <div class="filter-field">

                <label for="fromDate">

                    From Date

                </label>


                <input type="date"
                       name="fromDate"
                       id="fromDate"
                       value="<%= fromDate != null
                               ? fromDate
                               : "" %>">

            </div>



            <!-- TO DATE -->

            <div class="filter-field">

                <label for="toDate">

                    To Date

                </label>


                <input type="date"
                       name="toDate"
                       id="toDate"
                       value="<%= toDate != null
                               ? toDate
                               : "" %>">

            </div>



            <!-- BUTTONS -->

            <div class="filter-actions">


                <button type="submit"
                        class="btn btn-primary">

                    Apply Filters

                </button>


                <a href="<%= request.getContextPath() %>/HrLeaveRequestsServlet"
                   class="btn btn-reset">

                    Reset

                </a>


            </div>


        </form>


    </div>



    <!-- ========================================================
         REQUEST LIST
         ======================================================== -->

    <div class="request-card">


        <!-- HEADER -->

        <div class="request-header">

            <h2>

                <%= pageTitle %>

            </h2>


            <span class="request-count">

                <%= leaveRequests == null
                        ? 0
                        : leaveRequests.size() %>

                request<%= leaveRequests != null
                        && leaveRequests.size() == 1
                        ? ""
                        : "s" %>

            </span>

        </div>



        <!-- ====================================================
             EMPTY
             ==================================================== -->

        <% if (leaveRequests == null ||
                leaveRequests.isEmpty()) {
        %>


            <div class="empty-state">

                <div class="empty-icon">

                    &#128203;

                </div>


                <h3>

                    No Leave Requests Found

                </h3>


                <p>

                    There are no leave requests matching
                    the selected filters.

                </p>

            </div>


        <% } else { %>


            <!-- =================================================
                 TABLE
                 ================================================= -->

            <div class="table-wrapper">

                <table>


                    <thead>

                        <tr>

                            <th>
                                EMPLOYEE
                            </th>

                            <th>
                                LEAVE TYPE
                            </th>

                            <th>
                                DATES
                            </th>

                            <th>
                                DAYS
                            </th>

                            <th>
                                STATUS
                            </th>

                            <th>
                                ACTION
                            </th>

                        </tr>

                    </thead>



                    <tbody>


                    <% for (Leave leave : leaveRequests) { %>


                        <tr>


                            <!-- EMPLOYEE -->

                            <td>

                                <span class="employee-name">

                                    <%= leave.getEmployeeName() %>

                                </span>


                                <% if (leave.getEmpCode() != null) { %>

                                    <span class="employee-code">

                                        <%= leave.getEmpCode() %>

                                    </span>

                                <% } %>

                            </td>



                            <!-- LEAVE TYPE -->

                            <td>

                                <%= leave.getLeaveType().getDisplayName() %>

                            </td>



                            <!-- DATES -->

                            <td class="date-text">

                                <%= leave.getFromDate()
                                        .format(dateFmt) %>


                                <% if (!leave.getFromDate()
                                        .equals(leave.getToDate())) { %>


                                    -

                                    <%= leave.getToDate()
                                            .format(dateFmt) %>


                                <% } %>

                            </td>



                            <!-- DAYS -->

                            <td>

                                <%= leave.getNumDays() %>

                            </td>



                            <!-- STATUS -->

                            <td>

                                <span class="status
                                    status-<%= leave.getStatus().name() %>">

                                    <%= leave.getStatus()
                                            .getDisplayName() %>

                                </span>

                            </td>



                            <!-- OPEN -->

                            <td>

                                <a class="open-btn"
                                   href="<%= request.getContextPath() %>/HrLeaveRequestsServlet?id=<%= leave.getLeaveId() %>">

                                    Open

                                </a>

                            </td>


                        </tr>


                    <% } %>


                    </tbody>


                </table>

            </div>


        <% } %>


    </div>


</main>


</body>

</html>