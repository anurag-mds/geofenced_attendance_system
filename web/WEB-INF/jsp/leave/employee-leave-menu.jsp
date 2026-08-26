<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave and Work From Home</title>
    <%@ include file="/WEB-INF/jsp/common/nav-styles.jsp" %>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            background: var(--app-bg, #f2f4f7);
            color: var(--app-text, #1f2937);
            font-family: var(--app-font, Georgia, 'Times New Roman', serif);
        }
        .page-content { padding: 38px 24px 48px; }
        .container { max-width: 1100px; margin: 0 auto; }
        .header { margin-bottom: 28px; }
        h1 {
            margin: 0 0 10px;
            font-size: clamp(2.1rem, 3vw, 3.2rem);
            line-height: 1.15;
            font-weight: 700;
            letter-spacing: -0.04em;
        }
        .header p {
            margin: 0;
            color: #4b5563;
            font-size: 1.05rem;
        }
        .options {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 22px;
        }
        .option {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 220px;
            padding: 30px 28px 22px;
            border-radius: 14px;
            background: #fff;
            color: inherit;
            text-decoration: none;
            box-shadow: 0 2px 10px rgba(15, 23, 42, 0.06);
            border: 1px solid rgba(148, 163, 184, 0.2);
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
        }
        .option:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.10);
            border-color: rgba(100, 116, 139, 0.25);
        }
        .option h2 {
            margin: 0 0 10px;
            font-size: clamp(1.5rem, 2vw, 2rem);
            line-height: 1.2;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .option p {
            margin: 0;
            color: #4b5563;
            line-height: 1.5;
            font-size: 1rem;
        }
        .open {
            margin-top: 26px;
            font-size: 1rem;
            font-weight: 700;
            color: #111827;
        }
        @media (max-width: 700px) {
            .page-content { padding: 20px 18px 28px; }
            .options { grid-template-columns: 1fr; }
            .option { min-height: 180px; }
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/jsp/common/app-nav.jsp" %>
    <main class="page-content">
        <div class="container">
            <header class="header">
                <h1>Leave and Work From Home</h1>
                <p>Choose what you would like to manage.</p>
            </header>
            <div class="options">
                <a class="option" href="<%= request.getContextPath() %>/ApplyLeaveServlet"><div><h2>Apply Leave</h2><p>Submit a new leave request.</p></div><span class="open">Open &rarr;</span></a>
                <a class="option" href="<%= request.getContextPath() %>/LeaveHistoryServlet"><div><h2>Leave History</h2><p>View your previous and current leave requests.</p></div><span class="open">Open &rarr;</span></a>
                <a class="option" href="<%= request.getContextPath() %>/ApplyRemoteWorkServlet"><div><h2>Work From Home</h2><p>Submit a new work from home request.</p></div><span class="open">Open &rarr;</span></a>
                <a class="option" href="<%= request.getContextPath() %>/RemoteWorkHistoryServlet"><div><h2>Work From Home History</h2><p>View your previous and current WFH requests.</p></div><span class="open">Open &rarr;</span></a>
            </div>
        </div>
    </main>
</body>
</html>
