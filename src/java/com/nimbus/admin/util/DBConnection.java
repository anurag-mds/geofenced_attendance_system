//This utility class is responsible for establishing a connection
//between the Java application and the MySQL database.
//All DAO classes will use this class to obtain a database connection,
//avoiding duplicate connection code throughout the project.

package com.nimbus.admin.util;

import java.sql.*;

public class DBConnection {
    
    private static final String URL = "jdbc:mysql://localhost:3306/nimbus_tech_attendance";
    
    private static final String USERNAME = "root";
    private static final String PASSWORD = "RadhaKunj";
    
    private DBConnection() {
        
    }
    
    public static Connection getConnection() throws SQLException {
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
         
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }
        
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }   

}


