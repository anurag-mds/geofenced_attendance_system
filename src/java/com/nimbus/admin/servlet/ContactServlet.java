package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.EmployeeDAO;
import com.nimbus.admin.dao.ContactMessageDAO;
import com.nimbus.admin.dao.NotificationDAO;
import com.nimbus.admin.model.ContactMessage;
import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/ContactServlet")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 12 * 1024 * 1024)
public class ContactServlet extends HttpServlet {

    private static final long MAX_ATTACHMENT_SIZE = 10L * 1024 * 1024;
    private final EmployeeDAO employeeDAO = new EmployeeDAO();
    private final ContactMessageDAO messageDAO = new ContactMessageDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private Path uploadRoot;

    @Override
    public void init() {
        uploadRoot = Paths.get(System.getProperty("user.home"), ".employee-attendance", "contact-files");
        try {
            Files.createDirectories(uploadRoot);
        } catch (IOException exception) {
            throw new IllegalStateException("Unable to initialize contact attachment storage", exception);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Employee current = currentEmployee(request, response);
        if (current == null) {
            return;
        }
        String requestedFile = request.getParameter("file");
        if (requestedFile != null && !requestedFile.isBlank()) {
            streamAttachment(request, response, current, requestedFile);
            return;
        }
        Role contactRole = current.getRole() == Role.ADMIN ? Role.HR : Role.ADMIN;
        List<Employee> contacts = employeeDAO.getEmployeesByRole(contactRole);
        String contactWith = request.getParameter("contactWith");
        boolean canUseGroup = current.getRole() == Role.ADMIN || current.getRole() == Role.HR;
        boolean groupSelected = canUseGroup
            && (contactWith == null || "group".equalsIgnoreCase(contactWith));
        Employee selected = findAllowedContact(contactWith, contacts);
        if (!groupSelected && selected == null && !contacts.isEmpty()) {
            selected = contacts.get(0);
        }
        request.setAttribute("contacts", contacts);
        request.setAttribute("selectedContact", selected);
        request.setAttribute("groupSelected", groupSelected);
        try {
            request.setAttribute("messages", groupSelected ? messageDAO.getGroupConversation()
                    : selected == null ? List.of()
                    : messageDAO.getConversation(current.getEmpId(), selected.getEmpId()));
        } catch (java.sql.SQLException exception) {
            throw new ServletException("Unable to load contact conversation", exception);
        }
        request.setAttribute("contactRole", contactRole);
        request.getRequestDispatcher("/WEB-INF/jsp/common/contact.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Employee current = currentEmployee(request, response);
        if (current == null) {
            return;
        }
        List<Employee> contacts = employeeDAO.getEmployeesByRole(
                current.getRole() == Role.ADMIN ? Role.HR : Role.ADMIN);
        boolean groupSelected = (current.getRole() == Role.ADMIN || current.getRole() == Role.HR)
            && "group".equalsIgnoreCase(request.getParameter("conversationId"));
        if ("clear".equals(request.getParameter("action"))) {
            try {
                if (groupSelected) {
                    messageDAO.clearGroupConversation();
                } else {
                    Employee recipient = findAllowedContact(request.getParameter("recipientId"), contacts);
                    if (recipient == null) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    messageDAO.clearConversation(current.getEmpId(), recipient.getEmpId());
                }
                response.sendRedirect(request.getContextPath() + "/ContactServlet?contactWith="
                        + (groupSelected ? "group" : request.getParameter("recipientId")) + "&success=cleared");
            } catch (java.sql.SQLException exception) {
                throw new ServletException("Unable to clear contact conversation", exception);
            }
            return;
        }
        String[] recipientValues = request.getParameterValues("recipientId");
        String message = request.getParameter("message");
        Part attachment = request.getPart("attachment");
        String attachmentName = safeFileName(attachment);
        if (hasSubmittedAttachment(attachment) && attachmentName == null) {
            response.sendRedirect(request.getContextPath() + "/ContactServlet?error=attachment");
            return;
        }
        if ((!groupSelected && (recipientValues == null || recipientValues.length == 0))
                || ((message == null || message.isBlank()) && attachmentName == null)) {
            response.sendRedirect(request.getContextPath() + "/ContactServlet?error=message");
            return;
        }

        byte[] attachmentBytes = attachmentName == null ? null : attachment.getInputStream().readAllBytes();

        String lastRecipientId = groupSelected ? "group" : null;
        if (groupSelected) {
            try {
                int messageId = messageDAO.addGroupMessage(current.getEmpId(),
                        message == null ? "" : message.trim(), attachmentName);
                if (attachmentName != null && messageId > 0) {
                    Path folder = uploadRoot.resolve(String.valueOf(messageId));
                    Files.createDirectories(folder);
                    Files.write(folder.resolve(attachmentName), attachmentBytes);
                }
                List<Employee> groupMembers = new ArrayList<>();
                groupMembers.addAll(employeeDAO.getEmployeesByRole(Role.ADMIN));
                groupMembers.addAll(employeeDAO.getEmployeesByRole(Role.HR));
                for (Employee member : groupMembers) {
                    if (member.getEmpId() != current.getEmpId()) {
                        notificationDAO.addNotification(member.getEmpId(),
                                "New message in Admin + HR group", "ACCOUNT",
                                "/ContactServlet?contactWith=group");
                    }
                }
            } catch (java.sql.SQLException exception) {
                throw new ServletException("Unable to send contact message", exception);
            }
        } else {
            for (String recipientValue : recipientValues) {
                try {
                    Employee recipient = findAllowedContact(recipientValue, contacts);
                    if (recipient == null) {
                        continue;
                    }
                    lastRecipientId = recipientValue;
                    int messageId = messageDAO.addMessage(current.getEmpId(), recipient.getEmpId(),
                            message == null ? "" : message.trim(), attachmentName);
                    if (attachmentName != null && messageId > 0) {
                        Path folder = uploadRoot.resolve(String.valueOf(messageId));
                        Files.createDirectories(folder);
                        Files.write(folder.resolve(attachmentName), attachmentBytes);
                    }
                    notificationDAO.addNotification(recipient.getEmpId(),
                        "New message from " + current.getFullName(), "ACCOUNT",
                        "/ContactServlet?contactWith=" + current.getEmpId());
                } catch (NumberFormatException exception) {
                    // Ignore invalid recipient values submitted by a client.
                } catch (java.sql.SQLException exception) {
                    throw new ServletException("Unable to send contact message", exception);
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/ContactServlet?contactWith=" + lastRecipientId);
    }

    private Employee findAllowedContact(String value, List<Employee> contacts) {
        if (value == null) {
            return null;
        }
        try {
            int id = Integer.parseInt(value);
            return contacts.stream().filter(employee -> employee.getEmpId() == id).findFirst().orElse(null);
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private String safeFileName(Part attachment) {
        if (!hasSubmittedAttachment(attachment) || attachment.getSize() > MAX_ATTACHMENT_SIZE) {
            return null;
        }
        String original = Paths.get(attachment.getSubmittedFileName()).getFileName().toString();
        String fileName = original.replaceAll("[^A-Za-z0-9._ -]", "_").trim();
        if (fileName.isBlank() || fileName.length() > 255) return null;
        if (!fileName.matches("[A-Za-z0-9].*")) fileName = "attachment-" + fileName;
        return fileName;
    }

    private boolean hasSubmittedAttachment(Part attachment) {
        return attachment != null && attachment.getSize() > 0
                && attachment.getSubmittedFileName() != null
                && !attachment.getSubmittedFileName().isBlank();
    }

    private void streamAttachment(HttpServletRequest request, HttpServletResponse response,
            Employee current, String requestedFile) throws IOException, ServletException {
        try {
            int messageId = Integer.parseInt(request.getParameter("messageId"));
            if (!messageDAO.isParticipant(messageId, current.getEmpId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            Path file = uploadRoot.resolve(String.valueOf(messageId))
                    .resolve(Paths.get(requestedFile).getFileName().toString());
            if (!Files.isRegularFile(file)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
                String mimeType = getServletContext().getMimeType(file.getFileName().toString());
                boolean preview = "1".equals(request.getParameter("view"))
                    && (mimeType != null && (mimeType.startsWith("image/")
                    || "application/pdf".equals(mimeType)));
                response.setContentType(preview ? mimeType : "application/octet-stream");
                response.setHeader("Content-Disposition", (preview ? "inline" : "attachment") + "; filename=\""
                    + file.getFileName() + "\"");
            response.setHeader("X-Content-Type-Options", "nosniff");
            Files.copy(file, response.getOutputStream());
        } catch (NumberFormatException exception) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        } catch (java.sql.SQLException exception) {
            throw new ServletException("Unable to validate contact attachment", exception);
        }
    }

    private Employee currentEmployee(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Object value = request.getSession(false) == null
                ? null : request.getSession(false).getAttribute("employee");
        if (!(value instanceof Employee)) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return null;
        }
        return (Employee) value;
    }
}