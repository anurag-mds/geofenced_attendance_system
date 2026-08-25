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


    String error =
            (String) request.getAttribute("error");


    String today =
            (String) request.getAttribute("today");


    if (today == null || today.isBlank()) {

        today =
                java.time.LocalDate.now().toString();
    }
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

            max-width: 850px;

            margin: 0 auto;

        }


        .card {

            background: #fff;

            border-radius: 12px;

            padding: 32px;

            box-shadow:
                0 3px 12px
                rgba(0, 0, 0, 0.07);

        }


        h1 {

            margin: 0 0 8px 0;

            font-size: 30px;

            color: #111;

        }


        .subtitle {

            color: #666;

            margin: 0 0 28px 0;

            font-size: 15px;

            line-height: 1.5;

        }


        /* =====================================================
           ERROR
           ===================================================== */

        .error {

            background: #f8f8f8;

            color: #333;

            border-left: 4px solid #555;

            padding: 12px 15px;

            border-radius: 5px;

            margin-bottom: 22px;

        }


        /* =====================================================
           FORM
           ===================================================== */

        .form-row {

            display: flex;

            gap: 20px;

        }


        .form-group {

            flex: 1;

        }


        label {

            display: block;

            font-weight: 600;

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


        .date-note {

            margin-top: 8px;

            font-size: 12px;

            color: #777;

        }


        /* =====================================================
           BUTTON
           ===================================================== */

        .apply-btn {

            margin-top: 25px;

            padding: 12px 22px;

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


        /* =====================================================
           BACK LINK
           ===================================================== */

        .back-link {

            display: inline-block;

            margin-top: 22px;

            color: #444;

            text-decoration: none;

            font-size: 14px;

        }


        .back-link:hover {

            text-decoration: underline;

        }


        /* =====================================================
           MOBILE
           ===================================================== */

        @media (max-width: 700px) {

            .page-content {

                padding: 20px;

            }


            .card {

                padding: 22px;

            }


            .form-row {

                flex-direction: column;

                gap: 15px;

            }


            h1 {

                font-size: 25px;

            }

        }

    </style>

</head>


<body>


    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>


    <div class="page-content">

        <div class="container">


            <div class="card">


                <h1>
                    Work From Home
                </h1>


                <p class="subtitle">

                    Select the dates for which you would
                    like to work from home.

                    Your request will be sent for approval.

                </p>


                <% if (error != null) { %>

                    <div class="error">

                        <%= error %>

                    </div>

                <% } %>


                <form method="post"
                      action="<%= request.getContextPath() %>/ApplyRemoteWorkServlet">


                    <div class="form-row">


                        <!-- START DATE -->

                        <div class="form-group">

                            <label for="startDate">
                                Start Date
                            </label>


                            <input type="date"
                                   id="startDate"
                                   name="startDate"
                                   min="<%= today %>"
                                   required>


                            <div class="date-note">
                                You can select today or a future date.
                            </div>

                        </div>


                        <!-- END DATE -->

                        <div class="form-group">

                            <label for="endDate">
                                End Date
                            </label>


                            <input type="date"
                                   id="endDate"
                                   name="endDate"
                                   min="<%= today %>"
                                   required>


                            <div class="date-note">
                                End date cannot be before start date.
                            </div>

                        </div>


                    </div>


                    <button type="submit"
                            class="apply-btn">

                        Apply for Work From Home

                    </button>


                </form>


                <a href="<%= request.getContextPath() %>/EmployeeLeaveMenuServlet"
                   class="back-link">

                    &larr; Back to Leave

                </a>


            </div>


        </div>

    </div>


    <!-- =====================================================
         DATE VALIDATION
         ===================================================== -->

    <script>

        const startDate =
                document.getElementById("startDate");

        const endDate =
                document.getElementById("endDate");


        startDate.addEventListener(
                "change",
                function() {

                    endDate.min =
                            startDate.value;

                }
        );

    </script>


</body>

</html>