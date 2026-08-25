package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/EmployeeLeaveMenuServlet")
public class EmployeeLeaveMenuServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }


        Employee employee =
                (Employee) session.getAttribute("employee");


        if (employee == null
                || employee.getRole() != Role.EMPLOYEE) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.html"
            );

            return;
        }


        request.getRequestDispatcher(
                "/WEB-INF/jsp/leave/employee-leave-menu.jsp"
        ).forward(request, response);
    }
}