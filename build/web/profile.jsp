<%-- 
    Document   : profile
    Created on : 08-Aug-2026, 3:44:31 pm
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.nimbus.admin.model.Employee" %>

<% // Get the logged-in employee from the session
    Employee employee =
        (Employee) session.getAttribute("employee"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Employee Profile</title>
    </head>
    <style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    body {
        font-family: Arial, sans-serif;
        background: #f5f7fa;
        color: #222;
    }

    /* Main profile container */
    .profile-container {
        width: 85%;
        max-width: 950px;
        margin: 50px auto;
    }

    /* Header */
    .profile-header {
        margin-bottom: 25px;
    }

    .profile-header h1 {
        font-size: 28px;
        margin-bottom: 6px;
        color: #222;
    }

    .profile-header p {
        color: #777;
        font-size: 14px;
    }

    /* Profile card */
    .profile-card {
        background: white;
        border-radius: 12px;
        padding: 35px;
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.08);
    }

    /* Profile title */
    .profile-title {
        display: flex;
        align-items: center;
        gap: 15px;
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 1px solid #e5e5e5;
    }

    /* Avatar */
    .profile-avatar {
        width: 55px;
        height: 55px;
        border-radius: 50%;
        background: #222;
        color: white;

        display: flex;
        align-items: center;
        justify-content: center;

        font-size: 22px;
        font-weight: bold;
    }

    .profile-title h2 {
        font-size: 21px;
        margin-bottom: 4px;
    }

    .profile-title span {
        font-size: 13px;
        color: #777;
    }

    /* Information grid */
    .info-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 18px;
    }

    /* Individual information box */
    .info-box {
        background: #f8f9fb;
        border: 1px solid #e8e8e8;
        border-radius: 8px;
        padding: 18px 20px;
        transition: 0.2s;
    }

    .info-box:hover {
        background: #f2f4f7;
        border-color: #d8d8d8;
    }

    .info-label {
        display: block;
        font-size: 12px;
        color: #777;
        margin-bottom: 7px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .info-value {
        font-size: 16px;
        color: #222;
        font-weight: 500;
    }

    /* Responsive */
    @media (max-width: 700px) {

        .profile-container {
            width: 92%;
            margin: 30px auto;
        }

        .profile-card {
            padding: 25px;
        }

        .info-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<body>

    <div class="profile-container">

        <div class="profile-header">
            <h1>My Profile</h1>
        </div>

        <div class="profile-card">

            <div class="profile-title">

                <div class="profile-avatar">
                    <%= employee.getFullName().substring(0, 1).toUpperCase() %>
                </div>

                <div>
                    <h2><%= employee.getFullName() %></h2>
                    <span><%= employee.getDesignation() %></span>
                </div>

            </div>


            <div class="info-grid">

                <div class="info-box">
                    <span class="info-label">Employee Code</span>
                    <div class="info-value">
                        <%= employee.getEmpCode() %>
                    </div>
                </div>


                <div class="info-box">
                    <span class="info-label">Full Name</span>
                    <div class="info-value">
                        <%= employee.getFullName() %>
                    </div>
                </div>


                <div class="info-box">
                    <span class="info-label">Email</span>
                    <div class="info-value">
                        <%= employee.getEmail() %>
                    </div>
                </div>


                <div class="info-box">
                    <span class="info-label">Designation</span>
                    <div class="info-value">
                        <%= employee.getDesignation() %>
                    </div>
                </div>


                <div class="info-box">
                    <span class="info-label">Role</span>
                    <div class="info-value">
                        <%= employee.getRole() %>
                    </div>
                </div>


                <div class="info-box">
                    <span class="info-label">Employment Status</span>
                    <div class="info-value">
                        <%= employee.getEmploymentStatus() %>
                    </div>
                </div>

            </div>

        </div>

    </div>

</body>