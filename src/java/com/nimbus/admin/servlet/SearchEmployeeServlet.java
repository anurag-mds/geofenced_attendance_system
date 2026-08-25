package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.dao.DepartmentDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.EmploymentStatus;
import com.nimbus.admin.model.Role;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/SearchEmployeeServlet")
public class SearchEmployeeServlet extends HttpServlet {

    private EmployeeDAO employeeDAO;
    private DepartmentDAO departmentDAO;

    @Override
    public void init() {
        employeeDAO = new EmployeeDAO();
        departmentDAO = new DepartmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Employee viewer = session == null
            ? null : (Employee) session.getAttribute("employee");
        if (viewer == null || (viewer.getRole() != Role.ADMIN
            && viewer.getRole() != Role.HR)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Only administrators and HR may view employees.");
            return;
        }
        
        String keyword = request.getParameter("keyword");
        
        if (viewer.getRole() == Role.ADMIN) {
            Role role = parseRole(request.getParameter("role"));
            EmploymentStatus status = parseStatus(request.getParameter("status"));
            Integer departmentId = parseDepartment(request.getParameter("departmentId"));
            request.setAttribute("employees", employeeDAO.getEmployeesForAdmin(
                keyword, role, status, departmentId));
            request.setAttribute("departments", departmentDAO.getAllDepartments());
            request.setAttribute("selectedRole", request.getParameter("role"));
            request.setAttribute("selectedStatus", request.getParameter("status"));
            request.setAttribute("selectedDepartment", request.getParameter("departmentId"));
        } else if (viewer.getRole() == Role.HR) {
            List<Employee> employees = employeeDAO.searchEmployeesByDepartment(
                viewer.getDeptId(), keyword);
            request.setAttribute("employees", employees);
            request.setAttribute("keyword", keyword);
        } else if (keyword != null && !keyword.trim().isEmpty()) {
            List<Employee> employees = employeeDAO.searchEmployees(keyword.trim());
            request.setAttribute("employees", employees);
            request.setAttribute("keyword", keyword);
        } else {
            List<Employee> employees = employeeDAO.getAllEmployees();
            request.setAttribute("employees", employees);
        }
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin/employee-list.jsp")
                .forward(request, response);
    }

    private Role parseRole(String value) {
        try {
            return value == null || value.isBlank() ? null : Role.valueOf(value);
        } catch (IllegalArgumentException exception) {
            return null;
        }
    }

    private EmploymentStatus parseStatus(String value) {
        try {
            return value == null || value.isBlank() ? null : EmploymentStatus.valueOf(value);
        } catch (IllegalArgumentException exception) {
            return null;
        }
    }

    private Integer parseDepartment(String value) {
        try {
            int departmentId = Integer.parseInt(value);
            return departmentId > 0 ? departmentId : null;
        } catch (Exception exception) {
            return null;
        }
    }
}
