//This interface defines the database operations required by the Leave module.
//Keeping SQL behind a DAO allows the service layer to own business rules while
//HR and Admin developers integrate through LeaveService instead of raw queries.

package com.nimbus.admin.leave.dao;

import com.nimbus.admin.leave.model.Leave;
import com.nimbus.admin.leave.model.LeaveStatus;
import com.nimbus.admin.leave.model.LeaveType;
import java.time.LocalDate;
import java.util.List;

public interface LeaveDao {

    List<LeaveType> findAllLeaveTypes();

    LeaveType findLeaveTypeById(int leaveTypeId);

    int insertLeave(Leave leave);

    Leave findById(int leaveId);

    List<Leave> findByEmployeeId(int empId, LeaveStatus statusFilter,
            Integer leaveTypeIdFilter);

    List<Leave> findRecentByEmployeeId(int empId, int limit);

    List<Leave> findAll(LeaveStatus statusFilter, String employeeSearch,
            Integer leaveTypeIdFilter, LocalDate fromDate, LocalDate toDate);

    List<Leave> findAllByDepartment(int departmentId, LeaveStatus statusFilter,
            String employeeSearch, Integer leaveTypeIdFilter,
            LocalDate fromDate, LocalDate toDate);

    Leave findByIdAndDepartment(int leaveId, int departmentId);

        Leave findByIdAndHrDepartment(int leaveId, int hrEmployeeId);

    List<Leave> findRecentActivity(int limit);

    boolean updateStatus(int leaveId, LeaveStatus status, Integer reviewedBy);

    boolean updateLeave(Leave leave);

    boolean hasOverlappingLeave(int empId, LocalDate fromDate, LocalDate toDate,
            Integer excludeLeaveId);

    int countByStatus(LeaveStatus status);

    int sumApprovedDaysForYear(int empId, int year);

    int sumPendingDays(int empId);

        void insertNotification(int empId, int leaveId, String message);
}
