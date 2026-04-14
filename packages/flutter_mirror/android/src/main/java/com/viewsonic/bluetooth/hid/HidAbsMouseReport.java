package com.viewsonic.bluetooth.hid;

public class HidAbsMouseReport extends HidReport {

  public HidAbsMouseReport() {
    super(DeviceType.ABSOLUTE_MOUSE, HidConfig.ABS_MOUSE_REPORT_ID, new byte[] {0, 0, 0, 0, 0}); // 5 bytes
  }

  public void setState(int x, int y, int wheel, boolean leftButton, boolean rightButton, boolean middleButton) {
    byte buttonState = 0;

    if (leftButton) {
      buttonState |= 1;
    } else {
      buttonState &= ~1;
    }
    if (rightButton) {
      buttonState |= 2;
    } else {
      buttonState &= ~2;
    }
    if (middleButton) {
      buttonState |= 4;
    } else {
      buttonState &= ~4;
    }

    reportData[0] = buttonState;

    x = Math.max(0, Math.min(32767, x));
    reportData[1] = (byte) (x & 0xFF);
    reportData[2] = (byte) ((x >> 8) & 0xFF);

    y = Math.max(0, Math.min(32767, y));
    reportData[3] = (byte) (y & 0xFF);
    reportData[4] = (byte) ((y >> 8) & 0xFF);
  }
}
