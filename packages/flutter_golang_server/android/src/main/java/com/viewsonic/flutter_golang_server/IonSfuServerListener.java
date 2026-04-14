package com.viewsonic.flutter_golang_server;

import androidx.annotation.Keep;

@Keep
public interface IonSfuServerListener {
    void onError(String error, String msg);

    void onSignalMessage(long channelId, String message);

    void onIceConnectionState(long channelId, long state);

}
