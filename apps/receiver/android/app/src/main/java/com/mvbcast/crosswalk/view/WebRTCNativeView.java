package com.mvbcast.crosswalk.view;

import android.app.Activity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.lifecycle.MutableLiveData;

import com.mvbcast.crosswalk.BuildConfig;
import com.mvbcast.crosswalk.EulaActivity;
import com.mvbcast.crosswalk.R;
import com.mvbcast.crosswalk.helper.SocketSignalingChannel;
import com.mvbcast.crosswalk.helper.WebRTCHelper;

import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.RendererCommon;
import org.webrtc.SurfaceViewRenderer;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayDeque;
import java.util.ArrayList;
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
    private static final Object lock = new Object();
    private final ArrayList<Integer> mRenderUsedList;
    private final int mRenderId;
    private final String mRenderName;

    WebRTCNativeView(Activity activity, int id, BinaryMessenger messenger, ArrayList<Integer> renderUsedList, int renderId) {
        mActivityRef = new WeakReference<>(activity);
        mId = id;
        mRenderUsedList = renderUsedList;
        mRenderId = renderId;
        myLogDebug("Create: " + mRenderId);

        methodChannel =
                new MethodChannel(messenger, "com.mvbcast.crosswalk/webrtc_native_view_" + id);
        methodChannel.setMethodCallHandler(this);

        LayoutInflater layoutInflater = activity.getLayoutInflater();
        View webrtc_render = layoutInflater.inflate(R.layout.webrtc_render, null, false);
        mParentLayout = webrtc_render.findViewById(R.id.parentLayout);
        mSurfaceViewRenderer = webrtc_render.findViewById(mRenderId);
        mSurfaceViewRenderer.setKeepScreenOn(true);
        mSurfaceViewRenderer.init(WebRTCHelper.getInstance().getRootEglBaseContext(), this);

        TextView textView = webrtc_render.findViewById(R.id.textStateID);
        String str = textView.getText().toString();
        textView.setText(String.format("%s View ID: %s", str, mId));

        WebRTCHelper.getInstance().getDebugInfoVisible().observe((EulaActivity) activity,
                s -> webrtc_render.findViewById(R.id.layoutDebugInfo)
                        .setVisibility(s ? View.VISIBLE : View.GONE));

        WebRTCHelper.getInstance().getDecoder().observe((EulaActivity) activity,
                s -> {
                    ((TextView) webrtc_render.findViewById(R.id.textDecoder))
                            .setText(String.format("Decoder: %s", s));
                    myLogDebug(String.format("Decoder: %s", s));
                });

        mStateMachine.observe((EulaActivity) activity,
                s -> ((TextView) webrtc_render.findViewById(R.id.textLastState))
                        .setText(String.format("Last State: %s", s)));

        mRenderName = activity.getResources().getResourceEntryName(mRenderId);
        WebRTCHelper.getInstance().getFPS(mRenderName).observe((EulaActivity) activity,
                s -> {
                    ((TextView) webrtc_render.findViewById(R.id.textFPS))
                            .setText(String.format("Render fps: %s", s));
                    myLogDebug(String.format("Render fps: %s", s));
                });
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
        synchronized (lock) {
            mRenderUsedList.remove((Object) mRenderId);
        }
        disconnectP2pClient(false, null);

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
            case "connectP2pClient":
                connectP2pClient(call.argument("token"), call.argument("displayCode"), call.argument("peerId"), call.argument("url"), result);
                break;
            case "connectionTimeTimeOut":
                disconnectP2pClient(true, null);
                break;
            case "enableAudio":
                controlAudio(true);
                break;
            case "disableAudio":
                controlAudio(false);
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

        if (mActivityRef.get() != null) {
            mActivityRef.get().runOnUiThread(() ->
                    methodChannel.invokeMethod("onServerDisconnected", null));
        }
    }

    @Override
    public void onStreamAdded(RemoteStream remoteStream) {
        setStateMachine("onStreamAdded");
        WebRTCHelper.getInstance().clearFPS(mRenderName);

        if (mActivityRef.get() != null) {
            mActivityRef.get().runOnUiThread(() ->
                    methodChannel.invokeMethod("onStreamAdded", null));
        }

        mRemoteStream = remoteStream;

        mAudioControl = true;

        if (mStreamObserver != null)
            mRemoteStream.removeObserver(mStreamObserver);

        mStreamObserver = new RemoteStream.StreamObserver() {
            @Override
            public void onEnded() {
                setStateMachine("onEnded");
                disconnectP2pClient(false, null);
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
    private boolean mAudioControl = false;

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

    private void connectP2pClient(String token, String displayCode, String peerId, String url, @NonNull MethodChannel.Result methodResult) {
        setStateMachine(String.format(Locale.US, "connect token: %s, peerId: %s", token, peerId));

        if (!initP2PClient()) { // Try init again, return if init again failure.
            return;
        }

        JSONObject loginObj = new JSONObject();
        try {
            loginObj.put("host", url != null ? url : WebRTCHelper.getInstance().getSignalServer());
            loginObj.put("token", token);
            loginObj.put("displayCode", displayCode);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        mP2pClient.addAllowedRemotePeer(peerId);
        mP2pClient.connect(loginObj.toString(), new ActionCallback<String>() {
            @Override
            public void onSuccess(String result) {
                setStateMachine(String.format("connect() onSuccess: %s", result));
                methodResult.success(result);
            }

            @Override
            public void onFailure(OwtError error) {
                setStateMachine(String.format("connect() onFailure: %s %s", error.errorCode, error.errorMessage));
                methodResult.error(String.valueOf(error.errorCode), error.errorMessage, null);
            }
        });
    }

    private void disconnectP2pClient(boolean sendAnalytics, MethodChannel.Result result) {
        if (mP2pClient != null) {
            setStateMachine(String.format(Locale.US, "disconnect uid: %s", mP2pClient.id()));
            mP2pClient.disconnect();
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
            if (methodChannel != null) {
                methodChannel.invokeMethod("disconnectedP2pClient", sendAnalytics);
            }
            if (result != null) {
                result.success(null);
            }
        });
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

        disconnectP2pClient(true, result);

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                mRemoteStream.disableVideo();
            }
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
        sb.append("\n").append("History:");
        for (String s : new ArrayList<>(mStateMachineHistory)) {
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

    @SuppressWarnings("ConstantConditions")
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
