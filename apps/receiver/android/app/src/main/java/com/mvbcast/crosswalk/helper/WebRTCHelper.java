package com.mvbcast.crosswalk.helper;

import static owt.base.MediaCodecs.VideoCodec.H264;
import static owt.base.MediaCodecs.VideoCodec.H265;
import static owt.base.MediaCodecs.VideoCodec.VP8;
import static owt.base.MediaCodecs.VideoCodec.VP9;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.os.Build;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.mvbcast.crosswalk.BuildConfig;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.EglBase;
import org.webrtc.Logging;
import org.webrtc.PeerConnection;
import org.webrtc.RendererCommon;
import org.webrtc.SoftwareVideoDecoderFactory;
import org.webrtc.SurfaceViewRenderer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.ref.WeakReference;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Observable;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import javax.net.ssl.HttpsURLConnection;

import io.socket.client.IO;
import io.socket.client.Socket;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import owt.base.ActionCallback;
import owt.base.ContextInitialization;
import owt.base.OwtError;
import owt.base.VideoEncodingParameters;
import owt.p2p.P2PClient;
import owt.p2p.P2PClientConfiguration;
import owt.p2p.RemoteStream;


/**
 * Created by ChangLo on 2020/10/08.
 * Display Helper (Singleton)
 */

public class WebRTCHelper extends Observable implements
        P2PClient.P2PClientObserver, RendererCommon.RendererEvents {
    private static final String TAG = WebRTCHelper.class.getSimpleName();

    private final OkHttpClient mHttpClient = new OkHttpClient();

    // region Singleton Implementation
    // https://android.jlelse.eu/how-to-make-the-perfect-singleton-de6b951dfdb0
    //-------------------------------------------------------------------------
    private static volatile WebRTCHelper INSTANCE = null;

    // private constructor.
    private WebRTCHelper() {
        // Prevent form the reflection api.
        if (INSTANCE != null) {
            throw new RuntimeException("Use getInstance() method to get the single instance of this class.");
        }
    }

    public static WebRTCHelper getInstance() {
        // Double check locking pattern
        if (INSTANCE == null) {// Check for the first time
            synchronized (WebRTCHelper.class) {// Check for the second time.
                // if there is no instance available... create new one
                if (INSTANCE == null) INSTANCE = new WebRTCHelper();
            }
        }
        return INSTANCE;
    }
    //-------------------------------------------------------------------------
    // endregion Singleton Implementation

    // region public Implementation
    //-------------------------------------------------------------------------
    public enum ePresentationState {
        stopStreaming,
        waitForStream,
        streaming,
    }

    public static class WebRTCInfo {
        public String InstanceId = "";
        public String Token = "";

        public String DisplayCode = "";
        public String LicenseName = "";
        public ArrayList<String> FeatureList = new ArrayList<>();

        public String OTPCode = "";
        public int OTPTimer = 0;
        public boolean OTPUpdate = false;
        public boolean OTPForceUpdate = false;

        public boolean IsUIStateChanged = true;
        public ePresentationState PresentationState = ePresentationState.stopStreaming;

        public boolean ModeratorMode = false;
        public boolean IsModeratorLeave = false;
        public String ModeratorId = "";
        public String ModeratorName = "";
        public long RemainingTime = 0;
        public ArrayList<Long> RemainingTimeCheckPoints = new ArrayList<>();

        public boolean IsShowDelegate = false;
        public boolean IsShowCode = false;

        public String PresenterId = "";
        public String PresenterName = "";

        public String MeetingId = "";
    }

    public interface WebRTCListener {
        void updateFrameResolution(int videoWidth, int videoHeight, int rotation);
    }

    public void onActivityResume() {
        if (mAudioControl) {
            controlAudio(true);
        }
//        if (!mWebRTCInfo.DisplayCode.isEmpty())
//            mMainHandler.post(getOneTimePassword);
    }

    public void onActivityPause() {
        if (mAudioControl) {
            controlAudio(false);
        }
    }

    public void onNetworkResume() {
        if (mAudioControl) {
            controlAudio(true);
        }
    }

    public void onNetworkPause() {
        if (mAudioControl) {
            controlAudio(false);
        }
    }

    @SuppressWarnings({"UnusedDeclaration", "UnusedAssignment"})
    public void onActivityDestroy() {
        ContextInitialization contextInitialization = ContextInitialization.create();
        contextInitialization = null;

        if (mRemoteStream != null && mStreamObserver != null) {
            mRemoteStream.removeObserver(mStreamObserver);
        }

        disconnectControlSocket();
    }

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
            stopConnectionTimeoutTimer();
        }
    }

    @Override
    public void onStreamAdded(RemoteStream remoteStream) {
        setStateMachine("onStreamAdded");

        mStreamFPS.clear();
        stopConnectionTimeoutTimer();

        mWebRTCInfo.PresentationState = ePresentationState.streaming;
        mWebRTCInfo.IsUIStateChanged = true;
        setChanged();
        notifyObservers();
        sendMessageToControlSocket(mWebRTCInfo.DisplayCode);

        mRemoteStream = remoteStream;

        mAudioControl = true;

        if (mStreamObserver != null)
            mRemoteStream.removeObserver(mStreamObserver);

        mStreamObserver = new RemoteStream.StreamObserver() {
            @Override
            public void onEnded() {
                // AppCenterAnalyticsHelper.getInstance().EventStreamStopped();

                setStateMachine("onEnded: " + mStreamFPS);

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

        if (mRemoteRenderer != null) {
            myLogDebug(TAG, "mRemoteStream.attach(mRemoteRenderer)");
            if (mRemoteStream.hasVideo()) {
                mRemoteStream.attach(mRemoteRenderer);
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

        if (mListener != null) {
            mListener.updateFrameResolution(videoWidth, videoHeight, rotation);
        }
    }
    // endregion


    public void initWebRTCP2PClient(Activity activity, SurfaceViewRenderer renderer, WebRTCListener listener) {
        mActivityRef = new WeakReference<>(activity);
        mRemoteRenderer = renderer;
        mListener = listener;
        try {
            EglBase rootEglBase = EglBase.create();

            // TODO: How to check device need use software not hardware?
            // boolean isForceSW = IFPModelHelper.getIFPModelSeries().equals(IFPModelHelper.IFPModel.IFP50_2);
            boolean isForceSW = Build.MODEL.equals("");

            if (isForceSW) mDecoder.postValue("Use Software Video Decoder.");

            ContextInitialization.create()
                    .setApplicationContext(activity)
                    .setVideoHardwareAccelerationOptions(
                            rootEglBase.getEglBaseContext(),
                            rootEglBase.getEglBaseContext())
                    .setCustomizedVideoDecoderFactory(isForceSW ? new SoftwareVideoDecoderFactory() : null)
                    .setCustomizedLoggableFactory((s, severity, s1) ->
                            loggerParser(s, severity.name(), s1), Logging.Severity.LS_VERBOSE)
                    .initialize();

            initP2PClient();

            mRemoteRenderer.init(rootEglBase.getEglBaseContext(), this);
        } catch (RuntimeException e) {
            new AlertDialog.Builder(activity)
                    .setTitle("unsupported_device_title")
                    .setMessage("unsupported_device_msg\n\n\"" + e.getMessage() + "\"")
                    .setPositiveButton(android.R.string.yes, (dialog, which) -> {
                        // Continue with delete operation
                        activity.finish();
                        System.exit(0);
                    })
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .show();
        }
    }

    public WebRTCInfo getWebRTCInfo() {
        return mWebRTCInfo;
    }

    public LiveData<String> getStateMachine() {
        return mStateMachine;
    }

    public LiveData<String> getDecoder() {
        return mDecoder;
    }

    public LiveData<String> getFPS() {
        return mFPS;
    }

    public LiveData<String> getConnectionTimeout() {
        return mConnectionTimeout;
    }

    public LiveData<Long> getRemainingTimeTimeout() {
        return mRemainingTimeTimeout;
    }

    public LiveData<Boolean> getDisplaySocketReConnect() {
        return mDisplaySocketReConnect;
    }

    public String getmAllowId() {
        return !mAllowId.isEmpty() ? mAllowId : mReconnectAllowId;
    }

    public boolean isConnected() {
        return !mClientId.isEmpty();
    }

    public boolean audioVolumeIncrease() {
        if (mRemoteStream != null && mRemoteStream.hasAudio() && mAudioControl) {
            mVolume += 1;
            mVolume = Math.min(10, mVolume);
            mRemoteStream.setAudioVolume(mVolume);
            return true;
        }
        return false;
    }

    public boolean audioVolumeDecrease() {
        if (mRemoteStream != null && mRemoteStream.hasAudio() && mAudioControl) {
            mVolume -= 1;
            mVolume = Math.max(0, mVolume);
            mRemoteStream.setAudioVolume(mVolume);
            return true;
        }
        return false;
    }

    public double getAudioVolume() {
        return mVolume;
    }

    //-------------------------------------------------------------------------
    // endregion public Implementation

    // region private Implementation
    //-------------------------------------------------------------------------
    private final WebRTCInfo mWebRTCInfo = new WebRTCInfo();

    private final MutableLiveData<String> mStateMachine = new MutableLiveData<>();
    private final MutableLiveData<String> mDecoder = new MutableLiveData<>();
    private final MutableLiveData<String> mFPS = new MutableLiveData<>();
    private final MutableLiveData<String> mConnectionTimeout = new MutableLiveData<>();
    private final MutableLiveData<Long> mRemainingTimeTimeout = new MutableLiveData<>();
    private final MutableLiveData<Boolean> mIsNetworkSignalBad = new MutableLiveData<>();
    private final MutableLiveData<Boolean> mDisplaySocketReConnect = new MutableLiveData<>();

    private final ArrayDeque<String> mStateMachineHistory = new ArrayDeque<>();
    private final ArrayDeque<String> mStreamFPS = new ArrayDeque<>();

    private WeakReference<Activity> mActivityRef;
    private WebRTCListener mListener;
    private P2PClient mP2pClient = null;
    private final SocketSignalingChannel mSocketSignalingChannel = new SocketSignalingChannel();
    private RemoteStream mRemoteStream;
    private RemoteStream.StreamObserver mStreamObserver;
    private SurfaceViewRenderer mRemoteRenderer;
    private P2PClientConfiguration mP2pConfig;
    private String mClientId = "", mAllowId = "";
    private boolean mAudioControl = false;
    private boolean mNeedReconnect;
    private String mReconnectClientId = "", mReconnectAllowId = "";
    private JSONObject mReconnectResponse = null;
    private final Handler mMainHandler = new Handler(Looper.getMainLooper());
    private CountDownTimer mConnectionTimeoutTimer;
    private CountDownTimer mRemainingTimeTimer;

    private final int MAX_RECONNECT_ATTEMPTS = 5;
    private Socket mControlSocketIO;
    private int mDisplayReconnectAttempts = 0;

    private double mVolume = 5;

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

     public void connectP2pClient(String clientId, String allowId, JSONObject response) {
        setStateMachine(String.format("connect clientId: %s, allowId: %s", clientId, allowId));

        if (!mWebRTCInfo.ModeratorMode) {
            startConnectionTimeoutTimer();
        }

        if (!initP2PClient()) { // Try init again, return if init again failure.
            return;
        }

        if (!TextUtils.isEmpty(mClientId)) {

//			AppCenterAnalyticsHelper.getInstance().EventStreamSwitched();

            setupReConnectSettings(clientId, allowId, response);
            if (mP2pClient != null) {
                setStateMachine(String.format("disconnect clientId: %s, allowId: %s", clientId, allowId));
                mP2pClient.disconnect();
            }
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

//		AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());

        mP2pClient.addAllowedRemotePeer(allowId);
        mP2pClient.connect(loginObj.toString(), new ActionCallback<String>() {
            @Override
            public void onSuccess(String result) {
                setStateMachine(String.format("connect() onSuccess: %s", result));

                // Instance connection
                if (response != null) {
                    String nextId = response.optString("nextId");
                    String client = null, allow = null;
                    try {
                        JSONObject extra = response.getJSONObject("extra");
                        client = extra.getString("setClientId");
                        allow = extra.getString("setAllowedPeer");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    JSONObject reply = new JSONObject();
                    try {
                        reply.put("messageFor", mWebRTCInfo.DisplayCode);
                        reply.put("action", "control");
                        JSONObject statusReply = new JSONObject();
                        statusReply.put("action", "setClient");
                        statusReply.put("status", "ready");
                        reply.put("status", statusReply);
                        JSONObject extraReply = new JSONObject();
                        extraReply.put("setClientId", client);
                        extraReply.put("setAllowedPeer", allow);
                        extraReply.put("streamer", BuildConfig.VERSION_NAME);
                        extraReply.put("platform", "android");
                        extraReply.put("capacities", new JSONArray());
                        extraReply.put("code", mWebRTCInfo.DisplayCode);
                        reply.put("extra", extraReply);
                        reply.put("direction", "out");
                        reply.put("messageId", nextId);
                        reply.put("nextId", getRandomString(21));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    sendMessageToControlSocket(mWebRTCInfo.DisplayCode, reply);
                }
            }

            @Override
            public void onFailure(OwtError error) {
                setStateMachine(String.format("connect() onFailure: %s %s", error.errorCode, error.errorMessage));

                setupReConnectSettings(clientId, allowId, response);
                mSocketSignalingChannel.disconnect();

                myToastL(mActivityRef.get(), "connection_signal_connect_failure");
            }
        });
    }

    public void disconnectP2pClient() {
        if (!TextUtils.isEmpty(mClientId)) {
            setStateMachine(String.format("disconnect clientId: %s, allowId: %s", mClientId, mAllowId));
            if (mP2pClient != null) mP2pClient.disconnect();
            mClientId = "";
            mAllowId = "";
        }

        mWebRTCInfo.PresentationState = ePresentationState.stopStreaming;
        mWebRTCInfo.PresenterId = "";
        mWebRTCInfo.PresenterName = "";
        mWebRTCInfo.OTPForceUpdate = true;
        mWebRTCInfo.IsUIStateChanged = true;
        setChanged();
        notifyObservers();
        sendMessageToControlSocket(mWebRTCInfo.DisplayCode);
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

    private void startConnectionTimeoutTimer() {
        mMainHandler.post(() -> {
            stopConnectionTimeoutTimer();

            mConnectionTimeoutTimer = new CountDownTimer(30000, 1000) {
                @Override
                public void onTick(long millisUntilFinished) {
                    //myLogDebug(TAG, "ConnectionTimeout tick: " + millisUntilFinished / 1000);
                    mConnectionTimeout.setValue(String.valueOf((int) millisUntilFinished / 1000));
                }

                @Override
                public void onFinish() {
                    setStateMachine("ConnectionTimeout onFinish");

//					AppCenterAnalyticsHelper.getInstance().EventStreamTimeout();

                    sendMessageToControlSocket(mWebRTCInfo.DisplayCode, !mAllowId.isEmpty() ? mAllowId :
                            mReconnectAllowId, "timeout");

                    disconnectP2pClient();
                    myToastL(mActivityRef.get(), "connection_connect_timeout");
                }
            };
            mConnectionTimeoutTimer.start();
        });
    }

    private void stopConnectionTimeoutTimer() {
        if (mConnectionTimeoutTimer != null) {
            mConnectionTimeoutTimer.cancel();
            mConnectionTimeoutTimer = null;
            mConnectionTimeout.postValue("0");
        }
    }

    private void startRemainingTimeTimer(long milliseconds) {
        mMainHandler.post(() -> {
            stopRemainingTimeTimer();

            mRemainingTimeTimer = new CountDownTimer(milliseconds, 1000) {
                @Override
                public void onTick(long millisUntilFinished) {
                    myLogDebug(TAG, "RemainingTimeTimeout tick: " + millisUntilFinished / 1000);
                    mRemainingTimeTimeout.setValue(millisUntilFinished / 1000);
                }

                @Override
                public void onFinish() {
                    myLogDebug(TAG, "RemainingTimeTimeout onFinish");

                    mWebRTCInfo.ModeratorMode = false;
                    mWebRTCInfo.IsModeratorLeave = true;
                    mWebRTCInfo.ModeratorId = "";
                    mWebRTCInfo.ModeratorName = "";

                    disconnectP2pClient();
                }
            };
            mRemainingTimeTimer.start();
        });
    }

    private void stopRemainingTimeTimer() {
        if (mRemainingTimeTimer != null) {
            mRemainingTimeTimer.cancel();
            mRemainingTimeTimer = null;
            mRemainingTimeTimeout.postValue(0L);
        }
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

        stopConnectionTimeoutTimer();

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
                if (mRemoteRenderer != null) {
                    //mRemoteRenderer.clearImage();
                    if (mRemoteStream.hasVideo()) {
                        mRemoteStream.detach(mRemoteRenderer);
                    }
                }
                controlAudio(false);
                mAudioControl = false;

                try {
                    JSONObject reply = new JSONObject();
                    reply.put("messageFor", mWebRTCInfo.DisplayCode);
                    reply.put("userid", mAllowId);
                    reply.put("action", "pauseVideo");
                    reply.put("status", "pauseVideo-ok");
                    reply.put("messageId", messageID);
                    reply.put("nextId", getRandomString(21));

                    sendMessageToControlSocket(mWebRTCInfo.DisplayCode, reply);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void streamResume() {
        setStateMachine("streamResume() (unfreeze)");

        mActivityRef.get().runOnUiThread(() -> {
            if (mRemoteStream != null) {
                if (mRemoteRenderer != null) {
                    if (mRemoteStream.hasVideo()) {
                        mRemoteStream.attach(mRemoteRenderer);
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

    private void handleDisplayResponse(Object... args) {
        if (args[0] instanceof JSONObject) {
            JSONObject response = (JSONObject) args[0];
            String messageFor = response.optString("messageFor");

            if (!messageFor.isEmpty() && messageFor.equals(mWebRTCInfo.DisplayCode)) {
                String action = response.optString("action");
                String userid = response.optString("userid");
                JSONObject extra = response.optJSONObject("extra");
                switch (action) {
                    case "set-moderator":
                        mWebRTCInfo.ModeratorMode = true;
                        if (extra != null) {
                            JSONObject moderator = extra.optJSONObject("moderator");
                            if (moderator != null) {
                                mWebRTCInfo.ModeratorId = moderator.optString("id");
                                mWebRTCInfo.ModeratorName = moderator.optString("name");
                            }

                            mWebRTCInfo.RemainingTime = extra.optLong("endTime") - System.currentTimeMillis();
                            myLogDebug(TAG, "Remaining time: " + mWebRTCInfo.RemainingTime);
                            JSONArray checkPoints = extra.optJSONArray("checkPoints");
                            if (checkPoints != null) {
                                try {
                                    long duration = extra.optLong("durationRemaining");
                                    for (int i = 0; i < checkPoints.length(); i++) {
                                        if ((duration - (int) checkPoints.get(i)) > 1000) {
                                            long checkpoint = (duration - (int) checkPoints.get(i)) / 1000;
                                            mWebRTCInfo.RemainingTimeCheckPoints.add(checkpoint);
                                            myLogDebug(TAG, "checkpoint: " + checkpoint);
                                        }
                                    }
                                } catch (JSONException | ClassCastException e) {
                                    e.printStackTrace();
                                }
                            }
                            mWebRTCInfo.MeetingId = extra.optString("moderatedSessionId");
                        }
                        mWebRTCInfo.IsUIStateChanged = true;
                        setChanged();
                        notifyObservers();

                        //AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());

                        startRemainingTimeTimer(mWebRTCInfo.RemainingTime);
                        break;
                    case "unset-moderator":
                        mWebRTCInfo.ModeratorMode = false;
                        mWebRTCInfo.IsModeratorLeave = true;
                        mWebRTCInfo.ModeratorId = "";
                        mWebRTCInfo.ModeratorName = "";
                        mWebRTCInfo.IsUIStateChanged = true;
                        mWebRTCInfo.MeetingId = "";
                        setChanged();
                        notifyObservers();

                        //AppCenterAnalyticsHelper.getInstance().setEventProperties(buildEventProperties());

                        stopRemainingTimeTimer();
                        break;
                    case "get-display-state":
                        try {
                            JSONObject reply = new JSONObject();
                            reply.put("messageFor", mWebRTCInfo.DisplayCode);
                            reply.put("action", "display-state-update");
                            reply.put("status", "display-state-update");
                            JSONObject replyExtra = new JSONObject();
                            // replyExtra.put("windowState", "fullscreen");
                            replyExtra.put("presentationState", mWebRTCInfo.PresentationState.toString());
                            JSONObject uiState = new JSONObject();
                            uiState.put("code", mWebRTCInfo.IsShowCode);
                            uiState.put("delegate", mWebRTCInfo.IsShowDelegate);
                            replyExtra.put("uiState", uiState);
                            reply.put("extra", replyExtra);
                            reply.put("messageId", response.opt("nextId"));
                            reply.put("nextId", getRandomString(21));
                            sendMessageToControlSocket(mWebRTCInfo.DisplayCode, reply);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        break;
                    case "set-ui-state":
                        if (extra != null) {
                            mWebRTCInfo.IsShowCode = extra.optBoolean("code");
                            mWebRTCInfo.IsShowDelegate = extra.optBoolean("delegate");
                            mWebRTCInfo.IsUIStateChanged = true;
                            setChanged();
                            notifyObservers();
                            sendMessageToControlSocket(mWebRTCInfo.DisplayCode);
                        }
                        break;
                    case "control":
                        JSONObject status = response.optJSONObject("status");
                        if (status != null) {
                            String statusAction = status.optString("action");
                            switch (statusAction) {
                                case "setClient":
                                    if (extra != null) {
                                        String clientId = extra.optString("setClientId");
                                        String allowId = extra.optString("setAllowedPeer");
                                        if (mClientId.isEmpty()) {
                                            mWebRTCInfo.PresentationState = ePresentationState.waitForStream;
                                            JSONObject presenter = extra.optJSONObject("presenter");
                                            if (presenter != null) {
                                                mWebRTCInfo.PresenterId = presenter.optString("id");
                                                mWebRTCInfo.PresenterName = presenter.optString("name");
                                            }
                                            mWebRTCInfo.IsUIStateChanged = true;
                                            setChanged();
                                            if (!mWebRTCInfo.ModeratorMode) {
                                                notifyObservers("startConnectTimeOutTimer");
                                            } else {
                                                notifyObservers();
                                            }
                                            sendMessageToControlSocket(mWebRTCInfo.DisplayCode);

                                            connectP2pClient(clientId, allowId, response);

                                            //AppCenterAnalyticsHelper.getInstance().EventStreamStart();
                                        } else {
                                            sendMessageToControlSocket(mWebRTCInfo.DisplayCode, allowId, "blocked");
                                        }
                                    }
                                    break;
                                case "play":
                                    // todo: moderator start play?
                                    if (userid.equals(mAllowId)) {
                                        streamPlay();

                                        //AppCenterAnalyticsHelper.getInstance().EventStreamPlayed();
                                    }
                                    break;
                                case "stop":
                                    if (userid.equals(mAllowId)) {
                                        streamStop();

                                        //AppCenterAnalyticsHelper.getInstance().EventStreamStopped();
                                    }
                                    break;
                            }
                        } else {
                            sendMessageToControlSocket(mWebRTCInfo.DisplayCode, userid, "denied");
                        }
                        break;
                    case "pauseVideo":
                        String nextId = response.optString("nextId");
                        if (userid.equals(mAllowId)) {
                            streamPause(nextId);

                            //AppCenterAnalyticsHelper.getInstance().EventStreamPaused();
                        }
                        break;
                    case "resumeVideo":
                        if (userid.equals(mAllowId)) {
                            streamResume();

                            //AppCenterAnalyticsHelper.getInstance().EventStreamResumed();
                        }
                        break;
                }
            }
        }
    }

    // region Control Socket
    public void connectControlSocket(String gatewayUrl, String displayID) {
        android.util.Log.e(TAG, "zz connectControlSocket "+ displayID );
        mDisplaySocketReConnect.setValue(false);
        try {
            IO.Options options = new IO.Options();
            options.forceNew = true;
            options.reconnection = true;
            options.reconnectionAttempts = MAX_RECONNECT_ATTEMPTS;
            options.query = "socketCustomEvent=" + displayID + "&role=display&deviceId=" + mWebRTCInfo.InstanceId + "&token=" + mWebRTCInfo.Token;
            if (mControlSocketIO != null) {
                myLogDebug(TAG, "stop reconnecting the former url");
                mControlSocketIO.disconnect();
            }
            mControlSocketIO = IO.socket(gatewayUrl, options);
            mControlSocketIO
                    .on(Socket.EVENT_CONNECT, args -> printControlSocketLog(Socket.EVENT_CONNECT, args))
                    .on(Socket.EVENT_CONNECTING, args -> printControlSocketLog(Socket.EVENT_CONNECTING, args))
                    .on(Socket.EVENT_DISCONNECT, args -> printControlSocketLog(Socket.EVENT_DISCONNECT, args))
                    .on(Socket.EVENT_ERROR, args -> printControlSocketLog(Socket.EVENT_ERROR, args))
                    .on(Socket.EVENT_MESSAGE, args -> printControlSocketLog(Socket.EVENT_MESSAGE, args))
                    .on(Socket.EVENT_CONNECT_ERROR, args -> {
                        printControlSocketLog(Socket.EVENT_CONNECT_ERROR, args);
                        if (mDisplayReconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
                            mDisplayReconnectAttempts = 0;

                            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                                mDisplaySocketReConnect.postValue(true);
                                connectControlSocket(gatewayUrl, displayID);
                            }, 5000);
                        }
                    })
                    .on(Socket.EVENT_RECONNECTING, args -> {
                        printControlSocketLog(Socket.EVENT_RECONNECTING, args);
                        mDisplayReconnectAttempts++;
                    })
                    .on(displayID, args -> {
                        printControlSocketLog(displayID, args);
                        handleDisplayResponse(args);
                    });

            mControlSocketIO.connect();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
    }

    private void disconnectControlSocket() {
        if (mControlSocketIO != null) {
            mControlSocketIO.disconnect();
            mControlSocketIO = null;
        }
    }

    private void sendMessageToControlSocket(String messageFor, String allow, String action) {
        if (mControlSocketIO == null) {
            myLogDebug(TAG, "mDisplaySocketIO is not established.");
            return;
        }

        JSONObject content = new JSONObject();
        try {
            content.put("messageFor", allow);
            content.put("action", action);
            content.put("display", messageFor);
            content.put("streamer", BuildConfig.VERSION_NAME);
            content.put("capacities", new JSONArray());

            myLogDebug(TAG, "sendMessageToControlSocket: " + content.toString());

            mControlSocketIO.emit(messageFor, content);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void sendMessageToControlSocket(String messageFor, JSONObject reply) {
        if (mControlSocketIO == null) {
            myLogDebug(TAG, "mDisplaySocketIO is not established.");
            return;
        }
        myLogDebug(TAG, "sendMessageToControlSocket: " + reply.toString());

        mControlSocketIO.emit(messageFor, reply);
    }

    private void sendMessageToControlSocket(String messageFor) {
        if (mControlSocketIO == null) {
            myLogDebug(TAG, "mDisplaySocketIO is not established.");
            return;
        }

        JSONObject content = new JSONObject();
        try {
            content.put("messageFor", mWebRTCInfo.DisplayCode);
            content.put("action", "display-state-update");
            content.put("action", "display-state-update");
            JSONObject extra = new JSONObject();
            JSONObject uiState = new JSONObject();
            uiState.put("code", mWebRTCInfo.IsShowCode);
            uiState.put("delegate", mWebRTCInfo.IsShowDelegate);
            extra.put("uiState", uiState);
            extra.put("presentationState", mWebRTCInfo.PresentationState.toString());
            content.put("extra", extra);
            content.put("messageId", getRandomString(21));
            content.put("nextId", getRandomString(21));

            myLogDebug(TAG, "sendMessageToControlSocket: " + content.toString());

            mControlSocketIO.emit(messageFor, content);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void printControlSocketLog(String event, Object... args) {
        myLogDebug(TAG, "mDisplaySocketIO: " + event);
        for (Object arg : args) {
            myLogDebug(TAG, arg.toString());
        }
    }
    // endregion Control Socket

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

    private void loggerParser(String s, String severity, String s1) {
        myLogDebug("loggerParser", String.format("severity: %s s1: %s s: %s", severity, s1, s));
        switch (severity) {
            case "LS_INFO":
                switch (s1) {
                    case "EglRenderer":
                        if (s.startsWith("remote_rendererDuration")) {
                            if (s.contains("Render fps:")) {
                                String fps = s.substring(s.indexOf("Render fps:") + 11, s.indexOf("Average") - 2);

                                if (mStreamFPS.offerFirst(fps)) {
                                    if (mStreamFPS.size() > 10) {
                                        mStreamFPS.removeLast();
                                    }
                                }
                                mFPS.postValue(mStreamFPS.toString());
                            }
                        }
                        break;
                    case "AndroidVideoDecoder":
                        if (s.startsWith("initDecodeInternal name:"))
                            mDecoder.postValue(s.substring(s.indexOf("name:")));
                        else if (s.contains("Release on output thread done"))
                            mDecoder.postValue("");
                        break;
                }
                break;
            case "LS_VERBOSE":
                break;
        }
    }
    // endregion

    private Map<String, String> buildEventProperties() {
        Map<String, String> properties = new HashMap<>();
        properties.put("displayId", mWebRTCInfo.InstanceId);
        properties.put("meetingId", mWebRTCInfo.MeetingId);
        properties.put("presenterId", mWebRTCInfo.PresenterId);
        properties.put("licenseName", mWebRTCInfo.LicenseName);
        properties.put("version", BuildConfig.VERSION_NAME);
        return properties;
    }

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
