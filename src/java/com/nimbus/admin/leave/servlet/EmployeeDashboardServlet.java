//This servlet loads leave summary data for the employee dashboard.
//It attaches balance and recent request information before forwarding to
//employeeDashboard.jsp so employees see leave status without extra navigation.

package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.leave.model.LeaveBalance;
import com.nimbus.admin.leave.service.LeaveService;
import com.nimbus.admin.leave.service.LeaveServiceImpl;
import com.nimbus.admin.leave.util.LeaveAuthUtil;
import com.nimbus.admin.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/EmployeeDashboardServlet")
public class EmployeeDashboardServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Employee employee = LeaveAuthUtil.requireEmployeeRole(request, response);
        if (employee == null) {
            return;
        }

        LeaveBalance balance = leaveService.getLeaveBalance(employee.getEmpId());
        request.setAttribute("leaveBalance", balance);
        request.setAttribute("recentLeaves",
                leaveService.getRecentLeaveRequests(employee.getEmpId(), 3));

        request.getRequestDispatcher("/employeeDashboard.jsp")
                .forward(request, response);
    }
}
