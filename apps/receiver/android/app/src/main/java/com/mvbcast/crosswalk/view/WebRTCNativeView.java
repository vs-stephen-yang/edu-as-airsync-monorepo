package com.mvbcast.crosswalk.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.lifecycle.MutableLiveData;

import com.mvbcast.crosswalk.BuildConfig;
import com.mvbcast.crosswalk.helper.SocketSignalingChannel;
import com.mvbcast.crosswalk.helper.WebRTCHelper;

import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.RendererCommon;
import org.webrtc.SurfaceViewRenderer;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayDeque;
import java.util.Calendar;
import java.util.Locale;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import owt.base.ActionCallback;
import owt.base.OwtError;
import owt.p2p.P2PClient;
import owt.p2p.P2PClientConfiguration;
import owt.p2p.RemoteStream;

public class WebRTCNativeView implements PlatformView,
        MethodChannel.MethodCallHandler,
        P2PClient.P2PClientObserver,
        RendererCommon.RendererEvents {
    private static final String TAG = WebRTCNativeView.class.getSimpleName();

    private final WeakReference<Activity> mActivityRef;
    private final ConstraintLayout mParentLayout;
    private final MethodChannel methodChannel;
    private final int mId;

    WebRTCNativeView(Context context, Activity activity, int id, BinaryMessenger messenger) {
        mActivityRef = new WeakReference<>(activity);
        mId = id;
        myLogDebug("Create");

        methodChannel =
                new MethodChannel(messenger, "com.mvbcast.crosswalk/webrtc_native_view_" + id);
        methodChannel.setMethodCallHandler(this);

        mSurfaceViewRenderer = new SurfaceViewRenderer(context);
        mSurfaceViewRenderer.setVisibility(View.GONE);
        mSurfaceViewRenderer.init(WebRTCHelper.getInstance().getRootEglBaseContext(), this);

        mSurfaceViewRenderer.setId(View.generateViewId());
        mParentLayout = new ConstraintLayout(context);
        mParentLayout.setId(View.generateViewId());
        mParentLayout.setBackgroundColor(Color.BLACK);
        mParentLayout.addView(mSurfaceViewRenderer, -1, new ConstraintLayout.LayoutParams(0, 0));
        ConstraintSet constraintSet = new ConstraintSet();
        constraintSet.clone(mParentLayout);
        constraintSet.connect(mSurfaceViewRenderer.getId(), ConstraintSet.START, mParentLayout.getId(), ConstraintSet.START);
        constraintSet.connect(mSurfaceViewRenderer.getId(), ConstraintSet.TOP, mParentLayout.getId(), ConstraintSet.TOP);
        constraintSet.connect(mSurfaceViewRenderer.getId(), ConstraintSet.END, mParentLayout.getId(), ConstraintSet.END);
        constraintSet.connect(mSurfaceViewRenderer.getId(), ConstraintSet.BOTTOM, mParentLayout.getId(), ConstraintSet.BOTTOM);
        constraintSet.applyTo(mParentLayout);
    }

    // region PlatformView
    //-------------------------------------------------------------------------
    @Override
    public View getView() {
        myLogDebug("getView");
        return mParentLayout;
    }

    @Override
    public void dispose() {
        disconnectP2pClient();

        if (mActivityRef.get() != null) {
            mActivityRef.get().runOnUiThread(() -> methodChannel.invokeMethod("disposed", null));
        }

        if (mSurfaceViewRenderer != null) {
            mSurfaceViewRenderer.release();
            mSurfaceViewRenderer = null;
        }
        myLogDebug("dispose");
    }
    //-------------------------------------------------------------------------
    // endregion

    // region MethodCallHandler
    //-------------------------------------------------------------------------
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String msg = call.arguments() != null ? call.arguments().toString() : "";
        myLogDebug(String.format(Locale.US, "onMethodCall: %s, object: %s", call.method, msg));
        switch (call.method) {
            case "isNotConnected":
                result.success(mAllowId.isEmpty());
                break;
            case "connectP2pClient":
                connectP2pClient(call.argument("clientId"), call.argument("allowId"), result);
                break;
            case "disconnectP2pClient":
                disconnectP2pClient();
                break;
            case "playVideo":
                streamPlay(result);
                break;
            case "stopVideo":
                streamStop(result);
                break;
            case "pauseVideo":
                streamPause(result);
                break;
            case "resumeVideo":
                streamResume(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }
    //-------------------------------------------------------------------------
    // endregion

    // region P2PClientObserver
    @Override
    public void onServerDisconnected() {
        setStateMachine("onServerDisconnected");

        if (mNeedReconnect) {
            myLogDebug("mNeedReconnect");
            mNeedReconnect = false;
            connectP2pClient(mReconnectClientId, mReconnectAllowId, mMethodResult);
            mReconnectClientId = "";
            mReconnectAllowId = "";
            mMethodResult = null;
        } else {
            if (mActivityRef.get() != null) {
                mActivityRef.get().runOnUiThread(() ->
                        methodChannel.invokeMethod("stopConnectionTimeoutTimer", null));
            }
        }
    }

    @Override
    public void onStreamAdded(RemoteStream remoteStream) {
        setStateMachine("onStreamAdded");

        if (mActivityRef.get() != null) {
            mActivityRef.get().runOnUiThread(() -> {
                methodChannel.invokeMethod("stopConnectionTimeoutTimer", null);

                methodChannel.invokeMethod("sendMessageToControlSocket", null);
            });
        }

        mRemoteStream = remoteStream;

        mAudioControl = true;

        if (mStreamObserver != null)
            mRemoteStream.removeObserver(mStreamObserver);

        mStreamObserver = new RemoteStream.StreamObserver() {
            @Override
            public void onEnded() {
                disconnectP2pClient();
            }

            @Override
            public void onUpdated() {
                setStateMachine("onUpdated");
                // ignored in p2p.
            }
        };

        mRemoteStream.addObserver(mStreamObserver);

        if (mActivityRef.get() != null) {
            mActivityRef.get().runOnUiThread(() -> {
                if (mSurfaceViewRenderer != null) {
                    if (mRemoteStream.hasVideo()) {
                        myLogDebug("mRemoteStream.attach(mSurfaceViewRenderer)");
                        mRemoteStream.attach(mSurfaceViewRenderer);
                    }
                    mSurfaceViewRenderer.setVisibility(View.VISIBLE);
                }
            });
        }
    }

    @Override
    public void onDataReceived(String peerId, String message) {
        myLogInfo(String.format("onDataReceived, peerId=%s, message=%s", peerId, message));
    }
    // endregion

    // region RendererEvents
    @Override
    public void onFirstFrameRendered() {
        myLogInfo("onFirstFrameRendered");
    }

    @Override
    public void onFrameResolutionChanged(int videoWidth, int videoHeight, int rotation) {
        myLogDebug(String.format(Locale.US, "w:%d, h:%d, r:%d", videoWidth, videoHeight, rotation));
        if (mActivityRef.get() != null) {
            mActivityRef.get().runOnUiThread(() -> {
                String ratioVideoString = String.format(Locale.ENGLISH, "%d:%d", videoWidth, videoHeight);
                myLogDebug(String.format(Locale.US, "ratioVideoString: %s", ratioVideoString));
                ConstraintSet constraintSet = new ConstraintSet();
                constraintSet.clone(mParentLayout);
                constraintSet.setDimensionRatio(mSurfaceViewRenderer.getId(), ratioVideoString);
                constraintSet.applyTo(mParentLayout);
            });
        }
    }
    // endregion

    // region public Implementation
    //-------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    // endregion public Implementation

    // region private Implementation
    //-------------------------------------------------------------------------
    private final MutableLiveData<String> mStateMachine = new MutableLiveData<>();

    private final ArrayDeque<String> mStateMachineHistory = new ArrayDeque<>();

    private P2PClient mP2pClient = null;
    private final SocketSignalingChannel mSocketSignalingChannel = new SocketSignalingChannel();
    private RemoteStream mRemoteStream;
    private RemoteStream.StreamObserver mStreamObserver;
    private SurfaceViewRenderer mSurfaceViewRenderer;
    private String mClientId = "", mAllowId = "";
    private boolean mAudioControl = false;
    private boolean mNeedReconnect;
    private String mReconnectClientId = "", mReconnectAllowId = "";
    private MethodChannel.Result mMethodResult = null;

    private boolean initP2PClient() {
        if (mP2pClient == null) {
            P2PClientConfiguration p2pConfig = WebRTCHelper.getInstance().getAndSetConfigOfIceServers();
            if (p2pConfig != null) {
                mP2pClient = new P2PClient(p2pConfig, mSocketSignalingChannel);
                mP2pClient.addObserver(this);
                setStateMachine("init P2PClient success.");
                return true;
            }
            setStateMachine("init P2PClient failure.");
            return false;
        }
        return true;
    }

    private void connectP2pClient(String clientId, String allowId, @NonNull MethodChannel.Result methodResult) {
        setStateMachine(String.format(Locale.US, "connect clientId: %s, allowId: %s", clientId, allowId));

        if (!initP2PClient()) { // Try init again, return if init again failure.
            return;
        }

        mClientId = clientId;
        mAllowId = allowId;

        JSONObject loginObj = new JSONObject();
        try {
            loginObj.put("host", "https://mrtc.myviewboard.cloud");
            loginObj.put("token", clientId);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        mP2pClient.addAllowedRemotePeer(allowId);
        mP2pClient.connect(loginObj.toString(), new ActionCallback<String>() {
            @Override
            public void onSuccess(String result) {
                methodResult.success(result);
            }

            @Override
            public void onFailure(OwtError error) {
                methodResult.error(String.valueOf(error.errorCode), error.errorMessage, null);

                setupReConnectSettings(clientId, allowId, methodResult);
                mSocketSignalingChannel.disconnect();
            }
        });
    }

    private void disconnectP2pClient() {
        if (!TextUtils.isEmpty(mClientId)) {
            setStateMachine(String.format(Locale.US, "disconnect clientId: %s, allowId: %s", mClientId, mAllowId));
            if (mP2pClient != null) mP2pClient.disconnect();
            mClientId = "";
            mAllowId = "";
        }
        mActivityRef.get().runOnUiThread(() -> {
            if (mSurfaceViewRenderer != null) {
                mSurfaceViewRenderer.clearImage();
                if (mRemoteStream != null) {
                    if (mRemoteStream.hasVideo()) {
                        mRemoteStream.detach(mSurfaceViewRenderer);
                    }
                }
                mSurfaceViewRenderer.setVisibility(View.GONE);
            }
        });
    }

    private void setupReConnectSettings(String clientId, String allowId, @NonNull MethodChannel.Result methodResult) {
        // will go to the onServerDisconnected() callback in P2PClientObserver
        mClientId = "";
        mAllowId = "";
        mReconnectClientId = clientId;
        mReconnectAllowId = allowId;
        mMethodResult = methodResult;
        mNeedReconnect = true;
    }

    private void controlAudio(boolean isEnable) {

        if (mRemoteStream != null)
            if (isEnable)
                mRemoteStream.enableAudio();
            else
                mRemoteStream.disableAudio();
    }

    private void streamPlay(@NonNull MethodChannel.Result result) {
        setStateMachine("streamPlay()");

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                mRemoteStream.enableVideo();
            }

            result.success(null);
        });
    }

    private void streamStop(@NonNull MethodChannel.Result result) {
        setStateMachine("streamStop()");

        disconnectP2pClient();

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                mRemoteStream.disableVideo();
            }

            result.success(null);
        });
    }

    private void streamPause(@NonNull MethodChannel.Result result) {
        setStateMachine("streamPause() (freeze)");

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                if (mSurfaceViewRenderer != null) {
                    //mSurfaceViewRenderer.clearImage();
                    if (mRemoteStream.hasVideo()) {
                        mRemoteStream.detach(mSurfaceViewRenderer);
                    }
                }
                controlAudio(false);
                mAudioControl = false;
            }

            result.success(null);
        });
    }

    private void streamResume(@NonNull MethodChannel.Result result) {
        setStateMachine("streamResume() (unfreeze)");

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                if (mSurfaceViewRenderer != null) {
                    if (mRemoteStream.hasVideo()) {
                        mRemoteStream.attach(mSurfaceViewRenderer);
                    }
                }
                controlAudio(true);
                mAudioControl = true;
            }

            result.success(null);
        });
    }

    // region Information Analytics
    private void setStateMachine(String state) {
        myLogDebug(state);

        String msg = String.format("(%s) %s", getShortTimeString(), state);
        StringBuilder sb = new StringBuilder(msg);
        sb.append("\n").append(String.format("mId: %s, History:", mId));
        for (String s : mStateMachineHistory) {
            sb.append("\n").append(s);
        }
        mStateMachine.postValue(sb.toString());

        // Add to history array.
        if (mStateMachineHistory.size() >= 10) {
            mStateMachineHistory.removeLast();
        }
        mStateMachineHistory.offerFirst(msg);
    }
    // endregion

    private static String getShortTimeString() {
        SimpleDateFormat formatter = new SimpleDateFormat("MM-dd-HH-mm-ss", Locale.ENGLISH);
        return formatter.format(Calendar.getInstance().getTimeInMillis());
    }

    private static final boolean DEBUG_MESSAGE = (BuildConfig.VERSION_CODE % 2) != 0;

    // region myLog
    private void myLogInfo(String msg) {
        if (DEBUG_MESSAGE) {
            Log.i(TAG, String.format(Locale.US, "mId = %d, msg: %s", mId, msg));
        }
    }

    private void myLogDebug(String msg) {
        if (DEBUG_MESSAGE) {
            Log.d(TAG, String.format(Locale.US, "mId = %d, msg: %s", mId, msg));
        }
    }

    private void myLogError(String msg) {
        if (DEBUG_MESSAGE) {
            Log.e(TAG, String.format(Locale.US, "mId = %d, msg: %s", mId, msg));
        }
    }
    //-------------------------------------------------------------------------
    // endregion private Implementation
}
