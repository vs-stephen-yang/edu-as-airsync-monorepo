package com.viewsonic.bluetooth.hid;

public class HidReport {

  public enum DeviceType {
    ABSOLUTE_MOUSE, RELATIVE_MOUSE
  }

  protected final byte reportId;
  protected final DeviceType deviceType;
  protected byte[] reportData;

  public HidReport(DeviceType deviceType, byte reportId, byte[] data) {
    this.deviceType = deviceType;
    this.reportId = reportId;
    this.reportData = data;
  }

  public byte[] getReportData() {
    return reportData;
  }

  public byte getReportId() {
    return reportId;
  }
}
