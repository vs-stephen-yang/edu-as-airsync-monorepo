package com.viewsonic.bluetooth.hid;

public class HidRelMouseReport extends HidReport {

  public HidRelMouseReport() {
    super(DeviceType.RELATIVE_MOUSE, HidConfig.REL_MOUSE_REPORT_ID, new byte[] {0, 0, 0, 0}); // 4 bytes
  }

  public void setState(int dx, int dy, int wheel, boolean leftButton, boolean rightButton, boolean middleButton) {
    byte buttonState = 0;

    if (leftButton) buttonState |= 1;
    if (rightButton) buttonState |= 2;
    if (middleButton) buttonState |= 4;

    reportData[0] = buttonState;
    reportData[1] = (byte) Math.max(-127, Math.min(127, dx));
    reportData[2] = (byte) Math.max(-127, Math.min(127, dy));
    reportData[3] = (byte) Math.max(-127, Math.min(127, wheel));
  }
}
