/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.LoginDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import java.io.IOException;
//import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author Kanaka Jadhav
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

         System.out.println("========== LOGIN SERVLET CALLED ==========");

    String empCode = request.getParameter("empCode");
    String password = request.getParameter("password");

    System.out.println("Emp Code: " + empCode);
    System.out.println("Password: " + password);



        // Create LoginDAO object
        LoginDAO loginDAO = new LoginDAO();

        // Ask DAO to check the credentials
        Employee employee = loginDAO.login(empCode, password);

        // Check whether login was successful
        if (employee != null) {

            // Create a session for the logged-in employee
            HttpSession session = request.getSession();

            // Store employee information in the session
            session.setAttribute("employee", employee);

            // Check the employee's role
            if (employee.getRole() == Role.ADMIN) {

                response.sendRedirect("adminDashboard.jsp");

            } else if (employee.getRole() == Role.HR) {

                response.sendRedirect("hrDashboard.jsp");

            } else if (employee.getRole() == Role.EMPLOYEE) {

                response.sendRedirect("employeeDashboard.jsp");
            }

        } else {

            // Login failed
         

    response.sendRedirect(
        request.getContextPath() + "/index.html?error=invalid"
    );
}
    }
}