//This servlet displays an employee's own leave history and request details.
//It never exposes another employee's records and relies on LeaveService to
//enforce ownership checks before showing or filtering leave information.

package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveStatus;
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
import java.util.List;

@WebServlet("/LeaveHistoryServlet")
public class LeaveHistoryServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Employee employee = LeaveAuthUtil.requireEmployeeRole(request, response);
        if (employee == null) {
            return;
        }

        LeaveStatus statusFilter = parseStatus(request.getParameter("status"));
        Integer leaveTypeIdFilter = parseLeaveTypeId(request.getParameter("leaveTypeId"));
        String viewId = request.getParameter("id");

        if (viewId != null && !viewId.isEmpty()) {
            try {
                Leave leave = leaveService.getEmployeeLeaveById(
                        employee.getEmpId(), Integer.parseInt(viewId));
                request.setAttribute("selectedLeave", leave);
            } catch (NumberFormatException | LeaveServiceException e) {
                request.setAttribute("error", e.getMessage());
            }
        }

        List<Leave> history = leaveService.getEmployeeLeaveHistory(
                employee.getEmpId(), statusFilter, leaveTypeIdFilter);

        request.setAttribute("leaveHistory", history);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("leaveTypeIdFilter", leaveTypeIdFilter);
        request.setAttribute("leaveStatuses", LeaveStatus.values());
        request.setAttribute("leaveTypes", leaveService.getLeaveTypes());
        request.setAttribute("success", request.getParameter("success"));
        request.setAttribute("errorMsg", request.getParameter("error"));

        request.getRequestDispatcher("/WEB-INF/jsp/leave/leave-history.jsp")
                .forward(request, response);
    }

    private LeaveStatus parseStatus(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LeaveStatus.valueOf(value);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private Integer parseLeaveTypeId(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
