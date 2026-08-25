package com.nimbus.admin.dao;

/**
 * Enum representing different login result states
 * Used to provide specific error messages to users
 */
public enum LoginResult {
    SUCCESS,
    WRONG_PASSWORD,
    USER_NOT_FOUND,
    INACTIVE_USER,
    DB_ERROR
}
