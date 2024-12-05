package com.mvbcast.crosswalk.vsapi;

public class VSApiEmptyDelegate implements VSApiDelegate {
    @Override
    public String getSerialNumber() {
        return "Not supported on Android API < 26";
    }

    @Override
    public String getCurrentMacAddress() {
        return "Not supported on Android API < 26";
    }
}