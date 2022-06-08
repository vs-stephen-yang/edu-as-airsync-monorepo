package com.mvbcast.crosswalk.view;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;
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
    @NonNull
    @Override
    public PlatformView create(@Nullable Context context, int viewId, @Nullable Object args) {
        return new WebRTCNativeView(context, mActivity, viewId, mMessenger);
    }
    //-------------------------------------------------------------------------
    // endregion

}
