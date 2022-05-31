package com.mvbcast.crosswalk.view;

import static owt.base.MediaCodecs.VideoCodec.H264;
import static owt.base.MediaCodecs.VideoCodec.H265;
import static owt.base.MediaCodecs.VideoCodec.VP8;
import static owt.base.MediaCodecs.VideoCodec.VP9;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
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
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
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

    private WeakReference<Activity> mActivityRef;
    private final MethodChannel methodChannel;

    WebRTCNativeView(Context context, Activity activity, int id, BinaryMessenger messenger) {
        mActivityRef = new WeakReference<>(activity);
        myLogDebug(TAG, "NativeWebRTCView create id: " + id);
        mSurfaceViewRenderer = new SurfaceViewRenderer(context);
        methodChannel =
                new MethodChannel(messenger, "com.mvbcast.crosswalk/webrtc_native_view_" + id);
        methodChannel.setMethodCallHandler(this);

        initP2PClient();
        mSurfaceViewRenderer.init(WebRTCHelper.getInstance().getRootEglBaseContext(), this);
    }

    // region PlatformView
    //-------------------------------------------------------------------------
    @Override
    public View getView() {
        Log.e("_TAG_", "getView");
        return mSurfaceViewRenderer;
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
        Object msg = call.arguments() != null ? call.arguments().toString() : "";
        myLogDebug(TAG, "onMethodCall: " + call.method + " object:" + msg);
        switch (call.method) {
            case "connectP2pClient":
                connectP2pClient(call.argument("clientId"),
                        call.argument("allowId"),
                        new JSONObject((Map) call.argument("response")));
                break;
            case "disconnectP2pClient":
                disconnectP2pClient();
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
            myLogDebug(TAG, "mNeedReconnect");
            mNeedReconnect = false;
            connectP2pClient(mReconnectClientId, mReconnectAllowId, mReconnectResponse);
            mReconnectClientId = "";
            mReconnectAllowId = "";
            mReconnectResponse = null;
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
                myToastL(mActivityRef.get(), "video stream ended.");
            }

            @Override
            public void onUpdated() {
                setStateMachine("onUpdated");
                // ignored in p2p.
            }
        };

        mRemoteStream.addObserver(mStreamObserver);

        if (mSurfaceViewRenderer != null) {
            if (mRemoteStream.hasVideo()) {
                myLogDebug(TAG, "mRemoteStream.attach(mSurfaceViewRenderer)");
                mRemoteStream.attach(mSurfaceViewRenderer);
            }
        }
    }

    @Override
    public void onDataReceived(String peerId, String message) {
        myLogInfo(TAG, String.format("onDataReceived, peerId=%s, message=%s", peerId, message));
    }
    // endregion

    // region RendererEvents
    @Override
    public void onFirstFrameRendered() {
        myLogDebug(TAG, "onFirstFrameRendered");
    }

    @Override
    public void onFrameResolutionChanged(int videoWidth, int videoHeight, int rotation) {
        myLogDebug(TAG,
                String.format(Locale.US, "w:%d, h:%d, r:%d", videoWidth, videoHeight, rotation));

        // TODO: Update UI layout aspect ratio.
//        if (mListener != null) {
//            mListener.updateFrameResolution(videoWidth, videoHeight, rotation);
//        }
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
    private final SurfaceViewRenderer mSurfaceViewRenderer;
    private P2PClientConfiguration mP2pConfig;
    private String mClientId = "", mAllowId = "";
    private boolean mAudioControl = false;
    private boolean mNeedReconnect;
    private String mReconnectClientId = "", mReconnectAllowId = "";
    private JSONObject mReconnectResponse = null;

    private boolean initP2PClient() {
        if (mP2pClient == null) {
            if (getAndSetConfigOfIceServers() != null) {
                mP2pClient = new P2PClient(mP2pConfig, mSocketSignalingChannel);
                mP2pClient.addObserver(this);
                setStateMachine("init P2PClient success.");
                return true;
            }
            setStateMachine("init P2PClient failure.");
            return false;
        }
        return true;
    }

    private void connectP2pClient(String clientId, String allowId, JSONObject response) {
        setStateMachine(String.format("connect clientId: %s, allowId: %s", clientId, allowId));

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
                mActivityRef.get().runOnUiThread(() -> {
                    methodChannel.invokeMethod("connectP2PClientSuccess", result);
                });
            }

            @Override
            public void onFailure(OwtError error) {
                mActivityRef.get().runOnUiThread(() -> {
                    HashMap<String, Object> args = new HashMap<>();
                    args.put("errorCode", error.errorCode);
                    args.put("errorMessage", error.errorMessage);
                    methodChannel.invokeMethod("connectP2PClientFailure", args);
                });

                setupReConnectSettings(clientId, allowId, response);
                mSocketSignalingChannel.disconnect();

                myToastL(mActivityRef.get(), "connection_signal_connect_failure");
            }
        });
    }

    private void disconnectP2pClient() {
        if (!TextUtils.isEmpty(mClientId)) {
            setStateMachine(String.format("disconnect clientId: %s, allowId: %s", mClientId, mAllowId));
            if (mP2pClient != null) mP2pClient.disconnect();
            mClientId = "";
            mAllowId = "";
        }

        //sendMessageToControlSocket(mWebRTCInfo.DisplayCode);
    }

    private void setupReConnectSettings(String clientId, String allowId, JSONObject response) {
        // will go to the onServerDisconnected() callback in P2PClientObserver
        mClientId = "";
        mAllowId = "";
        mReconnectClientId = clientId;
        mReconnectAllowId = allowId;
        mReconnectResponse = response;
        mNeedReconnect = true;
    }

    private void controlAudio(boolean isEnable) {

        if (mRemoteStream != null)
            if (isEnable)
                mRemoteStream.enableAudio();
            else
                mRemoteStream.disableAudio();
    }

    private void streamPlay() {
        setStateMachine("streamPlay()");

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                mRemoteStream.enableVideo();
            }
        });
    }

    private void streamStop() {
        setStateMachine("streamStop()");

        disconnectP2pClient();
        myToastL(mActivityRef.get(), "connection_receive_stop_stream");

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                mRemoteStream.disableVideo();
            }
        });
    }

    private void streamPause(String messageID) {
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

                // TODO: 111 move to dart control socket
//                try {
//                    JSONObject reply = new JSONObject();
//                    reply.put("messageFor", mWebRTCInfo.DisplayCode);
//                    reply.put("userid", mAllowId);
//                    reply.put("action", "pauseVideo");
//                    reply.put("status", "pauseVideo-ok");
//                    reply.put("messageId", messageID);
//                    reply.put("nextId", getRandomString(21));
//
//                    sendMessageToControlSocket(mWebRTCInfo.DisplayCode, reply);
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
            }
        });
    }

    private void streamResume() {
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
                myLogDebug(TAG, "iceServersFromPCConfigJSON() is ok");
            } catch (JSONException e) {
                e.printStackTrace();
                myLogError(TAG, e.toString());
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
            myLogDebug(TAG, "connecting");
            connection.connect();
            myLogDebug(TAG, "connected");

            InputStream stream = connection.getInputStream();

            reader = new BufferedReader(new InputStreamReader(stream));

            StringBuilder buffer = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                buffer.append(line).append("\n");
                myLogDebug("Response: ", "> " + line);   //here u ll get whole response...... :-)
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
        myLogDebug(TAG, state);

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

    private static String getRandomString(int len) {
        String data = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        Random random = new Random();
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) {
            sb.append(data.toCharArray()[random.nextInt(data.length())]);
        }
        return sb.toString();
    }

    private static final boolean DEBUG_MESSAGE = (BuildConfig.VERSION_CODE % 2) != 0;

    // region myLog
    private static void myLogInfo(String tag, String msg) {
        if (DEBUG_MESSAGE) {
            Log.i(tag, msg);
        }
    }

    private static void myLogDebug(String tag, String msg) {
        if (DEBUG_MESSAGE) {
            Log.d(tag, msg);
        }
    }

    private static void myLogError(String tag, String msg) {
        if (DEBUG_MESSAGE) {
            Log.e(tag, msg);
        }
    }

    private static void myToast(Context context, int messageID) {
        new Handler(Looper.getMainLooper()).post(() -> {
            if (context != null)
                Toast.makeText(context, messageID, Toast.LENGTH_SHORT).show();
        });
    }

    private static void myToast(Context context, String messageString) {
        new Handler(Looper.getMainLooper()).post(() -> {
            if (context != null)
                Toast.makeText(context, messageString, Toast.LENGTH_SHORT).show();
        });
    }

    private static void myToastL(Context context, int messageID) {
        new Handler(Looper.getMainLooper()).post(() -> {
            if (context != null)
                Toast.makeText(context, messageID, Toast.LENGTH_LONG).show();
        });
    }

    private static void myToastL(Context context, String messageString) {
        new Handler(Looper.getMainLooper()).post(() -> {
            if (context != null)
                Toast.makeText(context, messageString, Toast.LENGTH_LONG).show();
        });
    }
    //-------------------------------------------------------------------------
    // endregion private Implementation
}
