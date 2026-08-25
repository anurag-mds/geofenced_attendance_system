package com.nimbus.admin.leave.servlet;

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

@WebServlet("/AdminLeaveOverviewServlet")
public class AdminLeaveOverviewServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Employee admin = LeaveAuthUtil.requireAdminRole(request, response);
        if (admin == null) {
            return;
        }

        request.setAttribute("viewMode", "records".equals(request.getParameter("view"))
                ? "records" : "overview");
        request.setAttribute("leaveStats", leaveService.getLeaveStatistics());
        request.setAttribute("recentActivity", leaveService.getRecentLeaveActivity(10));
        request.setAttribute("leaveTypes", leaveService.getLeaveTypes());
        request.setAttribute("leaveStatuses", LeaveStatus.values());

        if ("records".equals(request.getParameter("view"))) {
            LeaveStatus status = parseStatus(request.getParameter("status"));
            Integer leaveTypeId = parseInteger(request.getParameter("leaveTypeId"));
            String fromDate = trimToNull(request.getParameter("fromDate"));
            String toDate = trimToNull(request.getParameter("toDate"));
            request.setAttribute("statusFilter", status);
            request.setAttribute("leaveTypeIdFilter", leaveTypeId);
            request.setAttribute("employeeSearch", trimToNull(request.getParameter("search")));
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);
            request.setAttribute("leaveRecords", leaveService.getAllLeaveRecords(status,
                    trimToNull(request.getParameter("search")), leaveTypeId,
                    parseDate(fromDate), parseDate(toDate)));
        }

        request.getRequestDispatcher("/WEB-INF/jsp/leave/leave-overview.jsp")
                .forward(request, response);
    }

    private LeaveStatus parseStatus(String value) {
        try {
            return value == null || value.isBlank() ? null : LeaveStatus.valueOf(value);
        } catch (IllegalArgumentException exception) {
            return null;
        }
    }

    private Integer parseInteger(String value) {
        try {
            return value == null || value.isBlank() ? null : Integer.valueOf(value);
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private LocalDate parseDate(String value) {
        try {
            return value == null ? null : LocalDate.parse(value);
        } catch (RuntimeException exception) {
            return null;
        }
    }

    private String trimToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}