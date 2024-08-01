package com.viewsonic.flutter_input_injection;

public class PortraitInputStub implements InputStub {
  private InputStub mInputStub;
  private int mHeight;

  PortraitInputStub(
    InputStub inputStub,
    int height) {
    assert inputStub != null;
    assert height > 0;

    mHeight = height;
    mInputStub = inputStub;
  }

  // rotate 90 degree clockwise
  private int rotateY(int x, int y) {
    return Math.max(mHeight - x, 0);
  }

  // rotate 90 degree clockwise
  private int rotateX(int x, int y) {
    return y;
  }

  @Override
  public void InjectKeyEvent(
    int usbKeyCode,
    boolean pressed) {
    mInputStub.InjectKeyEvent(
      usbKeyCode,
      pressed);
  }

  @Override
  public void InjectTouchStart(
    int id,
    int x,
    int y) {
    mInputStub.InjectTouchStart(
      id,
      rotateX(x, y),
      rotateY(x, y));
  }

  @Override
  public void InjectTouchMove(
    int id,
    int x,
    int y) {
    mInputStub.InjectTouchMove(
      id,
      rotateX(x, y),
      rotateY(x, y));
  }

  @Override
  public void InjectTouchEnd(
    int id) {
    mInputStub.InjectTouchEnd(id);
  }

  @Override
  public void Dispose() {
  }
}
