package com.mvbcast.crosswalk.view;

import static owt.base.MediaCodecs.VideoCodec.H264;
import static owt.base.MediaCodecs.VideoCodec.H265;
import static owt.base.MediaCodecs.VideoCodec.VP8;
import static owt.base.MediaCodecs.VideoCodec.VP9;

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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.PeerConnection;
import org.webrtc.RendererCommon;
import org.webrtc.SurfaceViewRenderer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.ref.WeakReference;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayDeque;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.Locale;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import javax.net.ssl.HttpsURLConnection;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import owt.base.ActionCallback;
import owt.base.OwtError;
import owt.base.VideoEncodingParameters;
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
        myLogDebug("Create id: " + id);

        methodChannel =
                new MethodChannel(messenger, "com.mvbcast.crosswalk/webrtc_native_view_" + id);
        methodChannel.setMethodCallHandler(this);

        initP2PClient();

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
        myLogDebug("getView id: " + mId);
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
        myLogDebug("dispose id: " + mId);
    }
    //-------------------------------------------------------------------------
    // endregion

    // region MethodCallHandler
    //-------------------------------------------------------------------------
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String msg = call.arguments() != null ? call.arguments().toString() : "";
        myLogDebug(String.format(Locale.US, "mId: %d, onMethodCall: %s object: %s", mId, call.method, msg));
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
    private P2PClientConfiguration mP2pConfig;
    private String mClientId = "", mAllowId = "";
    private boolean mAudioControl = false;
    private boolean mNeedReconnect;
    private String mReconnectClientId = "", mReconnectAllowId = "";
    private MethodChannel.Result mMethodResult = null;

    private boolean initP2PClient() {
        if (mP2pClient == null) {
            if (getAndSetConfigOfIceServers() != null) {
                mP2pClient = new P2PClient(mP2pConfig, mSocketSignalingChannel);
                mP2pClient.addObserver(this);
                setStateMachine(String.format(Locale.US, "mId: %d, init P2PClient success.", mId));
                return true;
            }
            setStateMachine(String.format(Locale.US, "mId: %d, init P2PClient failure.", mId));
            return false;
        }
        return true;
    }

    private void connectP2pClient(String clientId, String allowId, @NonNull MethodChannel.Result methodResult) {
        setStateMachine(String.format(Locale.US, "mId: %d, connect clientId: %s, allowId: %s", mId, clientId, allowId));

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
            setStateMachine(String.format(Locale.US, "mId: %d, disconnect clientId: %s, allowId: %s", mId, mClientId, mAllowId));
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

    private P2PClientConfiguration getAndSetConfigOfIceServers() {

        if (mP2pConfig != null) return mP2pConfig;

        Callable<String> task = this::getJsonOfIceServers; // Short way for "() -> getJsonOfIceServers();". Suggested
        // by intelligence.

        ExecutorService mExecutor = Executors.newSingleThreadExecutor();
        Future<String> future = mExecutor.submit(task);

        String jsonResult = null;

        try {
            jsonResult = future.get(); // halt and wait here !!

            // Once an executor service has been shut down it can't be reactivated.
            // Create a new executor service to restart execution
            // See, https://stackoverflow.com/questions/26143233/android-java-executorservice-execute-after-shutdown
            mExecutor.shutdown();
        }
        // todo: loop to call getJsonOfIceServers for exceptions
        catch (ExecutionException | InterruptedException e) {

            e.printStackTrace();
        }

        if (jsonResult != null) {

            VideoEncodingParameters h264 = new VideoEncodingParameters(H264);
            VideoEncodingParameters h265 = new VideoEncodingParameters(H265);
            VideoEncodingParameters vp8 = new VideoEncodingParameters(VP8);
            VideoEncodingParameters vp9 = new VideoEncodingParameters(VP9);
            mP2pConfig = P2PClientConfiguration.builder()
                    .addVideoParameters(vp8)
                    .addVideoParameters(h264)
                    .addVideoParameters(h265)
                    .addVideoParameters(vp9)
                    .build();

            try {
                mP2pConfig.rtcConfiguration.iceServers = iceServersFromPCConfigJSON(jsonResult);
                myLogInfo("iceServersFromPCConfigJSON() is ok");
            } catch (JSONException e) {
                e.printStackTrace();
                myLogError(e.getMessage());
            }

            return mP2pConfig;
        }

        return null;
    }

    private String getJsonOfIceServers() {

        HttpsURLConnection connection = null;
        BufferedReader reader = null;

        try {
            URL url = new URL("https://getice.myviewboard.cloud");
            connection = (HttpsURLConnection) url.openConnection();
            myLogDebug("connecting");
            connection.connect();
            myLogDebug("connected");

            InputStream stream = connection.getInputStream();

            reader = new BufferedReader(new InputStreamReader(stream));

            StringBuilder buffer = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                buffer.append(line).append("\n");
                myLogDebug("Response: > " + line);   //here u ll get whole response...... :-)
            }

            return buffer.toString();

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
            try {
                if (reader != null) {
                    reader.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    private LinkedList<PeerConnection.IceServer> iceServersFromPCConfigJSON(String pcConfig)
            throws JSONException {
        JSONObject json = new JSONObject(pcConfig);
        JSONArray servers = json.getJSONArray("list");
        LinkedList<PeerConnection.IceServer> ret = new LinkedList<>();
        for (int i = 0; i < servers.length(); ++i) {
            JSONObject server = servers.getJSONObject(i);
            String url = server.getString("url");
            String username = server.has("username") ? server.getString("username") : "";
            String credential = server.has("credential") ? server.getString("credential") : "";
            PeerConnection.IceServer turnServer =
                    PeerConnection.IceServer.builder(url)
                            .setUsername(username)
                            .setPassword(credential)
                            .createIceServer();
            ret.add(turnServer);
        }
        return ret;
    }

    // region Information Analytics
    private void setStateMachine(String state) {
        myLogDebug(state);

        String msg = String.format("(%s) %s", getShortTimeString(), state);
        StringBuilder sb = new StringBuilder(msg);
        sb.append("\n").append("History:");
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
    private static void myLogInfo(String msg) {
        if (DEBUG_MESSAGE) {
            Log.i(TAG, msg);
        }
    }

    private static void myLogDebug(String msg) {
        if (DEBUG_MESSAGE) {
            Log.d(TAG, msg);
        }
    }

    private static void myLogError(String msg) {
        if (DEBUG_MESSAGE) {
            Log.e(TAG, msg);
        }
    }
    //-------------------------------------------------------------------------
    // endregion private Implementation
}
