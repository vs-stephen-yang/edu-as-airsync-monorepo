package com.viewsonic.flutter_input_injection;

import java.util.HashMap;
import java.util.Map;

// mapping between usb codes and native key codes
public class KeyCodeMap {
  private Map<Integer, Integer> mMap;

  public KeyCodeMap() {
    mMap = createMap();
  }

  // convert usb code to Linux native key code
  public int map(int usbKeyCode) {
    Integer nativeKeyCode = mMap.get(usbKeyCode);
    return nativeKeyCode != null ? nativeKeyCode : 0;
  }

  // https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
  // https://chromium.googlesource.com/chromium/src/+/dff16958029d9a8fb9004351f72e961ed4143e83/ui/events/keycodes/dom/keycode_converter_data.inc
  // https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values
  private static Map<Integer, Integer> createMap() {
    Map<Integer, Integer> map = new HashMap<Integer, Integer>();
    map.put(0x070004, 30); // A
    map.put(0x070005, 48);
    map.put(0x070006, 46);
    map.put(0x070007, 32);
    map.put(0x070008, 18);
    map.put(0x070009, 33);
    map.put(0x07000a, 34);
    map.put(0x07000b, 35);
    map.put(0x07000c, 23);
    map.put(0x07000d, 36);
    map.put(0x07000e, 37);
    map.put(0x07000f, 38);
    map.put(0x070010, 50);
    map.put(0x070011, 49); // N
    map.put(0x070012, 24);
    map.put(0x070013, 25);
    map.put(0x070014, 16);
    map.put(0x070015, 19);
    map.put(0x070016, 31);
    map.put(0x070017, 20);
    map.put(0x070018, 22);
    map.put(0x070019, 47);
    map.put(0x07001a, 17);
    map.put(0x07001b, 45);
    map.put(0x07001c, 21);
    map.put(0x07001d, 44); // Z
    map.put(0x07001e, 2); // 1
    map.put(0x07001f, 3);
    map.put(0x070020, 4);
    map.put(0x070021, 5);
    map.put(0x070022, 6);
    map.put(0x070023, 7);
    map.put(0x070024, 8);
    map.put(0x070025, 9);
    map.put(0x070026, 10); // 9
    map.put(0x070027, 11); // 0
    map.put(0x070028, 28); // Enter
    map.put(0x070029, 1); // Escape
    map.put(0x07002a, 14); // Backspace
    map.put(0x07002b, 15); // TAB
    map.put(0x07002c, 57); // Space
    map.put(0x07002d, 12); // Minus
    map.put(0x07002e, 13); // Equal
    map.put(0x07002f, 26); // BracketLeft
    map.put(0x070030, 27); // BracketRight
    map.put(0x070031, 43); // Backslash
    map.put(0x070033, 39); // Semicolon
    map.put(0x070034, 40); // Quote
    map.put(0x070035, 41); // Backquote, Grave
    map.put(0x070036, 51); // Comma
    map.put(0x070037, 52); // Period
    map.put(0x070038, 53); // Slash
    map.put(0x070039, 58); // CapsLock
    map.put(0x07003a, 59); // F1
    map.put(0x07003b, 60);
    map.put(0x07003c, 61);
    map.put(0x07003d, 62);
    map.put(0x07003e, 63);
    map.put(0x07003f, 64);
    map.put(0x070040, 65);
    map.put(0x070041, 66);
    map.put(0x070042, 67);
    map.put(0x070043, 68); // F10
    map.put(0x070044, 87); // F11
    map.put(0x070045, 88); // F12
    map.put(0x070047, 70); // ScrollLock
    // map.put(0x070048, 0); // Pause
    map.put(0x070049, 110); // Insert
    map.put(0x07004a, 102); // Home
    map.put(0x07004b, 104); // PageUp
    map.put(0x07004c, 111); // Delete
    map.put(0x07004d, 107); // End
    map.put(0x07004e, 109); // PageDown
    map.put(0x07004f, 106); // ArrowRight
    map.put(0x070050, 105); // ArrowLeft
    map.put(0x070051, 108); // ArrowDown
    map.put(0x070052, 103); // ArrowUp
    // keypad
    map.put(0x070053, 69); // NumLock
    map.put(0x070054, 98); // Keypad_Divide
    map.put(0x070055, 55); // Keypad_*
    map.put(0x070058, 96); // Keypad_Enter

    map.put(0x070059, 79); // Keypad_1
    map.put(0x07005a, 80); // Keypad_2
    map.put(0x07005b, 81); // Keypad_3
    map.put(0x07005c, 75); // Keypad_4
    map.put(0x07005d, 76); // Keypad_5
    map.put(0x07005e, 77); // Keypad_6
    map.put(0x07005f, 71); // Keypad_7
    map.put(0x070060, 72); // Keypad_8
    map.put(0x070061, 73); // Keypad_9
    map.put(0x070062, 82); // Keypad_0

    map.put(0x0700e0, 29); // ControlLeft
    map.put(0x0700e1, 42); // ShiftLeft
    map.put(0x0700e2, 56); // AltLeft
    map.put(0x0700e3, 125); // MetaLeft
    map.put(0x0700e4, 97); // ControlRight
    map.put(0x0700e5, 54); // ShiftRight
    map.put(0x0700e6, 100); // AltRight
    map.put(0x0700e7, 126); // MetaRight
    return map;
  }
}
