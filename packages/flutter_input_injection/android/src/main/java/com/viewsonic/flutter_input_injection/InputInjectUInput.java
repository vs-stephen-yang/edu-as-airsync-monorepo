package com.viewsonic.flutter_input_injection;

// Implements InputStub and injects input events via UInput
public class InputInjectUInput implements InputStub {
  private boolean mCloseDeviceOnDispose = false;

  public InputInjectUInput(
      int width,
      int height) {
    assert width > 0;
    assert height > 0;

    if (UInput.init(width, height)) {
      mCloseDeviceOnDispose = true;
    }
  }

  @Override
  public void InjectSingleTouch(
      int x,
      int y,
      TouchEventType eventType) {

    UInput.injectSingleTouch(
        x,
        y,
        eventType.ordinal());
  }

  @Override
  public void Dispose() {
    if (mCloseDeviceOnDispose) {
      UInput.close();
    }
  }
}
