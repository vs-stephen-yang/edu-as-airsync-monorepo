package com.viewsonic.flutter_mirror;

import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class NetUtils {

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

      return formatMacAddress(first.getHardwareAddress());
    } catch (java.net.SocketException e) {
      return null;
    }
  }

}
