//This model summarizes an employee's leave balance for dashboard display.
//It separates available, used, and pending days so the employee can quickly
//understand leave usage without opening the full leave history page.

package com.nimbus.admin.leave.model;

public class LeaveBalance {

    private int available;
    private int used;
    private int pending;

    public LeaveBalance() {
    }

    public LeaveBalance(int available, int used, int pending) {
        this.available = available;
        this.used = used;
        this.pending = pending;
    }

    public int getAvailable() {
        return available;
    }

    public void setAvailable(int available) {
        this.available = available;
    }

    public int getUsed() {
        return used;
    }

    public void setUsed(int used) {
        this.used = used;
    }

    public int getPending() {
        return pending;
    }

    public void setPending(int pending) {
        this.pending = pending;
    }
}
