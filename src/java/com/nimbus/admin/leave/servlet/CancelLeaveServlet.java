//This servlet lets an employee cancel a leave request while it is still
//in the SUBMITTED state. The record is marked CANCELLED instead of deleted
//so leave history remains auditable and traceable in the database.

package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.leave.service.LeaveService;
import com.nimbus.admin.leave.service.LeaveServiceException;
import com.nimbus.admin.leave.service.LeaveServiceImpl;
import com.nimbus.admin.leave.util.LeaveAuthUtil;
import com.nimbus.admin.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/CancelLeaveServlet")
public class CancelLeaveServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Employee employee = LeaveAuthUtil.requireEmployeeRole(request, response);
        if (employee == null) {
            return;
        }

        try {
            int leaveId = Integer.parseInt(request.getParameter("leaveId"));
            leaveService.cancelLeave(employee.getEmpId(), leaveId);
            response.sendRedirect(request.getContextPath()
                    + "/LeaveHistoryServlet?success=cancelled");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath()
                    + "/LeaveHistoryServlet?error=invalid");

        } catch (LeaveServiceException e) {
            response.sendRedirect(request.getContextPath()
                    + "/LeaveHistoryServlet?error="
                    + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }
}
