package com.mvbcast.crosswalk.vsapi;

import android.content.Context;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class VSApiHandler implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "com.mvbcast.crosswalk/vs_api";
    private final Context context;
    private final MethodChannel channel;
    private final VSApiDelegate delegate;

    public VSApiHandler(Context context, BinaryMessenger messenger) {
        this.context = context;
        this.channel = new MethodChannel(messenger, CHANNEL);
        this.channel.setMethodCallHandler(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            this.delegate = new VSApiDelegateImpl(context);
        } else {
            this.delegate = new VSApiEmptyDelegate();
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getSerialNumber":
                try {
                    result.success(delegate.getSerialNumber());
                } catch (Exception e) {
                    result.error("VS_API_ERROR", "Failed to get serial number", e.getMessage());
                }
                break;
            case "getEthernetMacAddress":
                try {
                    result.success(delegate.getEthernetMacAddress());
                } catch (Exception e) {
                    result.error("VS_API_ERROR", "Failed to get Ethernet MAC address", e.getMessage());
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    public void dispose() {
        channel.setMethodCallHandler(null);
    }
}
