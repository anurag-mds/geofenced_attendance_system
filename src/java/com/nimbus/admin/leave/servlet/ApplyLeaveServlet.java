//This servlet shows the Apply for Leave form and submits new leave requests.
//Employee identity comes from the session, and all validation is delegated to
//LeaveService so the browser cannot bypass workflow or business rules.

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
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet("/ApplyLeaveServlet")
public class ApplyLeaveServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Employee employee = LeaveAuthUtil.requireEmployeeRole(request, response);
        if (employee == null) {
            return;
        }

        request.setAttribute("leaveTypes", leaveService.getLeaveTypes());
        request.getRequestDispatcher("/WEB-INF/jsp/leave/apply-leave.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Employee employee = LeaveAuthUtil.requireEmployeeRole(request, response);
        if (employee == null) {
            return;
        }

        try {
            int leaveTypeId = Integer.parseInt(request.getParameter("leaveTypeId"));
            LocalDate fromDate = LocalDate.parse(request.getParameter("fromDate"));
            LocalDate toDate = LocalDate.parse(request.getParameter("toDate"));
            String reason = request.getParameter("reason");

            leaveService.applyLeave(employee.getEmpId(), leaveTypeId, fromDate,
                    toDate, reason);

            response.sendRedirect(request.getContextPath()
                    + "/LeaveHistoryServlet?success=applied");

        } catch (NumberFormatException | DateTimeParseException e) {
            request.setAttribute("error", "Invalid leave request data.");
            request.setAttribute("leaveTypes", leaveService.getLeaveTypes());
            preserveFormInput(request);
            request.getRequestDispatcher("/WEB-INF/jsp/leave/apply-leave.jsp")
                    .forward(request, response);

        } catch (LeaveServiceException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("leaveTypes", leaveService.getLeaveTypes());
            preserveFormInput(request);
            request.getRequestDispatcher("/WEB-INF/jsp/leave/apply-leave.jsp")
                    .forward(request, response);
        }
    }

    private void preserveFormInput(HttpServletRequest request) {
        request.setAttribute("selectedLeaveTypeId", request.getParameter("leaveTypeId"));
        request.setAttribute("fromDate", request.getParameter("fromDate"));
        request.setAttribute("toDate", request.getParameter("toDate"));
        request.setAttribute("reason", request.getParameter("reason"));
    }
}
