package com.mvbcast.crosswalk.view;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mvbcast.crosswalk.R;

import java.util.ArrayList;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class WebRTCNativeViewFactory extends PlatformViewFactory {
    private final Activity mActivity;
    private final BinaryMessenger mMessenger;
    private final int[] mAllRenderId = {
            R.id.remoteRenderMain,
            R.id.remoteRenderSub1,
            R.id.remoteRenderSub2,
            R.id.remoteRenderSub3,
    };
    private final ArrayList<Integer> mRenderUsedList = new ArrayList<>();

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
        int selectedId = R.id.remoteRenderMain;
        for (int layoutId : mAllRenderId) {
            if (!mRenderUsedList.contains(layoutId)) {
                selectedId = layoutId;
                break;
            }
        }
        mRenderUsedList.add(selectedId);
        return new WebRTCNativeView(mActivity, viewId, mMessenger, mRenderUsedList, selectedId);
    }
    //-------------------------------------------------------------------------
    // endregion

}
