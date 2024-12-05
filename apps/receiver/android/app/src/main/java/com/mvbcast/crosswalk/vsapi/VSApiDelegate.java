package com.mvbcast.crosswalk.vsapi;

interface VSApiDelegate {
    String getSerialNumber() throws Exception;

    String getCurrentMacAddress() throws Exception;
}