package com.viewsonic.flutter_golang_server;

public interface WebtransportServerListener {
    void onMessage(String connId, String message);

    void onClose(String connId);

    void onConnect(String connId, String queryStr, String clientIp);

    void onError(String connId, Exception e);
}
