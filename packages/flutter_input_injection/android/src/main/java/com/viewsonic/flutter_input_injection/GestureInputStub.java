package com.viewsonic.flutter_input_injection;

import android.util.Log;
import android.content.Context;
import android.content.Intent;

public class GestureInputStub implements InputStub {
  private static final String TAG = "GestureInputStub";

  private final Context context;

  private boolean touchInProcess = false;
  private int currentTouchId = -1;

  private int lastX = 0;
  private int lastY = 0;

  public GestureInputStub(Context context) {
    this.context = context;
  }

  @Override
  public void InjectKeyEvent(int usbKeyCode, boolean pressed) {
    // Implementation for key event injection if needed
  }

  @Override
  public void InjectTouchStart(int id, int x, int y) {
    // If a gesture is already in process, ignore this new touch id.
    if (touchInProcess) {
      return;
    }

    // Start a new gesture
    touchInProcess = true;
    currentTouchId = id;

    lastX = x;
    lastY = y;

    simulateGesture(x, y, false, true);
  }

  @Override
  public void InjectTouchMove(int id, int x, int y) {
    // Process move events only if the id matches the current touch in process.
    if (!touchInProcess || id != currentTouchId) {
      return;
    }

    simulateGesture(x, y, true, true);

    lastX = x;
    lastY = y;
  }

  @Override
  public void InjectTouchEnd(int id) {
    // Process touch end only if the id matches the current touch in process.
    if (!touchInProcess || id != currentTouchId) {
      return;
    }

    simulateGesture(lastX, lastY, true, false);

    touchInProcess = false;
    currentTouchId = -1; // Reset touch id after processing
  }

  @Override
  public void Dispose() {
    // Clean up resources if needed
  }

  private void simulateGesture(int x, int y, boolean continuePrevious, boolean willContinue) {
    Intent intent = new Intent(context, GestureDispatchService.class);
    intent.setAction(Constants.ACTION_GESTURE);

    intent.putExtra("startX", lastX);
    intent.putExtra("startY", lastY);

    intent.putExtra("endX", x);
    intent.putExtra("endY", y);

    intent.putExtra("continuePrevious", continuePrevious);
    intent.putExtra("willContinue", willContinue);

    // Start the service with the prepared intent.
    context.startService(intent);
  }

}
