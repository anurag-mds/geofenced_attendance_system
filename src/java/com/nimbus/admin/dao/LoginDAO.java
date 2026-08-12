package com.nimbus.admin.dao;


import com.nimbus.admin.model.Employee;
import com.nimbus.admin.model.Role;
import com.nimbus.admin.model.EmploymentStatus;

import com.nimbus.admin.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginDAO{
   
    public Employee login(String empCode, String password){
        Employee employee = null;
       
        String sql = "SELECT emp_id, emp_code, full_name, email, password, "
           + "role, designation, dept_id, joining_date, employment_status "
           + "FROM employees "
           + "WHERE emp_code = ? "
           + "AND password = ? "
           + "AND employment_status = 'ACTIVE'";
       
        try{
            Connection con = DBConnection.getConnection();
           
            PreparedStatement ps = con.prepareStatement(sql);
           
            ps.setString(1, empCode);
            ps.setString(2, password);
           
            ResultSet rs = ps.executeQuery();
           
            if(rs.next()){
                System.out.println("LOGIN MATCH FOUND!");
               
                employee = new Employee();
                employee.setEmpId(rs.getInt("emp_id"));

                employee.setEmpCode(
                    rs.getString("emp_code")
                );

                employee.setFullName(
                    rs.getString("full_name")
                );

                employee.setEmail(
                    rs.getString("email")
                );

                employee.setPassword(
                    rs.getString("password")
                );
               
                employee.setRole(
                    Role.valueOf(rs.getString("role"))
                );

                employee.setDesignation(
                    rs.getString("designation")
                );

                employee.setDeptId(
                    rs.getInt("dept_id")
                );

                employee.setJoiningDate(
                    rs.getDate("joining_date").toLocalDate()
                );

                employee.setEmploymentStatus(
                    EmploymentStatus.valueOf(
                        rs.getString("employment_status")
                    )
                );


               
               
            }
           
            else {

    System.out.println("NO EMPLOYEE FOUND!");
}
           
            rs.close();
            ps.close();
            con.close();
       
        }
       
        catch(Exception e) {
    System.out.println("ERROR IN LOGIN DAO:");
    e.printStackTrace();
}
       
        return employee;
        }
   
}