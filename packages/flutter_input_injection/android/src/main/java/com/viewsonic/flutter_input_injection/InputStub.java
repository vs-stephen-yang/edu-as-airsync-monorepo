package com.viewsonic.flutter_input_injection;

// Input stub is responsible for handling input
public interface InputStub {

  void InjectKeyEvent(int usbKeyCode, boolean pressed);

  void InjectTouchStart(int id, int x, int y);

  void InjectTouchMove(int id, int x, int y);

  void InjectTouchEnd(int id);

  void Dispose();
}
