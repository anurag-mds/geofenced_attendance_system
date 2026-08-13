//This class contains the core leave workflow and validation rules.
//Servlets call it for every leave action so illegal transitions, overlapping
//requests, and invalid input are blocked before any database update occurs.

package com.nimbus.admin.leave.service;

import com.nimbus.admin.leave.dao.LeaveDao;
import com.nimbus.admin.leave.dao.LeaveDaoImpl;
import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveBalance;
import com.nimbus.admin.leave.model.LeaveStatistics;
import com.nimbus.admin.leave.model.LeaveStatus;
import com.nimbus.admin.leave.model.LeaveType;
import java.time.LocalDate;
import java.util.List;

public class LeaveServiceImpl implements LeaveService {

    private final LeaveDao leaveDao;

    public LeaveServiceImpl() {
        this.leaveDao = new LeaveDaoImpl();
    }

    public LeaveServiceImpl(LeaveDao leaveDao) {
        this.leaveDao = leaveDao;
    }

    @Override
    public List<LeaveType> getLeaveTypes() {
        return leaveDao.findAllLeaveTypes();
    }

    @Override
    public int applyLeave(int empId, int leaveTypeId, LocalDate fromDate,
            LocalDate toDate, String reason) throws LeaveServiceException {

        LeaveType leaveType = requireLeaveType(leaveTypeId);
        validateLeaveInput(leaveType, fromDate, toDate, reason);

        if (leaveDao.hasOverlappingLeave(empId, fromDate, toDate, null)) {
            throw new LeaveServiceException(
                    "You already have a leave request that overlaps these dates.");
        }

        Leave leave = new Leave();
        leave.setEmpId(empId);
        leave.setLeaveType(leaveType);
        leave.setFromDate(fromDate);
        leave.setToDate(toDate);
        leave.setNumDays(Leave.calculateNumDays(fromDate, toDate));
        leave.setReason(reason.trim());
        leave.setStatus(LeaveStatus.SUBMITTED);

        int leaveId = leaveDao.insertLeave(leave);
        if (leaveId <= 0) {
            throw new LeaveServiceException(
                    "Failed to submit leave request. Please try again.");
        }
        return leaveId;
    }

    @Override
    public List<Leave> getEmployeeLeaveHistory(int empId, LeaveStatus statusFilter,
            Integer leaveTypeIdFilter) {
        return leaveDao.findByEmployeeId(empId, statusFilter, leaveTypeIdFilter);
    }

    @Override
    public Leave getEmployeeLeaveById(int empId, int leaveId)
            throws LeaveServiceException {
        Leave leave = leaveDao.findById(leaveId);
        if (leave == null) {
            throw new LeaveServiceException("Leave request not found.");
        }
        if (leave.getEmpId() != empId) {
            throw new LeaveServiceException(
                    "You are not authorized to view this leave request.");
        }
        return leave;
    }

    @Override
    public void cancelLeave(int empId, int leaveId) throws LeaveServiceException {
        Leave leave = getEmployeeLeaveById(empId, leaveId);

        if (!leave.getStatus().isEmployeeCancellable()) {
            throw new LeaveServiceException(
                    "This leave request cannot be cancelled in its current status.");
        }

        boolean updated = leaveDao.updateStatus(leaveId, LeaveStatus.CANCELLED, null);
        if (!updated) {
            throw new LeaveServiceException(
                    "Failed to cancel leave request. Please try again.");
        }
    }

    @Override
    public void modifyLeave(int empId, int leaveId, int leaveTypeId,
            LocalDate fromDate, LocalDate toDate, String reason)
            throws LeaveServiceException {

        Leave existing = getEmployeeLeaveById(empId, leaveId);

        if (!existing.getStatus().isEmployeeModifiable()) {
            throw new LeaveServiceException(
                    "This leave request cannot be modified after HR has acted on it.");
        }

        LeaveType leaveType = requireLeaveType(leaveTypeId);
        validateLeaveInput(leaveType, fromDate, toDate, reason);

        if (leaveDao.hasOverlappingLeave(empId, fromDate, toDate, leaveId)) {
            throw new LeaveServiceException(
                    "You already have a leave request that overlaps these dates.");
        }

        Leave updated = new Leave();
        updated.setLeaveId(leaveId);
        updated.setEmpId(empId);
        updated.setLeaveType(leaveType);
        updated.setFromDate(fromDate);
        updated.setToDate(toDate);
        updated.setNumDays(Leave.calculateNumDays(fromDate, toDate));
        updated.setReason(reason.trim());

        if (!leaveDao.updateLeave(updated)) {
            throw new LeaveServiceException(
                    "Failed to update leave request. Please try again.");
        }
    }

    @Override
    public LeaveBalance getLeaveBalance(int empId) {
        int year = LocalDate.now().getYear();
        int used = leaveDao.sumApprovedDaysForYear(empId, year);
        int pending = leaveDao.sumPendingDays(empId);
        int available = Math.max(0, ANNUAL_LEAVE_ALLOWANCE - used - pending);

        return new LeaveBalance(available, used, pending);
    }

    @Override
    public List<Leave> getRecentLeaveRequests(int empId, int limit) {
        return leaveDao.findRecentByEmployeeId(empId, limit);
    }

    @Override
    public List<Leave> getLeaveRequests(LeaveStatus statusFilter,
            String employeeSearch, Integer leaveTypeIdFilter,
            LocalDate fromDate, LocalDate toDate) {
        return leaveDao.findAll(statusFilter, employeeSearch, leaveTypeIdFilter,
                fromDate, toDate);
    }

    @Override
    public Leave getLeaveById(int leaveId) {
        return leaveDao.findById(leaveId);
    }

    @Override
    public void markUnderReview(int leaveId, int hrEmpId, String remark)
            throws LeaveServiceException {
        transitionHrStatus(leaveId, hrEmpId, remark, LeaveStatus.UNDER_REVIEW,
                false, null);
    }

    @Override
    public void approveLeave(int leaveId, int hrEmpId, String remark)
            throws LeaveServiceException {
        transitionHrStatus(leaveId, hrEmpId, remark, LeaveStatus.APPROVED, false,
                "Your leave request has been approved.");
    }

    @Override
    public void rejectLeave(int leaveId, int hrEmpId, String remark)
            throws LeaveServiceException {
        if (remark == null || remark.trim().isEmpty()) {
            throw new LeaveServiceException(
                    "Rejection reason is required when rejecting a leave request.");
        }
        transitionHrStatus(leaveId, hrEmpId, remark.trim(), LeaveStatus.REJECTED,
                true, "Your leave request has been rejected: " + remark.trim());
    }

    @Override
    public List<Leave> getAllLeaveRecords(LeaveStatus statusFilter,
            String employeeSearch, Integer leaveTypeIdFilter,
            LocalDate fromDate, LocalDate toDate) {
        return leaveDao.findAll(statusFilter, employeeSearch, leaveTypeIdFilter,
                fromDate, toDate);
    }

    @Override
    public LeaveStatistics getLeaveStatistics() {
        int submitted = leaveDao.countByStatus(LeaveStatus.SUBMITTED);
        int underReview = leaveDao.countByStatus(LeaveStatus.UNDER_REVIEW);
        int approved = leaveDao.countByStatus(LeaveStatus.APPROVED);
        int rejected = leaveDao.countByStatus(LeaveStatus.REJECTED);
        int cancelled = leaveDao.countByStatus(LeaveStatus.CANCELLED);
        int pending = submitted + underReview;
        int total = pending + approved + rejected + cancelled;

        return new LeaveStatistics(total, pending, approved, rejected, cancelled);
    }

    @Override
    public List<Leave> getRecentLeaveActivity(int limit) {
        return leaveDao.findRecentActivity(limit);
    }

    private void transitionHrStatus(int leaveId, int hrEmpId, String remark,
            LeaveStatus targetStatus, boolean remarkRequired,
            String notificationMessage) throws LeaveServiceException {

        Leave leave = leaveDao.findById(leaveId);
        if (leave == null) {
            throw new LeaveServiceException("Leave request not found.");
        }

        if (!leave.getStatus().isHrActionable()) {
            throw new LeaveServiceException(
                    "Cannot perform this action on a leave request with status: "
                    + leave.getStatus().getDisplayName());
        }

        if (remarkRequired && (remark == null || remark.trim().isEmpty())) {
            throw new LeaveServiceException("HR remark is required for this action.");
        }

        if (remark != null && !remark.trim().isEmpty()) {
            leave.setHrRemark(remark.trim());
        }

        boolean updated = leaveDao.updateStatus(leaveId, targetStatus, hrEmpId);
        if (!updated) {
            throw new LeaveServiceException(
                    "Failed to update leave request status. Please try again.");
        }

        if (notificationMessage != null) {
            leaveDao.insertNotification(leave.getEmpId(), notificationMessage);
        }
    }

    private LeaveType requireLeaveType(int leaveTypeId) throws LeaveServiceException {
        LeaveType leaveType = leaveDao.findLeaveTypeById(leaveTypeId);
        if (leaveType == null) {
            throw new LeaveServiceException("Please select a valid leave type.");
        }
        return leaveType;
    }

    private void validateLeaveInput(LeaveType leaveType, LocalDate fromDate,
            LocalDate toDate, String reason) throws LeaveServiceException {

        if (leaveType == null) {
            throw new LeaveServiceException("Please select a leave type.");
        }
        if (fromDate == null) {
            throw new LeaveServiceException("From date is required.");
        }
        if (toDate == null) {
            throw new LeaveServiceException("To date is required.");
        }
        LocalDate today = LocalDate.now();
        if (fromDate.isBefore(today) || toDate.isBefore(today)) {
            throw new LeaveServiceException(
                    "Leave dates must be today or in the future.");
        }
        if (fromDate.isAfter(toDate)) {
            throw new LeaveServiceException(
                    "From date cannot be after To date.");
        }
        if (reason == null || reason.trim().isEmpty()) {
            throw new LeaveServiceException("Reason is required.");
        }
    }
}
