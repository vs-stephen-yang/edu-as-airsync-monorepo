package com.viewsonic.bluetooth.hid;

public class HidConfig {
  // Device Information
  public static final String DEVICE_NAME = "AirSync";
  public static final String DESCRIPTION = "HID Device";
  public static final String PROVIDER = "HID Provider";

  // Report Identifiers
  public static final byte ABS_MOUSE_REPORT_ID = 0x01;  // Absolute-positioning mouse
  public static final byte REL_MOUSE_REPORT_ID = 0x02;  // Relative-positioning mouse

  // HID Descriptor
  public static final byte[] HID_DESCRIPTOR = {
    (byte) 0x05, (byte) 0x01,  // Usage Page (Generic Desktop Controls)

    // ======= Absolute Positioning Mouse (Report ID 1) =======
    (byte) 0x09, (byte) 0x02,  // Usage (Mouse)
    (byte) 0xA1, (byte) 0x01,  // Collection (Application)
    (byte) 0x85, (byte) 0x01,  //   Report ID (ABS_MOUSE_REPORT_ID)

    (byte) 0x09, (byte) 0x01,  //   Usage (Pointer)
    (byte) 0xA1, (byte) 0x00,  //   Collection (Physical)

    // Mouse Buttons
    (byte) 0x05, (byte) 0x09,  //     Usage Page (Button)
    (byte) 0x19, (byte) 0x01,  //     Usage Minimum (Button 1)
    (byte) 0x29, (byte) 0x03,  //     Usage Maximum (Button 3)
    (byte) 0x15, (byte) 0x00,  //     Logical Minimum (0)
    (byte) 0x25, (byte) 0x01,  //     Logical Maximum (1)
    (byte) 0x95, (byte) 0x03,  //     Report Count (3 buttons)
    (byte) 0x75, (byte) 0x01,  //     Report Size (1-bit per button)
    (byte) 0x81, (byte) 0x02,  //     Input (Data, Variable, Absolute)
    (byte) 0x95, (byte) 0x01,  //     Report Count (1)
    (byte) 0x75, (byte) 0x05,  //     Report Size (5-bit padding)
    (byte) 0x81, (byte) 0x03,  //     Input (Constant, Variable, Absolute)

    // X, Y Absolute Position (0 - 32767)
    (byte) 0x05, (byte) 0x01,  //     Usage Page (Generic Desktop Controls)
    (byte) 0x09, (byte) 0x30,  //     Usage (X)
    (byte) 0x09, (byte) 0x31,  //     Usage (Y)
    (byte) 0x15, (byte) 0x00,  //     Logical Minimum (0)
    (byte) 0x26, (byte) 0xFF, (byte) 0x7F,  // Logical Maximum (32767)
    (byte) 0x75, (byte) 0x10,  //     Report Size (16-bit)
    (byte) 0x95, (byte) 0x02,  //     Report Count (2) (X, Y)
    (byte) 0x81, (byte) 0x02,  //     Input (Data, Variable, Absolute)

    (byte) 0xC0,  //   End Collection
    (byte) 0xC0,  // End Collection

    // ======= Relative Positioning Mouse (Report ID 2) =======
    (byte) 0x05, (byte) 0x01,  // Usage Page (Generic Desktop Controls)
    (byte) 0x09, (byte) 0x02,  // Usage (Mouse)
    (byte) 0xA1, (byte) 0x01,  // Collection (Application)
    (byte) 0x85, (byte) 0x02,  //   Report ID (REL_MOUSE_REPORT_ID)

    (byte) 0x09, (byte) 0x01,  //   Usage (Pointer)
    (byte) 0xA1, (byte) 0x00,  //   Collection (Physical)

    // Mouse Buttons (same as Absolute Mouse)
    (byte) 0x05, (byte) 0x09,  //     Usage Page (Button)
    (byte) 0x19, (byte) 0x01,  //     Usage Minimum (Button 1)
    (byte) 0x29, (byte) 0x03,  //     Usage Maximum (Button 3)
    (byte) 0x15, (byte) 0x00,  //     Logical Minimum (0)
    (byte) 0x25, (byte) 0x01,  //     Logical Maximum (1)
    (byte) 0x95, (byte) 0x03,  //     Report Count (3 buttons)
    (byte) 0x75, (byte) 0x01,  //     Report Size (1-bit per button)
    (byte) 0x81, (byte) 0x02,  //     Input (Data, Variable, Absolute)
    (byte) 0x95, (byte) 0x01,  //     Report Count (1)
    (byte) 0x75, (byte) 0x05,  //     Report Size (5-bit padding)
    (byte) 0x81, (byte) 0x03,  //     Input (Constant, Variable, Absolute)

    // X, Y Relative Movement (-127 to +127)
    (byte) 0x05, (byte) 0x01,  //     Usage Page (Generic Desktop Controls)
    (byte) 0x09, (byte) 0x30,  //     Usage (X)
    (byte) 0x09, (byte) 0x31,  //     Usage (Y)
    (byte) 0x15, (byte) 0x81,  //     Logical Minimum (-127)
    (byte) 0x25, (byte) 0x7F,  //     Logical Maximum (127)
    (byte) 0x75, (byte) 0x08,  //     Report Size (8-bit)
    (byte) 0x95, (byte) 0x02,  //     Report Count (2) (X, Y)
    (byte) 0x81, (byte) 0x06,  //     Input (Data, Variable, Relative)

    (byte) 0xC0,  //   End Collection
    (byte) 0xC0   // End Collection
  };
}
