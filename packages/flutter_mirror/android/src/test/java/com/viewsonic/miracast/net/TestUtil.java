package com.viewsonic.miracast.net;

import java.nio.ByteBuffer;

public class TestUtil {
  static byte[] readBytes(ByteBuffer bb, int size) {
    byte[] arr = new byte[size];
    bb.get(arr);
    return arr;
  }
}
