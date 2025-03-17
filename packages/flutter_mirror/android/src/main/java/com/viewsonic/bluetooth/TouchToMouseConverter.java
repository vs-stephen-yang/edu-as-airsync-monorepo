package com.viewsonic.bluetooth;

import com.viewsonic.bluetooth.hid.HidAbsMouseReport;
import com.viewsonic.bluetooth.hid.HidRelMouseReport;
import com.viewsonic.bluetooth.hid.HidReport;

import java.util.HashMap;

public class TouchToMouseConverter {

  private static final int INVALID_TOUCH_ID = -1;
  private static final int HID_MAX_VALUE = 32767;

  private double lastX = 0.0;
  private double lastY = 0.0;
  private boolean lastTouchState = false;
  private int lastTouchId = INVALID_TOUCH_ID;

  public interface TouchToMouseConverterListener {
    void onHidReportReady(HidReport report);
  }

  TouchToMouseConverterListener listener;

  public TouchToMouseConverter(TouchToMouseConverterListener listener) {
    this.listener = listener;
  }

  public boolean touch(int touchId, boolean isTouching, double x, double y) {
    if (isRedundantTouch(touchId, isTouching, x, y)) {
      return false;
    }

    if (lastTouchId != INVALID_TOUCH_ID && lastTouchId != touchId) {
      return false; // Only support single touch
    }

    sendHidReports(x, y, isTouching);
    updateLastTouchState(touchId, isTouching, x, y);

    return true;
  }

  private boolean isRedundantTouch(int touchId, boolean isTouching, double x, double y) {
    return lastX == x && lastY == y && lastTouchId == touchId && lastTouchState == isTouching;
  }

  private void sendHidReports(double x, double y, boolean isTouching) {
    listener.onHidReportReady(createMouseMoveReport(x, y));
    listener.onHidReportReady(createMouseStateReport(isTouching));
  }

  private void updateLastTouchState(int touchId, boolean isTouching, double x, double y) {
    lastX = x;
    lastY = y;
    lastTouchState = isTouching;
    lastTouchId = isTouching ? touchId : INVALID_TOUCH_ID;
  }

  public HidReport createMouseMoveReport(double touchX, double touchY) {
    int targetX = (int) (touchX * HID_MAX_VALUE); // see HidConfig.ABS_MOUSE_X_MAX
    int targetY = (int) (touchY * HID_MAX_VALUE); // see HidConfig.ABS_MOUSE_Y_MAX
    HidAbsMouseReport mouseReport = new HidAbsMouseReport();
    mouseReport.setState(targetX, targetY, 0, false, false, false);
    return mouseReport;
  }

  public HidReport createMouseStateReport(boolean touchDown) {
    HidRelMouseReport mouseReport = new HidRelMouseReport();
    mouseReport.setState(0, 0, 0, touchDown, false, false);
    return mouseReport;
  }

}
