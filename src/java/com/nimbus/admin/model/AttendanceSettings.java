package com.nimbus.admin.model;

import java.time.LocalTime;

public class AttendanceSettings {
    private int settingId;
    private LocalTime officeStartTime;
    private LocalTime officeEndTime;
    private int lateThresholdMinutes;
    private double geofenceLatitude;
    private double geofenceLongitude;
    private int geofenceRadiusMeters;

    public AttendanceSettings() {
        // Default settings
        this.officeStartTime = LocalTime.of(9, 0);
        this.officeEndTime = LocalTime.of(18, 0);
        this.lateThresholdMinutes = 15;
        this.geofenceRadiusMeters = 100;
    }

    public int getSettingId() {
        return settingId;
    }

    public void setSettingId(int settingId) {
        this.settingId = settingId;
    }

    public LocalTime getOfficeStartTime() {
        return officeStartTime;
    }

    public void setOfficeStartTime(LocalTime officeStartTime) {
        this.officeStartTime = officeStartTime;
    }

    public LocalTime getOfficeEndTime() {
        return officeEndTime;
    }

    public void setOfficeEndTime(LocalTime officeEndTime) {
        this.officeEndTime = officeEndTime;
    }

    public int getLateThresholdMinutes() {
        return lateThresholdMinutes;
    }

    public void setLateThresholdMinutes(int lateThresholdMinutes) {
        this.lateThresholdMinutes = lateThresholdMinutes;
    }

    public double getGeofenceLatitude() {
        return geofenceLatitude;
    }

    public void setGeofenceLatitude(double geofenceLatitude) {
        this.geofenceLatitude = geofenceLatitude;
    }

    public double getGeofenceLongitude() {
        return geofenceLongitude;
    }

    public void setGeofenceLongitude(double geofenceLongitude) {
        this.geofenceLongitude = geofenceLongitude;
    }

    public int getGeofenceRadiusMeters() {
        return geofenceRadiusMeters;
    }

    public void setGeofenceRadiusMeters(int geofenceRadiusMeters) {
        this.geofenceRadiusMeters = geofenceRadiusMeters;
    }
}
