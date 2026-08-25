//This servlet is the HR entry point for listing and reviewing leave requests.
//HR users can filter requests and open details, while all approval decisions
//are still executed through dedicated action servlets backed by LeaveService.

package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveStatus;
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
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/HrLeaveRequestsServlet")
public class HrLeaveRequestsServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Employee hr = LeaveAuthUtil.requireHrRole(request, response);
        if (hr == null) {
            return;
        }

        LeaveStatus statusFilter = parseStatus(request.getParameter("status"));
        Integer leaveTypeIdFilter = parseLeaveTypeId(request.getParameter("leaveTypeId"));
        String employeeSearch = request.getParameter("search");
        LocalDate fromDate = parseDate(request.getParameter("fromDate"));
        LocalDate toDate = parseDate(request.getParameter("toDate"));
        String viewId = request.getParameter("id");

        if (viewId != null && !viewId.isEmpty()) {
            try {
                Leave leave = leaveService.getLeaveByIdForDepartment(
                    Integer.parseInt(viewId), hr.getDeptId());
                if (leave == null) {
                    request.setAttribute("error", "Leave request not found.");
                } else {
                    request.setAttribute("selectedLeave", leave);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid leave request ID.");
            }
            request.setAttribute("success", request.getParameter("success"));
            request.setAttribute("errorMsg", request.getParameter("error"));
            request.getRequestDispatcher("/WEB-INF/jsp/leave/leave-request-details.jsp")
                    .forward(request, response);
            return;
        }

        List<Leave> requests = leaveService.getLeaveRequestsForDepartment(
            hr.getDeptId(), statusFilter, employeeSearch, leaveTypeIdFilter,
            fromDate, toDate);

        request.setAttribute("leaveRequests", requests);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("leaveTypeIdFilter", leaveTypeIdFilter);
        request.setAttribute("employeeSearch", employeeSearch);
        request.setAttribute("fromDate", request.getParameter("fromDate"));
        request.setAttribute("toDate", request.getParameter("toDate"));
        request.setAttribute("leaveStatuses", LeaveStatus.values());
        request.setAttribute("leaveTypes", leaveService.getLeaveTypes());
        request.setAttribute("success", request.getParameter("success"));
        request.setAttribute("errorMsg", request.getParameter("error"));

        request.getRequestDispatcher("/WEB-INF/jsp/leave/leave-requests.jsp")
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

    private LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
