package com.nimbus.admin.model;

public class Department {
    private int deptId;
    private String deptName;
    private String deptCode;
    private int activeEmployeeCount;
    private boolean active = true;

    public Department() {
    }

    public Department(int deptId, String deptName, String deptCode) {
        this.deptId = deptId;
        this.deptName = deptName;
        this.deptCode = deptCode;
    }

    public int getDeptId() {
        return deptId;
    }

    public void setDeptId(int deptId) {
        this.deptId = deptId;
    }

    public String getDeptName() {
        return deptName;
    }

    public void setDeptName(String deptName) {
        this.deptName = deptName;
    }

    public String getDeptCode() {
        return deptCode;
    }

    public void setDeptCode(String deptCode) {
        this.deptCode = deptCode;
    }

    public int getActiveEmployeeCount() {
        return activeEmployeeCount;
    }

    public void setActiveEmployeeCount(int activeEmployeeCount) {
        this.activeEmployeeCount = activeEmployeeCount;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    @Override
    public String toString() {
        return "Department{" +
                "deptId=" + deptId +
                ", deptName='" + deptName + '\'' +
                ", deptCode='" + deptCode + '\'' +
                '}';
    }
}
