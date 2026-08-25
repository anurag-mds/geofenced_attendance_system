package com.nimbus.admin.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        preventBrowserCaching(response);
        HttpSession session = request.getSession(false);
        if (session != null) {
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void preventBrowserCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}
