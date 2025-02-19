package com.viewsonic.flutter_golang_server;

import java.util.List;
import java.util.Map;

import server.Server;
import server.WebTransportConfig;
import server.WebTransportListener;


public class WebtransportServer implements WebTransportListener {
    private final WebtransportServerListener webtransportServerListener_;

    public WebtransportServer(WebtransportServerListener webtransportServerListener) {
        assert (webtransportServerListener != null);
        webtransportServerListener_ = webtransportServerListener;
    }

    public void start(Map<String, Object> configuration) throws Exception {
        WebTransportConfig config = new WebTransportConfig();

        if (configuration.containsKey("port")) {
            config.setPort((int) configuration.get("port"));
        }

        Map<String, byte[]> certMap = WebtransportUtil.generateCertSlice(configuration);
        config.setInitCert(certMap.get(WebtransportUtil.CERT_PEM));
        config.setInitKey(certMap.get(WebtransportUtil.KEY_PEM));

        if (configuration.containsKey("allowOrigins")) {
            List<String> allowOriginConfigs = (List<String>) configuration.get("allowOrigins");
            WebtransportUtil.addAllowOrigins(config, allowOriginConfigs);
        }

        Server.registerWebTransportListener(this);
        Server.startWebTransportServer(config);
    }

    public void stop() {
        server.Server.stopWebTransportServer();
    }

    public void sendMessage(String connId, String message) {
        Server.sendMessage(connId, message);
    }

    public void updateCertificate(Map<String, Object> configuration) {
        Map<String, byte[]> certMap = WebtransportUtil.generateCertSlice(configuration);
        Server.updateCertificate(certMap.get(WebtransportUtil.CERT_PEM), certMap.get(WebtransportUtil.KEY_PEM));
    }

    public void closeConn(String connId) {
        Server.closeWebTransportConn(connId);
    }

    @Override
    public void onMessage(String connId, String message) {
        webtransportServerListener_.onMessage(connId, message);
    }

    public void onClose(String connId) {
        webtransportServerListener_.onClose(connId);
    }

    public void onConnect(String connId, String queryStr, String clientIp) {
        webtransportServerListener_.onConnect(connId, queryStr, clientIp);
    }

    @Override
    public void onError(String connId, Exception e) {
        webtransportServerListener_.onError(connId, e);
    }
}
