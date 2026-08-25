package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.dao.DepartmentDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.model.EmploymentStatus;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.logging.Logger;

@WebServlet("/EditEmployeeServlet")
public class EditEmployeeServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(EditEmployeeServlet.class.getName());
    private static final String PASSWORD_PATTERN = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,50}$";
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
        Employee viewer = getViewer(request);
        if (viewer == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String empIdStr = request.getParameter("empId");
        if (empIdStr != null) {
            try {
                int empId = Integer.parseInt(empIdStr);
                Employee employee = employeeDAO.getEmployeeById(empId);
                
                if (employee != null) {
                    if (!canManage(viewer, employee)) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin accounts are protected.");
                        return;
                    }
                    request.setAttribute("employee", employee);
                    request.setAttribute("departments", departmentDAO.getAllDepartments());
                    request.getRequestDispatcher("/WEB-INF/jsp/admin/edit-employee.jsp")
                            .forward(request, response);
                } else {
                    response.sendRedirect(employeeListRedirect(viewer) + "?error=notfound");
                }
            } catch (NumberFormatException e) {
                LOGGER.warning("Invalid employee ID: " + empIdStr);
                response.sendRedirect(employeeListRedirect(viewer) + "?error=invalid");
            }
        } else {
            response.sendRedirect(employeeListRedirect(viewer));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Employee viewer = getViewer(request);
        if (viewer == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        try {
            int empId = Integer.parseInt(request.getParameter("empId"));
            
            Employee employee = employeeDAO.getEmployeeById(empId);
            if (employee == null) {
                response.sendRedirect(employeeListRedirect(viewer) + "?error=notfound");
                return;
            }
            if (!canManage(viewer, employee)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin accounts are protected.");
                return;
            }

            // Update fields
            employee.setFullName(request.getParameter("fullName"));
            String email = request.getParameter("email");
            String designation = request.getParameter("designation");
            String roleValue = request.getParameter("role");
            if (email == null || email.isBlank() || email.length() > 100
                    || designation == null || designation.isBlank() || designation.length() > 50
                    || !Role.HR.name().equals(roleValue) && !Role.EMPLOYEE.name().equals(roleValue)) {
                request.setAttribute("error", "Enter valid name, email, designation, and an Employee or HR role.");
                returnToEdit(request, response, employee);
                return;
            }
            employee.setEmail(email.trim());
            
            String password = request.getParameter("password");
            if (password != null && !password.isEmpty()) {
                if (!password.matches(PASSWORD_PATTERN)) {
                    request.setAttribute("error", "Password must be 8-50 characters using letters and numbers, with at least one of each.");
                    returnToEdit(request, response, employee);
                    return;
                }
                employee.setPassword(password);
            }
            
                employee.setRole(viewer.getRole() == Role.HR
                    ? (employee.getEmpId() == viewer.getEmpId() ? Role.HR : Role.EMPLOYEE)
                    : Role.valueOf(roleValue));
            employee.setDesignation(designation.trim());

            if (employeeDAO.emailExists(employee.getEmail(), employee.getEmpId())) {
                request.setAttribute("error", "Email address already exists");
                returnToEdit(request, response, employee);
                return;
            }
            
            String deptIdStr = request.getParameter("deptId");
            if (Role.EMPLOYEE == employee.getRole()
                    && (deptIdStr == null || deptIdStr.isEmpty())) {
                request.setAttribute("error", "Select a department for an employee.");
                returnToEdit(request, response, employee);
                return;
            }
                    employee.setDeptId(viewer.getRole() == Role.HR ? employee.getDeptId()
                    : (deptIdStr != null && !deptIdStr.isEmpty() ? Integer.parseInt(deptIdStr) : 0));
            if (employee.getDeptId() > 0 && departmentDAO.getDepartmentById(employee.getDeptId()) == null) {
                request.setAttribute("error", "Select a valid department.");
                returnToEdit(request, response, employee);
                return;
            }
            
            employee.setJoiningDate(LocalDate.parse(request.getParameter("joiningDate")));
            employee.setEmploymentStatus(EmploymentStatus.valueOf(request.getParameter("employmentStatus")));

            if (employeeDAO.updateEmployee(employee)) {
                request.getSession().setAttribute("employee", employee.getEmpId() == viewer.getEmpId()
                        ? employee : viewer);
                LOGGER.info("Employee updated: " + employee.getEmpCode());
                response.sendRedirect(request.getContextPath()
                    + (viewer.getRole() == Role.HR ? "/SearchEmployeeServlet" : "/adminDashboard.jsp")
                    + "?success=updated");
            } else {
                request.setAttribute("error", "Failed to update employee");
                request.setAttribute("employee", employee);
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/edit-employee.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {
            LOGGER.severe("Error updating employee: " + e.getMessage());
            response.sendRedirect(employeeListRedirect(viewer) + "?error=update");
        }
    }

    private void returnToEdit(HttpServletRequest request, HttpServletResponse response,
            Employee employee) throws ServletException, IOException {
        request.setAttribute("employee", employee);
        request.setAttribute("departments", departmentDAO.getAllDepartments());
        request.getRequestDispatcher("/WEB-INF/jsp/admin/edit-employee.jsp")
                .forward(request, response);
    }

    private Employee getViewer(HttpServletRequest request) {
        Object value = request.getSession(false) == null
                ? null : request.getSession(false).getAttribute("employee");
        return value instanceof Employee ? (Employee) value : null;
    }

    private boolean canManage(Employee viewer, Employee target) {
        return target != null && target.getRole() != Role.ADMIN
                && (viewer.getRole() == Role.ADMIN
                || (viewer.getRole() == Role.HR
                && ((target.getEmpId() == viewer.getEmpId() && target.getRole() == Role.HR)
                || (target.getRole() == Role.EMPLOYEE
                && target.getDeptId() == viewer.getDeptId()))));
    }

    private String employeeListRedirect(Employee viewer) {
        return getServletContext().getContextPath() + "/SearchEmployeeServlet";
    }
}
