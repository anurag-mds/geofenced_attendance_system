//This exception carries user-facing leave validation and workflow errors.
//The service layer throws it for business rule failures so servlets can show
//a clear message without exposing low-level database exception details.

package com.nimbus.admin.leave.service;

public class LeaveServiceException extends Exception {

    public LeaveServiceException(String message) {
        super(message);
    }
}
