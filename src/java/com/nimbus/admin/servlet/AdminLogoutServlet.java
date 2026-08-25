package com.nimbus.admin.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet("/AdminLogoutServlet")
public class AdminLogoutServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminLogoutServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            LOGGER.info("User logged out: " + session.getAttribute("empCode"));
            session.invalidate();
        }
        Cookie authMarker = new Cookie("ATTENDANCE_AUTHENTICATED", "");
        authMarker.setMaxAge(0);
        authMarker.setHttpOnly(true);
        authMarker.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
        response.addCookie(authMarker);
        
        request.setAttribute("logoutTransition", Boolean.TRUE);
        request.getRequestDispatcher("/logout-success.jsp").forward(request, response);
    }
}
