//This model represents one row from the leave_types lookup table.
//Leave types are loaded from the database so the module stays aligned with
//the project's default schema instead of hard-coding enum values in Java.

package com.nimbus.admin.leave.model;

public class LeaveType {

    private int leaveTypeId;
    private String typeName;

    public LeaveType() {
    }

    public LeaveType(int leaveTypeId, String typeName) {
        this.leaveTypeId = leaveTypeId;
        this.typeName = typeName;
    }

    public int getLeaveTypeId() {
        return leaveTypeId;
    }

    public void setLeaveTypeId(int leaveTypeId) {
        this.leaveTypeId = leaveTypeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getDisplayName() {
        return typeName;
    }
}
