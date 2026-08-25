package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/DeleteEmployeeServlet")
public class DeleteEmployeeServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DeleteEmployeeServlet.class.getName());
    private EmployeeDAO employeeDAO;

    @Override
    public void init() {
        employeeDAO = new EmployeeDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object value = request.getSession(false) == null
            ? null : request.getSession(false).getAttribute("employee");
        if (!(value instanceof Employee)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String empIdStr = request.getParameter("empId");
        
        if (empIdStr != null) {
            try {
                int empId = Integer.parseInt(empIdStr);
                Employee viewer = (Employee) value;
                Employee target = employeeDAO.getEmployeeById(empId);
                boolean canManage = viewer.getRole() == Role.ADMIN
                    || (viewer.getRole() == Role.HR && target != null
                    && target.getRole() == Role.EMPLOYEE
                    && target.getDeptId() == viewer.getDeptId());
                if (target == null || target.getRole() == Role.ADMIN
                    || target.getEmpId() == viewer.getEmpId() || !canManage) {
                    response.sendRedirect(request.getContextPath() + "/SearchEmployeeServlet?error=protected");
                } else if (employeeDAO.deactivateEmployee(empId)) {
                    LOGGER.info("Employee deactivated: ID " + empId);
                    response.sendRedirect(request.getContextPath() + "/SearchEmployeeServlet?success=deleted");
                } else {
                    response.sendRedirect(request.getContextPath() + "/SearchEmployeeServlet?error=delete");
                }
                
            } catch (NumberFormatException e) {
                LOGGER.severe("Invalid employee ID: " + empIdStr);
                response.sendRedirect(employeeListRedirect((Employee) value) + "?error=invalid");
            }
        } else {
            response.sendRedirect(employeeListRedirect((Employee) value));
        }
    }

    private String employeeListRedirect(Employee viewer) {
        return getServletContext().getContextPath()
                + "/SearchEmployeeServlet";
    }
}
