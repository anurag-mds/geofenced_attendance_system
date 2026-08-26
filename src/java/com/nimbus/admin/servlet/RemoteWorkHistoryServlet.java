package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.RemoteWorkDAO;
import com.nimbus.admin.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/RemoteWorkHistoryServlet")
public class RemoteWorkHistoryServlet extends HttpServlet {

    private final RemoteWorkDAO remoteWorkDAO = new RemoteWorkDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Employee employee = session == null
                ? null : (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        request.setAttribute("remoteRequests",
                remoteWorkDAO.getEmployeeRequests(employee.getEmpId()));
        request.setAttribute("success", request.getParameter("success"));
        request.getRequestDispatcher("/WEB-INF/jsp/remote-work/remote-work-history.jsp")
                .forward(request, response);
    }
}
