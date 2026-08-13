//This servlet provides the admin leave overview and read-only record views.
//Admin can monitor statistics and activity but does not approve leave; that
//responsibility remains with HR through the dedicated HR leave workflow.

package com.nimbus.admin.leave.servlet;

import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveStatistics;
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

        String view = request.getParameter("view");

        if ("records".equals(view)) {
            showRecords(request, response);
            return;
        }

        LeaveStatistics stats = leaveService.getLeaveStatistics();
        List<Leave> recentActivity = leaveService.getRecentLeaveActivity(10);

        request.setAttribute("leaveStats", stats);
        request.setAttribute("recentActivity", recentActivity);

        request.getRequestDispatcher("/WEB-INF/jsp/leave/leave-overview.jsp")
                .forward(request, response);
    }

    private void showRecords(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        LeaveStatus statusFilter = parseStatus(request.getParameter("status"));
        Integer leaveTypeIdFilter = parseLeaveTypeId(request.getParameter("leaveTypeId"));
        String employeeSearch = request.getParameter("search");
        LocalDate fromDate = parseDate(request.getParameter("fromDate"));
        LocalDate toDate = parseDate(request.getParameter("toDate"));

        List<Leave> records = leaveService.getAllLeaveRecords(statusFilter,
                employeeSearch, leaveTypeIdFilter, fromDate, toDate);

        request.setAttribute("leaveRecords", records);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("leaveTypeIdFilter", leaveTypeIdFilter);
        request.setAttribute("employeeSearch", employeeSearch);
        request.setAttribute("fromDate", request.getParameter("fromDate"));
        request.setAttribute("toDate", request.getParameter("toDate"));
        request.setAttribute("leaveStatuses", LeaveStatus.values());
        request.setAttribute("leaveTypes", leaveService.getLeaveTypes());
        request.setAttribute("viewMode", "records");

        request.getRequestDispatcher("/WEB-INF/jsp/leave/leave-overview.jsp")
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
