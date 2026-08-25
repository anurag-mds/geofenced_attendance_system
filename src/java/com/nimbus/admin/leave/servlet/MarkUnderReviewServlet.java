//This servlet moves a leave request into the UNDER_REVIEW state for HR.
//It keeps the review step explicit in the workflow and prevents direct
//approval or rejection without first acknowledging the request.

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

@WebServlet("/MarkUnderReviewServlet")
public class MarkUnderReviewServlet extends HttpServlet {

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
            leaveService.markUnderReview(leaveId, hr.getEmpId(), remark);
            response.sendRedirect(request.getContextPath()
                    + "/HrLeaveRequestsServlet?id=" + leaveId
                    + "&success=under_review");
        } catch (NumberFormatException e) {
            redirectWithError(response, request, "Invalid leave request ID.");
        } catch (LeaveServiceException e) {
            redirectWithError(response, request, e.getMessage());
        }
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
