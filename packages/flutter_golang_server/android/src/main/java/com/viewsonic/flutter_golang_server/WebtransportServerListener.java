package com.viewsonic.flutter_golang_server;

public interface WebtransportServerListener {
    void onMessage(String clientId, String message);

    void onClose(String clientId);

    void onConnect(String clientId, String queryStr);
}
