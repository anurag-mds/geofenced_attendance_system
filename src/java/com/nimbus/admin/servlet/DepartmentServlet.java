package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.DepartmentDAO;
import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.model.Department;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/DepartmentServlet")
public class DepartmentServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DepartmentServlet.class.getName());
    private DepartmentDAO departmentDAO;
    private EmployeeDAO employeeDAO;

    @Override
    public void init() {
        departmentDAO = new DepartmentDAO();
        employeeDAO = new EmployeeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        List<Department> departments = departmentDAO.getAllDepartments();
        request.setAttribute("departments", departments);
        request.setAttribute("hrEmployees", employeeDAO.getUnassignedEmployeesByRole(Role.HR));
        String editId = request.getParameter("edit");
        if (editId != null && !editId.isBlank()) {
            try {
                request.setAttribute("editingDepartment",
                        departmentDAO.getDepartmentById(Integer.parseInt(editId)));
            } catch (NumberFormatException exception) {
                request.setAttribute("error", "Invalid department ID.");
            }
        }
        request.getRequestDispatcher("/WEB-INF/jsp/admin/departments.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                addDepartment(request, response);
            } else if ("update".equals(action)) {
                updateDepartment(request, response);
            } else if ("delete".equals(action)) {
                deleteDepartment(request, response);
            } else if ("toggle".equals(action)) {
                toggleDepartment(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/DepartmentServlet");
            }
        } catch (Exception e) {
            LOGGER.severe("Error in DepartmentServlet: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?error=true");
        }
    }

        private boolean isAdmin(HttpServletRequest request) {
        Object value = request.getSession(false) == null
            ? null : request.getSession(false).getAttribute("employee");
        return value instanceof Employee
            && ((Employee) value).getRole() == Role.ADMIN;
        }

    private void addDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String deptName = request.getParameter("deptName");
        String deptCode = request.getParameter("deptCode");
        String hrEmployeeId = request.getParameter("hrEmployeeId");

        if (hrEmployeeId == null || hrEmployeeId.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?error=hrRequired");
            return;
        }
        
        Department dept = new Department();
        dept.setDeptName(deptName);
        dept.setDeptCode(deptCode);

        if (deptName == null || deptName.isBlank() || deptName.trim().length() > 50) {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?error=invalid");
            return;
        }
        
        if (departmentDAO.addDepartment(dept, Integer.parseInt(hrEmployeeId))) {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?success=added");
        } else {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?error=add");
        }
    }

    private void updateDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        int deptId = Integer.parseInt(request.getParameter("deptId"));
        String deptName = request.getParameter("deptName");
        String deptCode = request.getParameter("deptCode");
        
        Department dept = new Department();
        dept.setDeptId(deptId);
        dept.setDeptName(deptName);
        dept.setDeptCode(deptCode);
        
        if (departmentDAO.updateDepartment(dept)) {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?error=update");
        }
    }

    private void deleteDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        int deptId = Integer.parseInt(request.getParameter("deptId"));
        
        if (departmentDAO.deleteDepartment(deptId)) {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/DepartmentServlet?error=delete");
        }
    }

    private void toggleDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int deptId = Integer.parseInt(request.getParameter("deptId"));
        boolean active = "true".equalsIgnoreCase(request.getParameter("active"));
        response.sendRedirect(request.getContextPath() + "/DepartmentServlet?success="
                + (departmentDAO.setDepartmentActive(deptId, active) ? "status" : "update"));
    }
}
