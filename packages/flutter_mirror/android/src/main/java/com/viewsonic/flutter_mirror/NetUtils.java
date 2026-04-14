package com.viewsonic.flutter_mirror;

import java.net.NetworkInterface;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class NetUtils {

  static final int MAC_SIZE = 6; // 6-byte

  // returns true if the interface is up and not a loopback one.
  public static boolean IsUpPhysical(NetworkInterface intf)
      throws java.net.SocketException {

    return intf.isUp() &&
        !intf.isLoopback();
  }

  // returns a list of network interfaces that are up and running
  public static List<NetworkInterface> getUpInterfaces()
      throws java.net.SocketException {

    List<NetworkInterface> interfaces = Collections.list(NetworkInterface.getNetworkInterfaces());

    List<NetworkInterface> results = new ArrayList<>();

    for (NetworkInterface intf : interfaces) {
      if (IsUpPhysical(intf)) {
        results.add(intf);
      }
    }
    return results;

  }

  public static String formatMacAddress(byte[] bytes) {
    List<String> elements = new ArrayList<>();

    // format each byte
    for (byte b : bytes) {
      elements.add(String.format("%02X", b));
    }

    // join each byte with ':'
    return String.join(":", elements);
  }

  // returns the MAC address of the first interface that is up and running.
  public static String getMacAddressOfFirstUpInterface() {
    try {
      List<NetworkInterface> interfaces = getUpInterfaces();

      if (interfaces.isEmpty()) {
        return null;
      }

      NetworkInterface first = interfaces.get(0);

      // on Android versions 6 and higher, access to MAC addresses is restricted to
      // system apps. Third-party apps can't access them.
      return formatMacAddress(first.getHardwareAddress());
    } catch (java.net.SocketException e) {
      return null;
    }
  }

  public static String getRandomMacAddress() {
    SecureRandom random = new SecureRandom();

    byte bytes[] = new byte[MAC_SIZE];
    random.nextBytes(bytes);

    return formatMacAddress(bytes);
  }
}
