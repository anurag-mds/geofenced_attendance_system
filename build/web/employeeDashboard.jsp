
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>

<%
    // Get the logged-in employee from the session
    Employee employee =
        (Employee) session.getAttribute("employee");

    // If there is no employee in the session,
    // send the user back to the login page
    if (employee == null) {
        response.sendRedirect("login.html");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Employee Dashboard</title>

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, sans-serif;
            background-color: #f2f4f7;
        }

        /* Top navigation */

        .navbar {
            background-color: #222;
            color: white;

            padding: 18px 30px;

            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h2 {
            font-size: 22px;
        }

        .logout-button {
            background-color: #e74c3c;
            color: white;

            padding: 9px 16px;

            border: none;
            border-radius: 5px;

            text-decoration: none;
        }

        .logout-button:hover {
            background-color: #c0392b;
        }

        

        /* Collapsible Sidebar  */
        .sidebar{
            position: fixed;
            top: 70px;
            left: 0;
            width:230px;
            height: calc(100vh - 70px);
            
            background-color : #ffffff;
            border-right: 1px solid #ddd;
            padding: 25px 15px;
            
            transform: translate(-100%);
            transition: transform 0.3s ease;
            
            z-index: 1000;
            
        }
        /* Sidebar OPEN */

        .sidebar.open {
            transform: translateX(0);
        }

        .sidebar-title{
            font-size:13px;
            color: #888;
            
            text-transform: uppercase;
            margin-bottom:15px;
            padding-left: 12px;
        }
        
        
        .sidebar a{
            display: flex;
            align-items: center;
            gap:12px;
            padding: 14px 12px;
            
            margin-bottom: 6px;
            border-radius: 7px;
            text-decoration: none;
            color: #333;
            font-size: 15px;
            transition: 0.2s;
        }
        
        .sidebar a:hover {
        background-color: #f0f2f5;
    }

    
         /* Menu Button */
         .menu-button {
            background: none;
            border: none;
            color: white;
            font-size: 27px;
            cursor: pointer;
            margin-right: 15px;
            padding: 5px 8px;
            }

         .menu-button:hover {
            opacity: 0.8;
          }
          
          /* NAVBAR LEFT SECTION */

            .navbar-left {
                display: flex;
                align-items: center;
            }
          
         /* Main dashboard */
        .dashboard {
            margin-left: 0;
            padding: 30px;
            transition: margin-left 0.3s ease;
        }
        
        /* Move dashboard when sidebar opens */
        .dashboard.sidebar-open {
             margin-left: 230px;
            }
            
        .welcome {
            margin-bottom: 30px;
        }

        .welcome h1 {
            color: #222;
            margin-bottom: 8px;
            font-size: 28px;
        }

        .welcome p {
            color: #666;
        } 
        @media (max-width: 1000px){
            .sidebar{
                width: 250px;
            }
            .dashboard{
                margin-left : 190px;
                padding: 25px;
            }
            .navbar {
            padding: 0 20px;
            }
        }
        
        
        /* Summary  Cards */
        
        .summary-cards{
            display: grid;
            grid-template-columns: repeat(4,1fr);
            gap: 20px;
            margin-bottom: 25px;
        }
        .summary-card{
            background-color: white;
            padding:22px;
            border-radius: 10px;
            
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
            
            border-left: 5px solid #333;
        }
        
        .summary-card .card-title{
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .summary-card .card-number{
            font-size: 28px;
            font-weight: bold;
            color:#222;
        }
        .summary-card .card-subtext {
            margin-top: 6px;
            font-size: 13px;
            color: #888;
        }
        
        .summary-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .summary-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 8px 18px rgba(0, 0, 0, 0.18);
        }
        
        
        /* chart section */
        
        .chart-section {
         display: grid;
         grid-template-columns: 1fr 1.4fr;
         gap: 25px;
         margin-bottom: 25px;
        }

        .chart-box {
          background-color: white;
          padding: 25px;
          border-radius: 10px;

          box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }

        .chart-box h2 {
          font-size: 18px;
          color: #222;
          margin-bottom: 5px;
        }

       .chart-box .chart-description {
          color: #777;
          font-size: 13px;
          margin-bottom: 20px;
         }
 
         /* pie chart */
         
         .pie-chart{
             width: 220px;
             height: 220px;
             
             border-radius: 50%;
             
             margin: 20px auto;
             
             background:
                 conic-gradient(
                    #4caf50 0deg 270deg,
                    #e74c3c 270deg 310deg,
                    #f1c40f 310deg 330deg,
                    #9b59b6 330deg 360deg
                 );
         }
         .legend {
           display: flex;
           flex-direction: column;
           gap: 8px;
        }

         .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;

            font-size: 14px;
}

        .legend-color {
            width: 12px;
            height: 12px;
            border-radius: 3px;
        }
        
        /* LINE CHART */

        .line-chart {
            width: 100%;
            height: 280px;
            margin-top: 15px;
        }

        .line-chart svg {
            width: 100%;
            height: 100%;
            overflow: visible;
            }

        .grid-line {
          stroke: #444;
             stroke-width: 1;
        }

        .chart-line {
             fill: none;
            stroke: #4caf50;
            stroke-width: 3;
        }

        .chart-point {
            fill: #4caf50;
            stroke: #ffffff;
            stroke-width: 2;
        }

        .chart-value {
            fill: #ffffff;
            font-size: 12px;
            text-anchor: middle;
        }

        .chart-week {
            fill: #999;
            font-size: 12px;
            text-anchor: middle;
            }
          

    
        /*RESPONSIVE */
        
        @media (max-width: 1000px) {

            .summary-cards {
                    grid-template-columns: repeat(2, 1fr);
                }

            .chart-section {
                     grid-template-columns: 1fr;
            }
        }

        @media (max-width: 600px) {

            .summary-cards {
                    grid-template-columns: 1fr;
            }
        }

    </style>
</head>
<body>

    <!-- Navigation Bar -->
    <div class="navbar">
        <div class="navbar-left">
            <button class="menu-button" onclick="toggleSidebar()">
                 ☰
            </button>
                <h2>Employee Attendance System</h2>
        </div> 
        <a href="LogoutServlet" class="logout-button">
            Logout
        </a>

    </div>
    
    <!-- SideBar -->
       <div class="sidebar" id="sidebar">
                <div class="sidebar-title">
                    Employee Menu
                </div>
                
            <a href="#">

                <h3>📅 Attendance</h3>
            </a>
                
            <a href="#">

                <h3>🏖  Leave</h3>
            </a>
                
            <a href="#">

                <h3>📝 Permission</h3>
            </a>    
                
            <a href="ProfileServlet">

                <h3>👤 My Profile</h3>
            </a>      
        </div>

    <!-- Dashboard -->
    <div class="dashboard">
        <!-- Welcome message -->
        <div class="welcome">
            <h1>
                Welcome, <%= employee.getFullName() %>!
            </h1>
            <p>
                Here's today's attendance overview.
            </p>
        </div>
            
            <!-- Summary Cards -->
            
            <div class="summary-cards">
                <div class="summary-card">
                    <div class="card-title">
                        👥 Total Employees
                    </div>
                    <div class="card-number">
                         52
                    </div>

                    <div class="card-subtext">
                      Active employees
                    </div>
                </div>
                <div class="summary-card">

                    <div class="card-title">
                         🟢 Present Today
                    </div>

                    <div class="card-number">
                       43
                    </div>

                    <div class="card-subtext">
                         Employees present
                    </div>
                </div>
                <div class="summary-card">

                    <div class="card-title">
                      🔴 Absent Today
                    </div>

                    <div class="card-number">
                         6
                    </div>

                    <div class="card-subtext">
                         Employees absent
                    </div>

                </div>              
                <div class="summary-card">

                    <div class="card-title">
                        ⏰ Late / Half Day
                    </div>

                    <div class="card-number">
                        3
                    </div>
                    
                    <div class="card-subtext">
                        2 Late • 1 Half Day
                    </div>
                </div>

            </div>
            
            <!-- Charts -->
            
            <div class="chart-section">
                <!-- pie chart -->
                
                <div class="chart-box">
                    <h2>Today's Attendance</h2>
                    <p class="chart-description">
                        Attendence description for today
                    </p>
                    <div class="pie-chart"></div>
                    <div class="legend">

                        <div class="legend-item">
                            <span class="legend-color"
                                style="background:#4caf50;">
                            </span>
                        Present — 43
                        </div>  
                        
                        <div class="legend-item">
                            <span class="legend-color"
                                style="background:#e74c3c;">
                            </span>
                        Absent — 6
                        </div> 
                       
                        <div class="legend-item">
                            <span class="legend-color"
                                style="background:#f1c40f;">
                            </span>

                        Late — 2
                        </div>

                        <div class="legend-item">
                            <span class="legend-color"
                                style="background:#9b59b6;">
                            </span>

                        Half Day — 1
                        </div>
                    
                    </div>
                </div>    
            
            
            <!-- Attendance trend -->
                <div class="chart-box">
                    <h2>Weekly Attendance Trend</h2>
                    
                    <p class="chart-description">
                        Overall attendance percentage by week
                    </p>
                    
                    <div class="line-chart">
                        <svg viewBox="0 0 600 280">
                        <!-- Horizontal Grid Lines -->
                        
                            <line x1="60" y1="30"
                            x2="570" y2="30"
                            class="grid-line"/>

                            <line x1="60" y1="80"
                            x2="570" y2="80"
                            class="grid-line"/>

                            <line x1="60" y1="130"
                            x2="570" y2="130"
                            class="grid-line"/>

                            <line x1="60" y1="180"
                            x2="570" y2="180"
                            class="grid-line"/>

                            <line x1="60" y1="230"
                            x2="570" y2="230"
                            class="grid-line"/>            
                            
                            
                            <!-- Y axis labels -->
                    
                                <text x="45" y="35"
                                    class="chart-value">
                                    100%
                                </text>

                                <text x="45" y="85"
                                    class="chart-value">
                                    95%
                                </text>

                                <text x="45" y="135"
                                    class="chart-value">
                                    90%
                                </text>

                                <text x="45" y="185"
                                    class="chart-value">
                                    85%
                                </text>

                                <text x="45" y="235"
                                    class="chart-value">
                                    80%
                                </text>
                                
                                <!-- Attendance line -->
                                <polyline 
                                    points="90,230,250,160,410,100,550,150"
                                    class="chart-line"
                                />
                                
                                <!--Points-->
                                
                                    <circle 
                                        cx="90"
                                        cy="230"
                                        r="6"
                                        class="chart-point"
                                    />
                                
                                    <circle
                                       cx="250"
                                        cy="160"
                                        r="6"
                                        class="chart-point"
                                    />
                                    <circle
                                        cx="410"
                                        cy="100"
                                        r="6"
                                        class="chart-point"
                                    />

                                    <circle
                                        cx="550"
                                        cy="150"
                                        r="6"
                                        class="chart-point"
                                    />
                                <!-- Values -->

                                    <text x="90" y="212"
                                        class="chart-value">
                                        80%
                                    </text>

                                    <text x="250" y="142"
                                        class="chart-value">
                                        87%
                                    </text>

                                    <text x="410" y="82"
                                        class="chart-value">
                                        91%
                                    </text>

                                    <text x="550" y="132"
                                        class="chart-value">
                                        86%
                                    </text>


                                <!-- Week labels -->

                                    <text x="90" y="260"
                                            class="chart-week">
                                                 Week 1
                                    </text>

                                    <text x="250" y="260"
                                            class="chart-week">
                                            Week 2
                                    </text>

                                    <text x="410" y="260"
                                            class="chart-week">
                                            Week 3
                                    </text>

                                    <text x="550" y="260"
                                            class="chart-week">
                                            Week 4
                                    </text>

                        </svg>        
                    </div>
                </div>
            </div>        
    </div>
            
    <script>
      function toggleSidebar() {

         const sidebar = document.getElementById("sidebar");
         const dashboard = document.querySelector(".dashboard");

         sidebar.classList.toggle("open");
         dashboard.classList.toggle("sidebar-open");
     }
    </script>          
</body>
</html>