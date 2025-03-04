package com.viewsonic.flutter_input_injection;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.GestureDescription;
import android.content.Intent;
import android.graphics.Path;
import android.os.Build;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;

import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class GestureDispatchService extends AccessibilityService {

  private static final String TAG = "GestureDispatchService";

  // Holds the last stroke used for gesture continuation.
  // This field is used when a gesture segment should continue the previous
  // stroke.
  private GestureDescription.StrokeDescription lastStroke = null;

  // Thread-safe queue of pending gestures.
  // Each gesture in this list represents a segment of a continuous gesture.
  private List<GestureDescription> pendingGestures = new ArrayList<>();

  @Override
  public void onServiceConnected() {
    super.onServiceConnected();
    Log.d(TAG, "AccessibilityService has been connected and is now active.");
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    // Check if the intent is valid and if it contains the correct action.
    if (intent == null ||
        !Constants.ACTION_GESTURE.equalsIgnoreCase(intent.getAction())) {
      Log.w(TAG, "Received null intent or unknown action");
      return START_STICKY;
    }

    // Check that the device is running at least API level O (26)
    // since some functionality in addGesture requires it.
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      return START_STICKY;
    }

    // Extract gesture coordinates and flags from the intent extras.
    int startX = intent.getIntExtra("startX", 0);
    int startY = intent.getIntExtra("startY", 0);
    int endX = intent.getIntExtra("endX", startX);
    int endY = intent.getIntExtra("endY", startY);

    // continuePrevious indicates whether to continue the last stroke.
    boolean continuePrevious = intent.getBooleanExtra("continuePrevious", false);
    // willContinue indicates if this stroke should be marked as ongoing.
    boolean willContinue = intent.getBooleanExtra("willContinue", false);

    // Build a new gesture segment based on the provided parameters.
    addGesture(startX, startY, endX, endY, continuePrevious, willContinue);

    // Attempt to dispatch the gesture
    tryDispatchGesture();

    return START_STICKY;
  }

  /**
   * Checks if there's exactly one gesture in the queue and dispatches it.
   * This method requires API level N (24) or higher.
   */
  @RequiresApi(api = Build.VERSION_CODES.N)
  private void tryDispatchGesture() {
    // If the queue has only one gesture, dispatch it immediately.
    if (pendingGestures.size() == 1) {
      dispatchNextGesture();
    }
  }

  /**
   * Dispatches the next gesture in the pendingGestures queue.
   * Once the gesture is completed or cancelled, it is removed from the queue,
   * and if additional gestures remain, the next one is dispatched.
   * This method requires API level N (24) or higher.
   */
  @RequiresApi(api = Build.VERSION_CODES.N)
  private void dispatchNextGesture() {
    GestureDescription nextGesture = pendingGestures.get(0);

    // Dispatch the gesture at the front of the queue.
    boolean result = dispatchGesture(nextGesture, new GestureResultCallback() {
      @Override
      public void onCompleted(GestureDescription gestureDescription) {
        dequeueAndDispatchNextGesture();

        super.onCompleted(gestureDescription);
      }

      @Override
      public void onCancelled(GestureDescription gestureDescription) {
        dequeueAndDispatchNextGesture();

        super.onCancelled(gestureDescription);
      }
    }, null);

    // Log if dispatching the gesture failed.
    if (!result) {
      Log.w(TAG, "dispatchGesture failed");
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  private void dequeueAndDispatchNextGesture() {
    if (pendingGestures.isEmpty()) {
      return;
    }

    // Remove the current gesture from the queue
    pendingGestures.remove(0);

    // If there are more gestures pending, dispatch the next one.
    if (!pendingGestures.isEmpty()) {
      dispatchNextGesture();
    }
  }

  /**
   * Builds a gesture segment and adds it to the pendingGestures queue.
   * The segment is defined by the starting and ending coordinates, as well as
   * flags
   * that indicate whether to continue from a previous stroke and if the stroke
   * will continue.
   *
   * This method requires API level O (26) or higher.
   *
   * @param startX           Starting X coordinate.
   * @param startY           Starting Y coordinate.
   * @param endX             Ending X coordinate.
   * @param endY             Ending Y coordinate.
   * @param continuePrevious If true, the stroke will continue from the last
   *                         stroke.
   * @param willContinue     If true, the stroke is marked as continuing after
   *                         this segment.
   */
  @RequiresApi(api = Build.VERSION_CODES.O)
  private void addGesture(
      int startX, int startY,
      int endX, int endY,
      boolean continuePrevious,
      boolean willContinue) {
    // Set the start time and duration for the gesture segment.
    long startTime = 0;
    long duration = 1;

    // Create a new Path for the gesture segment.
    Path path = new Path();
    path.moveTo(startX, startY);
    if (startX != endX || startY != endY) {
      // If the gesture involves movement, add a line to the end coordinates.
      path.lineTo(endX, endY);
    }

    GestureDescription.StrokeDescription stroke;
    if (!continuePrevious || lastStroke == null) {
      // Start a new stroke if not continuing from a previous one.
      stroke = new GestureDescription.StrokeDescription(path, startTime, duration, willContinue);
    } else {
      // Continue the previous stroke using the continueStroke() method.
      stroke = this.lastStroke.continueStroke(path, startTime, duration, willContinue);
    }

    // Build the gesture description from the stroke.
    GestureDescription.Builder builder = new GestureDescription.Builder();
    builder.addStroke(stroke);
    GestureDescription gesture = builder.build();

    // Update lastStroke for potential continuation.
    this.lastStroke = stroke;

    // Add the gesture to the queue of pending gestures.
    pendingGestures.add(gesture);
  }

  @Override
  public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
    // No accessibility events are handled in this service.
  }

  @Override
  public void onInterrupt() {
    // Handle service interruption if needed.
  }
}
