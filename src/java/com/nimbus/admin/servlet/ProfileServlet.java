/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.nimbus.admin.servlet;

import com.nimbus.admin.dao.LoginDAO;
import com.nimbus.admin.model.Employee;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author admin
 */

@WebServlet(name = "ProfileServlet",urlPatterns={"/ProfileServlet"})
public class ProfileServlet extends HttpServlet{
    
    @Override
    protected void doGet(HttpServletRequest request, 
            HttpServletResponse response)
            throws ServletException, IOException{
        HttpSession session = request.getSession(false);
        
        if(session==null||session.getAttribute("employee")==null){
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        Employee employee =(Employee)session.getAttribute("employee");
        
        request.setAttribute("employee", employee);
        
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
        
    }
}