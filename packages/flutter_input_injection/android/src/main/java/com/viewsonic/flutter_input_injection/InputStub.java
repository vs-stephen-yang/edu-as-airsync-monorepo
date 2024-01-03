package com.viewsonic.flutter_input_injection;

// Input stub is responsible for handling input
public interface InputStub {

  void InjectSingleTouch(int x, int y, TouchEventType eventType);

  void Dispose();
}
