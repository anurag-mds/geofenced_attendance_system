//This class stores all constant values used throughout the
//Admin module, such as session keys, role names and common
//application-wide values.
//Using constants avoids hardcoding strings and improves
//code readability, maintainability and consistency.

package com.nimbus.admin.constants;

public final class ApplicationConstants {
    
    private ApplicationConstants() {   
    }
    
    //Session Attributes
    
    public static final String ADMIN_SESSION = "adminSession";
    public static final String LOGGED_IN_ADMIN = "loggedInAdmin";
    
    //User Roles
    
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_HR = "HR";
    public static final String ROLE_EMPLOYEE = "EMPLOYEE";
    
    //Employment Status
    
    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_INACTIVE = "INACTIVE";
    
    //Messages
    
    public static final String LOGIN_FAILED = 
            "Invalid username or password.";
    public static final String ACCESS_DENIED =
            "You are not authorized to access this page.";
    public static final String DATABASE_ERROR = 
            "Database connection failed";
    
}