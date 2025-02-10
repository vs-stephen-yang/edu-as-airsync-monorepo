package com.viewsonic.flutter_golang_server;

import java.util.List;
import java.util.Map;

import server.ConfigInfo;
import server.ICEServerConfig;

public class IonSfuUtil {

    // Adds multiple ICE server configurations to the given ConfigInfo instance.
    public static void addIceServers(ConfigInfo configInfo, List<Map<String, Object>> configs) {
        for (Map<String, Object> config : configs) {
            List<String> urls = (List<String>) config.get("urls");

            String username = (String) config.get("username");
            String credential = (String) config.get("credential");

            ICEServerConfig iceServerConfig = new ICEServerConfig();

            iceServerConfig.setUsername(username);
            iceServerConfig.setCredential(credential);
            for (String url : urls) {
                iceServerConfig.addURL(url);
            }
            configInfo.addICEServer(iceServerConfig);
        }
    }

}
