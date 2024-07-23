package com.viewsonic.flutter_input_injection;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

// Implements InputStub and injects input events via UInput
public class InputInjectUInput implements InputStub {
  // key code mapping table
  private KeyCodeMap mKeyMap = new KeyCodeMap();

  private boolean mCloseDeviceOnDispose = false;

  private static final int MAX_SLOT = 9;
  private static final int MAX_TRACKING_ID = 1000;

  int mTrackingId = 0;
  Map<Integer, Integer> mIdSlotMapping = new HashMap<>();
  boolean[] mSlots = new boolean[MAX_SLOT];

  public InputInjectUInput(
      int width,
      int height) {
    assert width > 0;
    assert height > 0;

    if (UInput.init(MAX_TRACKING_ID, MAX_SLOT, width, height)) {
      mCloseDeviceOnDispose = true;
    }

    Arrays.fill(mSlots, false);
  }

  // inject keyboard events
  @Override
  public void InjectKeyEvent(int usbKeyCode, boolean pressed) {
    // convert usb key code to native key code
    int nativeKeyCode = mKeyMap.map(usbKeyCode);

    if (nativeKeyCode != 0) {
      UInput.injectKey(nativeKeyCode, pressed ? 1 : 0);
    }
  }

  @Override
  public void InjectTouchStart(int id, int x, int y) {
    int slot = AcquireSlot(id);
    if (slot < 0) {
      return;
    }

    mTrackingId = (mTrackingId + 1) % MAX_TRACKING_ID;

    UInput.injectTouchStart(slot, mTrackingId, x, y);

  }

  @Override
  public void InjectTouchMove(int id, int x, int y) {
    int slot = FindSlotById(id);
    if (slot < 0) {
      return;
    }

    UInput.injectTouchMove(slot, x, y);
  }

  @Override
  public void InjectTouchEnd(int id) {
    int slot = FindSlotById(id);
    if (slot < 0) {
      return;
    }

    ReleaseSlot(id, slot);
    UInput.injectTouchEnd(slot);
  }

  @Override
  public void Dispose() {
    if (mCloseDeviceOnDispose) {
      UInput.close();
    }
  }

  int FindSlotById(int id) {
    Integer slot = mIdSlotMapping.get(id);
    if (slot == null) {
      return -1;
    }
    assert mSlots[slot];

    return slot;
  }

  int AcquireSlot(int id) {
    // find a free slot
    int slot = FindFreeSlot();
    if (slot < 0) {
      return -1;
    }

    mSlots[slot] = true;
    mIdSlotMapping.put(id, slot);
    return slot;
  }

  void ReleaseSlot(int id, int slot) {
    assert slot >= 0;
    assert slot < mSlots.length;

    mSlots[slot] = false;
    mIdSlotMapping.remove(id);
  }

  int FindFreeSlot() {
    for (int i = 0; i < mSlots.length; ++i) {
      if (!mSlots[i]) {
        return i;
      }
    }
    return -1;
  }
}
