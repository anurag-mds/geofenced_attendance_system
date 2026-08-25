//This enum defines the controlled lifecycle states for a leave request.
//It maps application workflow states onto the database enum values
//(PENDING, APPROVED, REJECTED, CANCELLED) used in leave_requests.

package com.nimbus.admin.leave.model;

public enum LeaveStatus {
    SUBMITTED,
    UNDER_REVIEW,
    APPROVED,
    REJECTED,
    CANCELLED;

    public boolean isEmployeeCancellable() {
        return this == SUBMITTED;
    }

    public boolean isEmployeeModifiable() {
        return this == SUBMITTED;
    }

    public boolean isHrActionable() {
        return this == SUBMITTED || this == UNDER_REVIEW;
    }

    public String getDisplayName() {
        return switch (this) {
            case SUBMITTED -> "Submitted";
            case UNDER_REVIEW -> "Under Review";
            case APPROVED -> "Approved";
            case REJECTED -> "Rejected";
            case CANCELLED -> "Cancelled";
        };
    }

    public String toDatabaseValue() {
        return switch (this) {
            case SUBMITTED, UNDER_REVIEW -> "PENDING";
            default -> name();
        };
    }

    public static LeaveStatus fromDatabase(String dbStatus, Integer reviewedBy) {
        if ("PENDING".equals(dbStatus)) {
            return reviewedBy != null ? UNDER_REVIEW : SUBMITTED;
        }
        return valueOf(dbStatus);
    }
}
