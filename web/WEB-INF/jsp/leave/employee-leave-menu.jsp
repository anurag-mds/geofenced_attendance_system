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
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Leave & Work From Home</title>

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


        .leave-container {

            max-width: 1000px;

            margin: 0 auto;

        }


        .page-header {

            margin-bottom: 30px;

        }


        .page-header h1 {

            margin: 0 0 8px 0;

            font-size: 30px;

            color: #111;

        }


        .page-header p {

            margin: 0;

            color: #666;

            font-size: 15px;

        }


        /* =====================================================
           FOUR CARDS
           ===================================================== */

        .leave-grid {

            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 22px;

        }


        .leave-card {

            background: #fff;

            border-radius: 12px;

            padding: 28px;

            min-height: 190px;

            text-decoration: none;

            color: #222;

            box-shadow:
                0 3px 12px
                rgba(0, 0, 0, 0.07);

            transition:
                transform 0.2s ease,
                box-shadow 0.2s ease;

            display: flex;

            flex-direction: column;

            justify-content: space-between;

        }


        .leave-card:hover {

            transform: translateY(-3px);

            box-shadow:
                0 7px 20px
                rgba(0, 0, 0, 0.10);

        }


        


        .leave-card h2 {

            margin: 0 0 8px 0;

            font-size: 20px;

            color: #111;

        }


        .leave-card p {

            margin: 0;

            color: #777;

            font-size: 14px;

            line-height: 1.5;

        }


        .card-arrow {

            margin-top: 22px;

            font-size: 14px;

            font-weight: 600;

            color: #333;

        }


        @media (max-width: 700px) {

            .page-content {

                padding: 20px;

            }


            .leave-grid {

                grid-template-columns: 1fr;

            }


            .page-header h1 {

                font-size: 25px;

            }

        }

    </style>

</head>


<body>

    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>


    <div class="page-content">

        <div class="leave-container">


            <div class="page-header">

                <h1>
                    Leave & Work From Home
                </h1>

                <p>
                    Choose what you would like to manage.
                </p>

            </div>


            <div class="leave-grid">


                <!-- =================================================
                     APPLY LEAVE
                     ================================================= -->

                <a href="<%= request.getContextPath() %>/ApplyLeaveServlet"
                   class="leave-card">

                    <div>

                   

                        <h2>
                            Apply Leave
                        </h2>

                        <p>
                            Submit a new leave request.
                        </p>

                    </div>

                    <div class="card-arrow">
                        Open &rarr;
                    </div>

                </a>


                <!-- =================================================
                     LEAVE HISTORY
                     ================================================= -->

                <a href="<%= request.getContextPath() %>/LeaveHistoryServlet"
                   class="leave-card">

                    <div>

                        

                        <h2>
                            Leave History
                        </h2>

                        <p>
                            View your previous and current
                            leave requests.
                        </p>

                    </div>

                    <div class="card-arrow">
                        Open &rarr;
                    </div>

                </a>


                <!-- =================================================
                     WORK FROM HOME
                     ================================================= -->

                <a href="<%= request.getContextPath() %>/ApplyRemoteWorkServlet"
                   class="leave-card">

                    <div>

                      

                        <h2>
                            Work From Home
                        </h2>

                        <p>
                            Submit a new work from home request.
                        </p>

                    </div>

                    <div class="card-arrow">
                        Open &rarr;
                    </div>

                </a>


                <!-- =================================================
                     WFH HISTORY
                     ================================================= -->

                <a href="<%= request.getContextPath() %>/RemoteWorkHistoryServlet"
                   class="leave-card">

                    <div>

                      

                        <h2>
                            Work From Home History
                        </h2>

                        <p>
                            View your previous and current
                            WFH requests.
                        </p>

                    </div>

                    <div class="card-arrow">
                        Open &rarr;
                    </div>

                </a>


            </div>

        </div>

    </div>

</body>

</html>