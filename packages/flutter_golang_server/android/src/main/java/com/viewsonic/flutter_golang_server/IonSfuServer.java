package com.viewsonic.flutter_golang_server;

import java.util.List;
import java.util.Map;

import server.ConfigInfo;
import server.IonSfuListener;

public class IonSfuServer implements IonSfuListener {
    private static final String TAG = "IonSfuServer";

    private final IonSfuServerListener ionSfuServerListener_;

    public IonSfuServer(IonSfuServerListener ionSfuServerListener) {
        assert (ionSfuServerListener != null);
        ionSfuServerListener_ = ionSfuServerListener;
    }

    public void initialize() {
        server.Server.initialize();
    }

    public boolean start(Map<String, Object> configuration) {
        ConfigInfo configInfo = new ConfigInfo();

        if (configuration.containsKey("ballast")) {
            configInfo.setBallast((int) configuration.get("ballast"));
        }
        if (configuration.containsKey("withStats")) {
            configInfo.setWithStats((boolean) configuration.get("withStats"));
        }
        if (configuration.containsKey("maxBandwidth")) {
            configInfo.setMaxBandwidth((int) configuration.get("maxBandwidth"));
        }
        if (configuration.containsKey("maxPacketTrack")) {
            configInfo.setMaxPacketTrack((int) configuration.get("maxPacketTrack"));
        }
        if (configuration.containsKey("audioLevelThreshold")) {
            configInfo.setAudioLevelThreshold((int) configuration.get("audioLevelThreshold"));
        }
        if (configuration.containsKey("audioLevelInterval")) {
            configInfo.setAudioLevelInterval((int) configuration.get("audioLevelInterval"));
        }
        if (configuration.containsKey("audioLevelFilter")) {
            configInfo.setAudioLevelFilter((int) configuration.get("audioLevelFilter"));
        }
        if (configuration.containsKey("bestQualityFirst")) {
            configInfo.setBestQualityFirst((boolean) configuration.get("bestQualityFirst"));
        }
        if (configuration.containsKey("enableTemporalLayer")) {
            configInfo.setEnableTemporalLayer((boolean) configuration.get("enableTemporalLayer"));
        }
        if (configuration.containsKey("icePortRangeStart")) {
            configInfo.setICEPortRangeStart((int) configuration.get("icePortRangeStart"));
        }
        if (configuration.containsKey("icePortRangeEnd")) {
            configInfo.setICEPortRangeEnd((int) configuration.get("icePortRangeEnd"));
        }
        if (configuration.containsKey("sdpSemantics")) {
            configInfo.setSDPSemantics((String) configuration.get("sdpSemantics"));
        }
        if (configuration.containsKey("mdns")) {
            configInfo.setMDNS((boolean) configuration.get("mdns"));
        }
        if (configuration.containsKey("iceDisconnectedTimeout")) {
            configInfo.setICEDisconnectedTimeout((int) configuration.get("iceDisconnectedTimeout"));
        }
        if (configuration.containsKey("iceFailedTimeout")) {
            configInfo.setICEFailedTimeout((int) configuration.get("iceFailedTimeout"));
        }
        if (configuration.containsKey("iceKeepaliveInterval")) {
            configInfo.setICEKeepaliveInterval((int) configuration.get("iceKeepaliveInterval"));
        }
        if (configuration.containsKey("credentials")) {
            configInfo.setCredentials((String) configuration.get("credentials"));
        }

        if (configuration.containsKey("iceServers")) {
            List<Map<String, Object>> iceServerConfigs = (List<Map<String, Object>>) configuration.get("iceServers");
            IonSfuUtil.addIceServers(configInfo, iceServerConfigs);
        }

        try {
            server.Server.registerListener(this);
            server.Server.startServer(configInfo);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

    }

    public void stop() {
        server.Server.stopServer();
    }

    public long createSignalChannel() {
        return server.Server.createSignalChannel();
    }

    public void closeSignalChannel(long channelId) {
        server.Server.closeSignalChannel(channelId);
    }

    public void processSignalMessage(long channelId, String message) {
        server.Server.processSignalMessage(channelId, message);
    }

    @Override
    public void onError(String error, String msg) {
        ionSfuServerListener_.onError(error, msg);
    }

    @Override
    public void onSignalMessage(long channelId, String message) {
        ionSfuServerListener_.onSignalMessage(channelId, message);
    }

    @Override
    public void onIceConnectionState(long channelId, long state) {
        ionSfuServerListener_.onIceConnectionState(channelId, state);
    }
}
