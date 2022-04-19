package com.mvbcast.crosswalk.view;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.mvbcast.crosswalk.helper.WebRTCHelper;

import org.webrtc.SurfaceViewRenderer;

import java.util.Observable;
import java.util.Observer;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class WebRTCNativeViewFactory extends PlatformViewFactory {
    private final Activity mActivity;
    private final BinaryMessenger mMessenger;

    public WebRTCNativeViewFactory(Activity activity, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        mActivity = activity;
        mMessenger = messenger;
    }

    // region PlatformViewFactory
    //-------------------------------------------------------------------------
    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new WebRTCNativeView(context, mActivity, viewId, mMessenger);
    }
    //-------------------------------------------------------------------------
    // endregion

}
