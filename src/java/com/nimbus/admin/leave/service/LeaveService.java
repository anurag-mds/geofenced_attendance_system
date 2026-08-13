//This interface is the single contract for leave business operations.
//Employee, HR, and Admin code should call these methods so validation,
//status transitions, and authorization rules stay in one shared place.

package com.nimbus.admin.leave.service;

import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveBalance;
import com.nimbus.admin.leave.model.LeaveStatistics;
import com.nimbus.admin.leave.model.LeaveStatus;
import com.nimbus.admin.leave.model.LeaveType;
import java.time.LocalDate;
import java.util.List;

public interface LeaveService {

    int ANNUAL_LEAVE_ALLOWANCE = 20;

    List<LeaveType> getLeaveTypes();

    // Employee operations
    int applyLeave(int empId, int leaveTypeId, LocalDate fromDate,
            LocalDate toDate, String reason) throws LeaveServiceException;

    List<Leave> getEmployeeLeaveHistory(int empId, LeaveStatus statusFilter,
            Integer leaveTypeIdFilter);

    Leave getEmployeeLeaveById(int empId, int leaveId)
            throws LeaveServiceException;

    void cancelLeave(int empId, int leaveId) throws LeaveServiceException;

    void modifyLeave(int empId, int leaveId, int leaveTypeId,
            LocalDate fromDate, LocalDate toDate, String reason)
            throws LeaveServiceException;

    LeaveBalance getLeaveBalance(int empId);

    List<Leave> getRecentLeaveRequests(int empId, int limit);

    // HR operations
    List<Leave> getLeaveRequests(LeaveStatus statusFilter, String employeeSearch,
            Integer leaveTypeIdFilter, LocalDate fromDate, LocalDate toDate);

    Leave getLeaveById(int leaveId);

    void markUnderReview(int leaveId, int hrEmpId, String remark)
            throws LeaveServiceException;

    void approveLeave(int leaveId, int hrEmpId, String remark)
            throws LeaveServiceException;

    void rejectLeave(int leaveId, int hrEmpId, String remark)
            throws LeaveServiceException;

    // Admin operations
    List<Leave> getAllLeaveRecords(LeaveStatus statusFilter,
            String employeeSearch, Integer leaveTypeIdFilter,
            LocalDate fromDate, LocalDate toDate);

    LeaveStatistics getLeaveStatistics();

    List<Leave> getRecentLeaveActivity(int limit);
}
