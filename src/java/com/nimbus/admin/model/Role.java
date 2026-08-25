//This enum represents all valid user roles in the system.
//It ensures that only predefined roles can be assigned to an employee,
//providing type safety and preventing invalid role values.

package com.nimbus.admin.model;

public enum Role {
    ADMIN,
    HR,
    EMPLOYEE
}
