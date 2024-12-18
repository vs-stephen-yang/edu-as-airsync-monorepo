package com.viewsonic.flutter_ion_sfu;

public interface IonSfuServerListener {
    public void onError(String error, String msg);

    public void onSignalMessage(long channelId, String message);

    public void onIceConnectionState(long channelId, long state);

}
