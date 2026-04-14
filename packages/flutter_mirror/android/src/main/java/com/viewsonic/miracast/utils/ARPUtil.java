package com.viewsonic.miracast.utils;

import java.io.BufferedReader;
import java.io.FileReader;
import android.util.Log;

/**
 *
 * /proc/net/arp example
 * IP address HW type Flags HW address Mask Device
 * 192.168.49.208 0x1 0x2 a2:0b:ba:ba:c4:d1 * p2p-wlan0-8
 *
 */
public class ARPUtil {
  private final static String TAG = "MiraARPUtil";

  public static String getIPFromMac(String macAddr,String interfaceName) {
    /* check macAddr format */
    if (macAddr == null || macAddr.length() != 17) {
      Log.e(TAG, "getIPFromMac error: macAddr format error");
      return "";
    }

    String ipAddr = null;
    String line = null;
    try {
      BufferedReader reader = new BufferedReader(new FileReader("/proc/net/arp"));
      while ((line = reader.readLine()) != null) {
        String[] splitted = line.split(" +");
        if (splitted != null && splitted.length >= 6) {
          String mac = splitted[3];
          String device = splitted[5];
          if (mac.matches("..:..:..:..:..:..")) {
            if (device.contains(interfaceName)) {
              int mismatchCount = 0;
              for (int i = 0; i < macAddr.length(); i++) {
                if (macAddr.charAt(i) != mac.charAt(i)) {
                  mismatchCount++;
                }
              }
              if (mismatchCount <= 2) {
                ipAddr = splitted[0];
                break;
              }
            }
          }
        }
      }
      reader.close();
    } catch (Exception e) {
      Log.e(TAG, "getIPFromMac error:" + e.toString());
      return "";
    }
    return ipAddr;
  }
}
