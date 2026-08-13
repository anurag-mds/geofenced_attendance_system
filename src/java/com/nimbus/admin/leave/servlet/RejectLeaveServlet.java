//This servlet allows authorized HR users to reject a leave request.
//A rejection reason is required and persisted so the employee can later see
//why the request was declined in their leave history.

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

@WebServlet("/RejectLeaveServlet")
public class RejectLeaveServlet extends HttpServlet {

    private final LeaveService leaveService = new LeaveServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Employee hr = LeaveAuthUtil.requireHrRole(request, response);
        if (hr == null) {
            return;
        }

        try {
            int leaveId = Integer.parseInt(request.getParameter("leaveId"));
            String remark = request.getParameter("hrRemark");
            leaveService.rejectLeave(leaveId, hr.getEmpId(), remark);
            redirectWithSuccess(response, request, leaveId);
        } catch (NumberFormatException e) {
            redirectWithError(response, request, "Invalid leave request ID.");
        } catch (LeaveServiceException e) {
            redirectWithError(response, request, e.getMessage());
        }
    }

    private void redirectWithSuccess(HttpServletResponse response,
            HttpServletRequest request, int leaveId) throws IOException {
        response.sendRedirect(request.getContextPath()
                + "/HrLeaveRequestsServlet?id=" + leaveId + "&success=rejected");
    }

    private void redirectWithError(HttpServletResponse response,
            HttpServletRequest request, String message) throws IOException {
        String leaveId = request.getParameter("leaveId");
        String target = request.getContextPath() + "/HrLeaveRequestsServlet";
        if (leaveId != null && !leaveId.isBlank()) {
            target += "?id=" + leaveId;
        }
        target += (target.contains("?") ? "&" : "?")
                + "error=" + URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(target);
    }
}
