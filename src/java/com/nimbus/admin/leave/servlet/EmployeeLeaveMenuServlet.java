package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.leave.util.LeaveAuthUtil;
import com.nimbus.admin.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/EmployeeLeaveMenuServlet")
public class EmployeeLeaveMenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Employee employee = LeaveAuthUtil.requireEmployeeRole(request, response);
        if (employee == null) {
            return;
        }
        request.getRequestDispatcher("/WEB-INF/jsp/leave/employee-leave-menu.jsp")
                .forward(request, response);
    }
}
