package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/CheckEmployeeCodeServlet")
public class CheckEmployeeCodeServlet extends HttpServlet {

    private EmployeeDAO employeeDAO;

    @Override
    public void init() {
        employeeDAO = new EmployeeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Object value = request.getSession(false) == null
                ? null : request.getSession(false).getAttribute("employee");
        if (!(value instanceof Employee)
                || ((Employee) value).getRole() != Role.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String empCode = request.getParameter("empCode");
        boolean valid = empCode != null && empCode.matches("[A-Za-z0-9]+");
        boolean exists = valid && employeeDAO.employeeCodeExists(empCode.trim());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.getWriter().printf("{\"valid\":%s,\"exists\":%s}", valid, exists);
    }
}
