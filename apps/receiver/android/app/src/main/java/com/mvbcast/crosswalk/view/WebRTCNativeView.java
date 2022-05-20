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
import io.flutter.plugin.platform.PlatformView;

public class WebRTCNativeView implements PlatformView, MethodChannel.MethodCallHandler, Observer {
    private final Activity mActivity;
    private final SurfaceViewRenderer surfaceViewRenderer;
    private final MethodChannel methodChannel;

    WebRTCNativeView(Context context, Activity activity, int id, BinaryMessenger messenger) {
        mActivity = activity;
        Log.e("_TAG_", "NativeWebRTCView create id: " + id);
        surfaceViewRenderer = new SurfaceViewRenderer(context);
        methodChannel =
                new MethodChannel(messenger, "com.mvbcast.crosswalk/webrtc_native_view_" + id);
        methodChannel.setMethodCallHandler(this);

        WebRTCHelper.getInstance().initWebRTCP2PClient(mActivity,
                surfaceViewRenderer,
                (videoWidth, videoHeight, rotation) -> mActivity.runOnUiThread(() -> {
                    // TODO: Adjust screen aspect ratio.
//                    String ratioVideoString = String.format(Locale.ENGLISH, "%d:%d", videoWidth, videoHeight);
//                    // adjust aspect ratio dominated by ConstraintLayout
//                    // https://stackoverflow.com/questions/41265570/constraintlayout-aspect-ratio
//                    // https://stackoverflow.com/questions/12343376/set-view-width-programmatically
//                    ConstraintSet constraintSet = new ConstraintSet();
//                    constraintSet.clone((ConstraintLayout) findViewById(R.id.parentLayout));
//                    constraintSet.setDimensionRatio(mRemoteRenderer.getId(), ratioVideoString);
//                    constraintSet.applyTo(findViewById(R.id.parentLayout));
                }));

//        WebRTCHelper.getInstance().processGetDisplayCode("EC53FEC106F6433A82FA2F223A6C7F99");
    }

    // region PlatformView
    //-------------------------------------------------------------------------
    @Override
    public View getView() {
        Log.e("_TAG_", "getView");
        return surfaceViewRenderer;
    }

    @Override
    public void dispose() {
        Log.e("_TAG_", "dispose");
    }
    //-------------------------------------------------------------------------
    // endregion

    // region MethodCallHandler
    //-------------------------------------------------------------------------
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.e("_TAG_", "onMethodCall: " + call.method + " object:" + call.arguments().toString());
        if ("setText".equals(call.method)) {
            result.success(null);
        } else if ("connectControlSocket".equals(call.method)) {
            WebRTCHelper.WebRTCInfo webRTCInfo = WebRTCHelper.getInstance().getWebRTCInfo();
            webRTCInfo.InstanceId = call.argument("id");
            webRTCInfo.DisplayCode = call.argument("displayCode");
            webRTCInfo.Token = call.argument("token");
            webRTCInfo.LicenseName = call.argument("name");
            WebRTCHelper.getInstance().connectControlSocket(webRTCInfo.DisplayCode);
        } else if ("disconnectP2pClient".equals(call.method)) {
            WebRTCHelper.getInstance().disconnectP2pClient();
        } else {
            result.notImplemented();
        }
    }
    //-------------------------------------------------------------------------
    // endregion

    // region Observer
    //-------------------------------------------------------------------------
    @Override
    public void update(Observable o, Object arg) {
        if (o instanceof WebRTCHelper) {
            Log.d("zz update ", "o: "+ (o != null? o.toString(): "") + " arg: "+ (arg != null? arg.toString():""));
            if (arg != null && arg.equals("startConnectTimeOutTimer")) {
                startConnectTimeOutTimer(WebRTCHelper.getInstance().getmAllowId());
            }
        }
    }
    //-------------------------------------------------------------------------
    // endregion

    // region private method
    //-------------------------------------------------------------------------
    private void startConnectTimeOutTimer(String allowId) {
        methodChannel.invokeMethod("startConnectTimeOutTimer", allowId);
    }
    //-------------------------------------------------------------------------
    // endregion
}
