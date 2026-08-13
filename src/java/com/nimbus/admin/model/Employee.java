//This class is used for holding the data and It represents one record 
//or one row from the employees table.
//It acts as a model (Plain Old Java Object) that transfers employee information
//between the database and the application.

package com.nimbus.admin.model;

import java.time.LocalDate;

public class Employee {
    private int empId;
    private String empCode;
    private String fullName;
    private String email;
    private String password;
    private Role role;
    private String designation;
    private int deptId;
    private LocalDate joiningDate;
    private EmploymentStatus employmentStatus;
    
    public Employee() {
    }
    
    public Employee(int empId, String empCode, String fullName,
            String email, String password,
            Role role, String designation,
            int deptId, LocalDate joiningDate,
            EmploymentStatus employmentStatus) {
        
        this.empId = empId;
        this.empCode = empCode;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.role = role;
        this.designation = designation;
        this.deptId = deptId;
        this.joiningDate = joiningDate;
        this.employmentStatus = employmentStatus;  
    }
    
    //Getter and setter methods are implemented here for Encapsulation
    public int getEmpId() { 
        return empId;
    }
    
    public void setEmpId(int empId) {  
        this.empId = empId; 
    }
    
    public String getEmpCode() {
        return empCode;
    }
    
    public void setEmpCode(String empCode) {
        this.empCode = empCode;
    }
    
    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public int getDeptId() {
        return deptId;
    }

    public void setDeptId(int deptId) {
        this.deptId = deptId;
    }

    public LocalDate getJoiningDate() {
        return joiningDate;
    }

    public void setJoiningDate(LocalDate joiningDate) {
        this.joiningDate = joiningDate;
    }

    public EmploymentStatus getEmploymentStatus() {
        return employmentStatus;
    }

    public void setEmploymentStatus(EmploymentStatus employmentStatus) {
        this.employmentStatus = employmentStatus;
    }
    
    @Override
    public String toString() {
        return "Employee{" +
                "empId=" + empId +
                ", empCode='" + empCode + '\'' +
                ", fullName='" + fullName + '\'' +
                ", email='" + email + '\'' +
                ", role=" + role +
                ", designation='" + designation + '\'' +
                ", deptId=" + deptId +
                ", joiningDate=" + joiningDate +
                ", employmentStatus=" + employmentStatus +
                '}';
                
    }
}


