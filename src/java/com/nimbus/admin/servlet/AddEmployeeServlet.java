package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.model.EmploymentStatus;
import com.nimbus.admin.model.Department;
import com.nimbus.admin.dao.DepartmentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.logging.Logger;

@WebServlet("/AddEmployeeServlet")
public class AddEmployeeServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AddEmployeeServlet.class.getName());
    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final int MAX_PASSWORD_LENGTH = 50;
    private static final String EMPLOYEE_CODE_PATTERN = "^NT[0-9]{1,3}$";
    private static final String COMPANY_EMAIL_PATTERN = "(?i)^[A-Z0-9._%+-]+@nimbustech\\.com$";
    private static final String PASSWORD_PATTERN = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{"
            + MIN_PASSWORD_LENGTH + "," + MAX_PASSWORD_LENGTH + "}$";
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
        if (!isAdmin(request, response)) {
            return;
        }
        String mode = request.getParameter("mode");
        if (mode != null && !isSupportedMode(mode)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported employee form mode.");
            return;
        }
        request.setAttribute("creationMode", "hr".equalsIgnoreCase(mode) ? "hr" : "employee");
        request.setAttribute("departments", departmentDAO.getAllDepartments());
        request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) {
            return;
        }
        
        try {
            String empCode = request.getParameter("empCode");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String mode = request.getParameter("mode");
            String designation = request.getParameter("designation");
            String deptIdStr = request.getParameter("deptId");
            String joiningDateStr = request.getParameter("joiningDate");
            if (!isSupportedMode(mode)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported employee form mode.");
                return;
            }
            boolean isHr = "hr".equalsIgnoreCase(mode);
            String roleStr = isHr ? Role.HR.name() : Role.EMPLOYEE.name();

            // Validate required fields
            if (empCode == null || empCode.trim().isEmpty()
                    || fullName == null || fullName.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || password == null || password.isEmpty()
                    || designation == null || designation.trim().isEmpty()
                    || joiningDateStr == null || joiningDateStr.isBlank()
                    || (!isHr && (deptIdStr == null || deptIdStr.isBlank()))) {
                request.setAttribute("error", isHr
                        ? "Employee code, name, email, password, designation, and joining date are required."
                        : "Employee code, name, email, password, designation, joining date, and department are required.");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            if (!password.matches(PASSWORD_PATTERN)) {
                request.setAttribute("error", "Password must be 8-50 characters using only letters and numbers, with at least one of each.");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            if (!email.trim().matches(COMPANY_EMAIL_PATTERN)) {
                request.setAttribute("error", "Use a valid company email ending in @nimbustech.com.");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            if (empCode.trim().length() > 20 || fullName.trim().length() > 100
                    || email.trim().length() > 100 || designation.trim().length() > 50) {
                request.setAttribute("error", "Employee code, name, email, or designation is too long for the database limits.");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            if (!empCode.trim().matches(EMPLOYEE_CODE_PATTERN)) {
                request.setAttribute("error", "Employee code must start with NT and contain 1 to 3 numbers, for example NT001.");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            int deptId = isHr && (deptIdStr == null || deptIdStr.isBlank())
                    ? 0 : Integer.parseInt(deptIdStr);
            if (!isHr && (deptId <= 0 || departmentDAO.getDepartmentById(deptId) == null)) {
                request.setAttribute("error", "Select a valid department");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            // Check if emp code already exists
            if (employeeDAO.employeeCodeExists(empCode.trim())) {
                request.setAttribute("error", "Employee code already exists");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            if (employeeDAO.emailExists(email.trim())) {
                request.setAttribute("error", "Email address already exists");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
                return;
            }

            // Create employee
            Employee employee = new Employee();
            employee.setEmpCode(empCode.trim());
            employee.setFullName(fullName.trim());
            employee.setEmail(email != null ? email.trim() : "");
            employee.setPassword(password);
            employee.setRole(Role.valueOf(roleStr));
            employee.setDesignation(designation.trim());
            employee.setDeptId(deptId);
            employee.setJoiningDate(LocalDate.parse(joiningDateStr));
            employee.setEmploymentStatus(EmploymentStatus.ACTIVE);

            if (employeeDAO.addEmployee(employee)) {
                LOGGER.info("Employee added: " + empCode);
                response.sendRedirect(request.getContextPath() + "/SearchEmployeeServlet?success=added&createdRole=" + roleStr);
            } else {
                request.setAttribute("error", "Failed to add employee");
                request.setAttribute("creationMode", mode.toLowerCase());
                request.setAttribute("departments", departmentDAO.getAllDepartments());
                request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error adding employee", e);
            request.setAttribute("error", "System error while adding employee. Please try again.");
            request.setAttribute("creationMode", "hr".equalsIgnoreCase(request.getParameter("mode"))
                    ? "hr" : "employee");
            request.setAttribute("departments", departmentDAO.getAllDepartments());
            request.getRequestDispatcher("/WEB-INF/jsp/admin/add-employee.jsp")
                    .forward(request, response);
        }
    }

    private boolean isSupportedMode(String mode) {
        return "employee".equalsIgnoreCase(mode) || "hr".equalsIgnoreCase(mode);
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Object value = request.getSession(false) == null
                ? null : request.getSession(false).getAttribute("employee");
        if (!(value instanceof Employee)
                || ((Employee) value).getRole() != Role.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
    }
}
