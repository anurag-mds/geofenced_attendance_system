//This model holds aggregate leave counts for the admin overview screen.
//It lets the admin monitor workflow volume without granting approval rights
//that belong exclusively to HR in the leave decision process.

package com.nimbus.admin.leave.model;

public class LeaveStatistics {

    private int totalRequests;
    private int pending;
    private int approved;
    private int rejected;
    private int cancelled;

    public LeaveStatistics() {
    }

    public LeaveStatistics(int totalRequests, int pending, int approved,
            int rejected, int cancelled) {
        this.totalRequests = totalRequests;
        this.pending = pending;
        this.approved = approved;
        this.rejected = rejected;
        this.cancelled = cancelled;
    }

    public int getTotalRequests() {
        return totalRequests;
    }

    public void setTotalRequests(int totalRequests) {
        this.totalRequests = totalRequests;
    }

    public int getPending() {
        return pending;
    }

    public void setPending(int pending) {
        this.pending = pending;
    }

    public int getApproved() {
        return approved;
    }

    public void setApproved(int approved) {
        this.approved = approved;
    }

    public int getRejected() {
        return rejected;
    }

    public void setRejected(int rejected) {
        this.rejected = rejected;
    }

    public int getCancelled() {
        return cancelled;
    }

    public void setCancelled(int cancelled) {
        this.cancelled = cancelled;
    }
}
