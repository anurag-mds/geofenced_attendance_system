package com.nimbus.admin.dao;

import com.nimbus.admin.model.RemoteWork;
import com.nimbus.admin.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RemoteWorkDAO {

    // =========================================================
    // EMPLOYEE: APPLY FOR WORK FROM HOME
    // =========================================================

    public boolean applyRemoteWork(RemoteWork remoteWork) {

        String sql =
                "INSERT INTO remote_work_approvals "
              + "(emp_id, start_date, end_date, approved_by, status) "
              + "VALUES (?, ?, ?, NULL, 'PENDING')";

        try {

            Connection con = DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ps.setInt(
                    1,
                    remoteWork.getEmpId()
            );

            ps.setDate(
                    2,
                    remoteWork.getStartDate()
            );

            ps.setDate(
                    3,
                    remoteWork.getEndDate()
            );

            int rows = ps.executeUpdate();

            ps.close();
            con.close();

            return rows > 0;

        } catch (Exception e) {

            System.out.println(
                    "ERROR IN APPLY REMOTE WORK:"
            );

            e.printStackTrace();

            return false;
        }
    }


    // =========================================================
    // EMPLOYEE: GET THEIR WFH REQUESTS
    // =========================================================

    public List<RemoteWork> getEmployeeRequests(
            int empId) {

        List<RemoteWork> requests =
                new ArrayList<>();

        String sql =
                "SELECT remote_id, emp_id, start_date, "
              + "end_date, approved_by, status, requested_on "
              + "FROM remote_work_approvals "
              + "WHERE emp_id = ? "
              + "ORDER BY requested_on DESC, remote_id DESC";

        try {

            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ps.setInt(1, empId);

            ResultSet rs =
                    ps.executeQuery();

            while (rs.next()) {

                RemoteWork remoteWork =
                        new RemoteWork();

                remoteWork.setRemoteId(
                        rs.getInt("remote_id")
                );

                remoteWork.setEmpId(
                        rs.getInt("emp_id")
                );

                remoteWork.setStartDate(
                        rs.getDate("start_date")
                );

                remoteWork.setEndDate(
                        rs.getDate("end_date")
                );

                // approved_by can be NULL
                int approvedBy =
                        rs.getInt("approved_by");

                if (rs.wasNull()) {
                    remoteWork.setApprovedBy(0);
                } else {
                    remoteWork.setApprovedBy(
                            approvedBy
                    );
                }

                remoteWork.setStatus(
                        rs.getString("status")
                );

                remoteWork.setRequestedOn(
                        rs.getDate("requested_on")
                );

                requests.add(remoteWork);
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {

            System.out.println(
                    "ERROR IN GET EMPLOYEE REMOTE WORK:"
            );

            e.printStackTrace();
        }

        return requests;
    }


    // =========================================================
    // HR: GET ALL PENDING WFH REQUESTS
    // =========================================================

    public List<RemoteWork> getPendingRequests() {

        List<RemoteWork> requests =
                new ArrayList<>();

        String sql =
                "SELECT remote_id, emp_id, start_date, "
              + "end_date, approved_by, status, requested_on "
              + "FROM remote_work_approvals "
              + "WHERE status = 'PENDING' "
              + "ORDER BY requested_on ASC, remote_id ASC";

        try {

            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery();

            while (rs.next()) {

                RemoteWork remoteWork =
                        new RemoteWork();

                remoteWork.setRemoteId(
                        rs.getInt("remote_id")
                );

                remoteWork.setEmpId(
                        rs.getInt("emp_id")
                );

                remoteWork.setStartDate(
                        rs.getDate("start_date")
                );

                remoteWork.setEndDate(
                        rs.getDate("end_date")
                );

                int approvedBy =
                        rs.getInt("approved_by");

                if (rs.wasNull()) {
                    remoteWork.setApprovedBy(0);
                } else {
                    remoteWork.setApprovedBy(
                            approvedBy
                    );
                }

                remoteWork.setStatus(
                        rs.getString("status")
                );

                remoteWork.setRequestedOn(
                        rs.getDate("requested_on")
                );

                requests.add(remoteWork);
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {

            System.out.println(
                    "ERROR IN GET PENDING REMOTE WORK:"
            );

            e.printStackTrace();
        }

        return requests;
    }

// =========================================================
// HR: GET ALL WFH REQUESTS
// =========================================================

public List<RemoteWork> getAllRequests() {

    List<RemoteWork> requests =
            new ArrayList<>();


    String sql =
            "SELECT remote_id, emp_id, start_date, "
          + "end_date, approved_by, status, requested_on "
          + "FROM remote_work_approvals "
          + "ORDER BY requested_on DESC, remote_id DESC";


    try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
    ) {


        while (rs.next()) {

            RemoteWork remoteWork =
                    new RemoteWork();


            remoteWork.setRemoteId(
                    rs.getInt("remote_id")
            );


            remoteWork.setEmpId(
                    rs.getInt("emp_id")
            );


            remoteWork.setStartDate(
                    rs.getDate("start_date")
            );


            remoteWork.setEndDate(
                    rs.getDate("end_date")
            );


            int approvedBy =
                    rs.getInt("approved_by");


            if (rs.wasNull()) {

                remoteWork.setApprovedBy(0);

            } else {

                remoteWork.setApprovedBy(
                        approvedBy
                );

            }


            remoteWork.setStatus(
                    rs.getString("status")
            );


            remoteWork.setRequestedOn(
                    rs.getDate("requested_on")
            );


            requests.add(remoteWork);
        }


    } catch (Exception e) {

        System.out.println(
                "ERROR IN GET ALL REMOTE WORK:"
        );

        e.printStackTrace();
    }


    return requests;
}


// =========================================================
// HR: GET WFH REQUESTS BY STATUS
// =========================================================

public List<RemoteWork> getRequestsByStatus(
        String status) {

    List<RemoteWork> requests =
            new ArrayList<>();


    String sql =
            "SELECT remote_id, emp_id, start_date, "
          + "end_date, approved_by, status, requested_on "
          + "FROM remote_work_approvals "
          + "WHERE status = ? "
          + "ORDER BY requested_on DESC, remote_id DESC";


    try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
    ) {


        ps.setString(
                1,
                status
        );


        try (ResultSet rs =
                     ps.executeQuery()) {


            while (rs.next()) {

                RemoteWork remoteWork =
                        new RemoteWork();


                remoteWork.setRemoteId(
                        rs.getInt("remote_id")
                );


                remoteWork.setEmpId(
                        rs.getInt("emp_id")
                );


                remoteWork.setStartDate(
                        rs.getDate("start_date")
                );


                remoteWork.setEndDate(
                        rs.getDate("end_date")
                );


                int approvedBy =
                        rs.getInt("approved_by");


                if (rs.wasNull()) {

                    remoteWork.setApprovedBy(0);

                } else {

                    remoteWork.setApprovedBy(
                            approvedBy
                    );

                }


                remoteWork.setStatus(
                        rs.getString("status")
                );


                remoteWork.setRequestedOn(
                        rs.getDate("requested_on")
                );


                requests.add(remoteWork);
            }
        }


    } catch (Exception e) {

        System.out.println(
                "ERROR IN GET REMOTE WORK BY STATUS:"
        );

        e.printStackTrace();
    }


    return requests;
}


// =========================================================
// HR: GET ONE WFH REQUEST
// =========================================================

public RemoteWork getRequestById(
        int remoteId) {


    String sql =
            "SELECT remote_id, emp_id, start_date, "
          + "end_date, approved_by, status, requested_on "
          + "FROM remote_work_approvals "
          + "WHERE remote_id = ?";


    try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
    ) {


        ps.setInt(
                1,
                remoteId
        );


        try (ResultSet rs =
                     ps.executeQuery()) {


            if (rs.next()) {

                RemoteWork remoteWork =
                        new RemoteWork();


                remoteWork.setRemoteId(
                        rs.getInt("remote_id")
                );


                remoteWork.setEmpId(
                        rs.getInt("emp_id")
                );


                remoteWork.setStartDate(
                        rs.getDate("start_date")
                );


                remoteWork.setEndDate(
                        rs.getDate("end_date")
                );


                int approvedBy =
                        rs.getInt("approved_by");


                if (rs.wasNull()) {

                    remoteWork.setApprovedBy(0);

                } else {

                    remoteWork.setApprovedBy(
                            approvedBy
                    );

                }


                remoteWork.setStatus(
                        rs.getString("status")
                );


                remoteWork.setRequestedOn(
                        rs.getDate("requested_on")
                );


                return remoteWork;
            }
        }


    } catch (Exception e) {

        System.out.println(
                "ERROR IN GET REMOTE WORK BY ID:"
        );

        e.printStackTrace();
    }


    return null;
}
    // =========================================================
    // HR: APPROVE WFH REQUEST
    // =========================================================

    public boolean approveRequest(
            int remoteId,
            int hrId) {

        String sql =
                "UPDATE remote_work_approvals "
              + "SET status = 'APPROVED', "
              + "approved_by = ? "
              + "WHERE remote_id = ? "
              + "AND status = 'PENDING'";

        try {

            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ps.setInt(1, hrId);
            ps.setInt(2, remoteId);

            int rows =
                    ps.executeUpdate();

            ps.close();
            con.close();

            return rows > 0;

        } catch (Exception e) {

            System.out.println(
                    "ERROR IN APPROVE REMOTE WORK:"
            );

            e.printStackTrace();

            return false;
        }
    }


    // =========================================================
    // HR: REJECT WFH REQUEST
    // =========================================================

    public boolean rejectRequest(
            int remoteId,
            int hrId) {

        String sql =
                "UPDATE remote_work_approvals "
              + "SET status = 'REJECTED', "
              + "approved_by = ? "
              + "WHERE remote_id = ? "
              + "AND status = 'PENDING'";

        try {

            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ps.setInt(1, hrId);
            ps.setInt(2, remoteId);

            int rows =
                    ps.executeUpdate();

            ps.close();
            con.close();

            return rows > 0;

        } catch (Exception e) {

            System.out.println(
                    "ERROR IN REJECT REMOTE WORK:"
            );

            e.printStackTrace();

            return false;
        }
    }
    
}