package com.viewsonic.flutter_multicast_plugin;

import androidx.annotation.Keep;

import java.net.NetworkInterface;
import java.net.InetAddress;
import java.util.Collections;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.List;

@Keep
public class NetworkUtils {
    public static List<String> getAllLocalIPv4s() {
        List<String> ipList = new ArrayList<>();

        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();

            for (NetworkInterface iface : Collections.list(interfaces)) {
                if (!iface.isUp() || iface.isLoopback()) continue;

                Enumeration<InetAddress> addresses = iface.getInetAddresses();
                for (InetAddress addr : Collections.list(addresses)) {
                    if (!addr.isLoopbackAddress() && addr instanceof java.net.Inet4Address) {
                        ipList.add(addr.getHostAddress());
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return ipList;
    }
}