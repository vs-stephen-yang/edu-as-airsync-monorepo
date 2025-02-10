package com.viewsonic.flutter_golang_server;

import org.json.JSONArray;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import server.WebTransportConfig;


public class WebtransportUtil {
    public static final String CERT_PEM = "certPEM";
    public static final String KEY_PEM = "keyPEM";

    public static void addAllowOrigins(WebTransportConfig config, List<String> allowOrigins) {
        for (String url : allowOrigins) {
            config.addAllowOrigin(url);
        }
    }

    public static Map<String, byte[]> generateCertSlice(Map<String, Object> configuration) {
        Map<String, byte[]> certMap = new HashMap<>();

        ArrayList<String> certList = (ArrayList<String>) configuration.get("cert");
        ArrayList<String> keyList = (ArrayList<String>) configuration.get("key");

        // Convert ArrayLists to JSON arrays
        JSONArray certJsonArray = new JSONArray(certList);
        JSONArray keyJsonArray = new JSONArray(keyList);

        // Pass JSON arrays as byte[] to Go
        byte[] certPEM = certJsonArray.toString().getBytes(StandardCharsets.UTF_8);
        byte[] keyPEM = keyJsonArray.toString().getBytes(StandardCharsets.UTF_8);

        certMap.put(CERT_PEM, certPEM);
        certMap.put(KEY_PEM, keyPEM);
        return certMap;
    }
}
