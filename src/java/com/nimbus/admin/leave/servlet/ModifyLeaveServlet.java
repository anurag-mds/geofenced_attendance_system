//This servlet handles employee requests to update a leave application
//that is still in the SUBMITTED state.
//It enforces employee-only access and delegates all business rules
//(date validation, overlap checks, status transitions) to LeaveService
//so the workflow cannot be bypassed from the browser.

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
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet("/ModifyLeaveServlet")
public class ModifyLeaveServlet extends HttpServlet {

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
            int leaveTypeId = Integer.parseInt(request.getParameter("leaveTypeId"));
            LocalDate fromDate = LocalDate.parse(request.getParameter("fromDate"));
            LocalDate toDate = LocalDate.parse(request.getParameter("toDate"));
            String reason = request.getParameter("reason");

            leaveService.modifyLeave(employee.getEmpId(), leaveId, leaveTypeId,
                    fromDate, toDate, reason);

            response.sendRedirect(request.getContextPath()
                    + "/LeaveHistoryServlet?id=" + leaveId + "&success=modified");

        } catch (NumberFormatException | DateTimeParseException e) {
            redirectWithError(response, request, "Invalid leave request data.");
        } catch (LeaveServiceException e) {
            redirectWithError(response, request, e.getMessage());
        }
    }

    private void redirectWithError(HttpServletResponse response,
            HttpServletRequest request, String message) throws IOException {
        String leaveId = request.getParameter("leaveId");
        String target = request.getContextPath() + "/LeaveHistoryServlet";
        if (leaveId != null && !leaveId.isBlank()) {
            target += "?id=" + leaveId;
        }
        target += (target.contains("?") ? "&" : "?")
                + "error=" + URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(target);
    }
}
