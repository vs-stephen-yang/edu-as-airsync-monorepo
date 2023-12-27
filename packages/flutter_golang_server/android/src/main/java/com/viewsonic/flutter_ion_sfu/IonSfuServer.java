package com.viewsonic.flutter_ion_sfu;

import java.util.Map;
import ionsfu.Ionsfu;

public class IonSfuServer {
    private static final String TAG = "IonSfuServer";

    public void initialize() {
        ionsfu.Ionsfu.initialize();
    }

    public boolean start(Map<String, Object> configuration) {
        try {
            ionsfu.Ionsfu.startServer();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

    }

    public void stop() {
        ionsfu.Ionsfu.stopServer();
    }
}
