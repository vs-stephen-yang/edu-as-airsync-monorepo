package com.viewsonic.flutter_ion_sfu;

import java.util.Map;

import ionsfu.IonSfuListener;

public class IonSfuServer implements IonSfuListener {
    private static final String TAG = "IonSfuServer";

    private IonSfuServerListener ionSfuServerListener_;

    public IonSfuServer(IonSfuServerListener ionSfuServerListener) {
        assert (ionSfuServerListener != null);
        ionSfuServerListener_ = ionSfuServerListener;
    }

    public void initialize() {
        ionsfu.Ionsfu.initialize();
    }

    public boolean start(Map<String, Object> configuration) {
        try {
            ionsfu.Ionsfu.registerListener(this);
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

    @Override
    public void onError(String error, String msg) {
        ionSfuServerListener_.onError(error, msg);
    }
}
