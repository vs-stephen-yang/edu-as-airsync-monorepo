package com.mvbcast.crosswalk.helper;

import static owt.base.MediaCodecs.VideoCodec.H264;
import static owt.base.MediaCodecs.VideoCodec.H265;
import static owt.base.MediaCodecs.VideoCodec.VP8;
import static owt.base.MediaCodecs.VideoCodec.VP9;

import android.app.Activity;
import android.app.AlertDialog;
import android.os.Build;
import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.mvbcast.crosswalk.BuildConfig;
import com.mvbcast.crosswalk.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.EglBase;
import org.webrtc.Logging;
import org.webrtc.PeerConnection;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayDeque;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import javax.net.ssl.HttpsURLConnection;

import owt.base.ContextInitialization;
import owt.base.VideoEncodingParameters;
import owt.p2p.P2PClientConfiguration;

/**
 * Created by ChangLo on 2022/05/26.
 * WebRTC Helper (Singleton)
 */

public class WebRTCHelper {
    private static final String TAG = WebRTCHelper.class.getSimpleName();
    EglBase mRootEglBase = EglBase.create();

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
    @SuppressWarnings({"UnusedDeclaration", "UnusedAssignment"})
    public void onActivityDestroy() {
        ContextInitialization contextInitialization = ContextInitialization.create();
        contextInitialization = null;
    }

    public void initWebRTCContext(Activity activity) {
        try {
            ContextInitialization.create()
                    .setApplicationContext(activity)
                    .setVideoHardwareAccelerationOptions(
                            mRootEglBase.getEglBaseContext(),
                            mRootEglBase.getEglBaseContext())
                    .setCustomizedLoggableFactory((s, severity, s1) ->
                            loggerParser(s, severity.name(), s1), Logging.Severity.LS_VERBOSE)
                    .initialize();
        } catch (RuntimeException e) {
            new AlertDialog.Builder(activity)
                    .setTitle(R.string.unsupported_device_title)
                    .setMessage(activity.getString(R.string.unsupported_device_msg) + "\n\n\"" + e.getMessage() + "\"")
                    .setPositiveButton(android.R.string.yes, (dialog, which) -> {
                        // Continue with delete operation
                        activity.finish();
                        System.exit(0);
                    })
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .show();
        }
    }

    public EglBase.Context getRootEglBaseContext() {
        return mRootEglBase.getEglBaseContext();
    }

    public P2PClientConfiguration getAndSetConfigOfIceServers() {

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
                if (Build.MODEL.contains("50-2")) {
                    // disable the prerenderer smoothing to workaround the low fps issue on 50-2
                    mP2pConfig.rtcConfiguration.enablePrerendererSmoothing = false;
                }
                myLogDebug(TAG, "iceServersFromPCConfigJSON() is ok");
            } catch (JSONException e) {
                e.printStackTrace();
                myLogDebug(TAG, e.getMessage());
            }

            return mP2pConfig;
        }

        return null;
    }

    public LiveData<Boolean> getDebugInfoVisible() {
        return mIsDebugInfoVisible;
    }

    public void setDebugInfoVisible(boolean visible) {
        if (DEBUG_MESSAGE) { // only show debug on stage version.
            mIsDebugInfoVisible.postValue(visible);
        }
    }

    public LiveData<String> getDecoder() {
        return mDecoder;
    }

    public LiveData<String> getFPS(String key) {
        return mFPS.get(key);
    }

    public void clearFPS(String key) {
        ArrayDeque<String> data = mStreamFPS.get(key);
        if (data != null) {
            data.clear();
        }
    }

    //-------------------------------------------------------------------------
    // endregion public Implementation

    // region private Implementation
    //-------------------------------------------------------------------------

    private P2PClientConfiguration mP2pConfig;
    private final MutableLiveData<Boolean> mIsDebugInfoVisible = new MutableLiveData<>();

    {
        mIsDebugInfoVisible.postValue(false);
    }

    private final MutableLiveData<String> mDecoder = new MutableLiveData<>();
    private final Map<String, MutableLiveData<String>> mFPS = new HashMap<String, MutableLiveData<String>>() {{
        put("remoteRenderMain", new MutableLiveData<>());
        put("remoteRenderSub1", new MutableLiveData<>());
        put("remoteRenderSub2", new MutableLiveData<>());
        put("remoteRenderSub3", new MutableLiveData<>());
    }};
    private final Map<String, ArrayDeque<String>> mStreamFPS = new HashMap<String, ArrayDeque<String>>() {{
        put("remoteRenderMain", new ArrayDeque<>());
        put("remoteRenderSub1", new ArrayDeque<>());
        put("remoteRenderSub2", new ArrayDeque<>());
        put("remoteRenderSub3", new ArrayDeque<>());
    }};
    @SuppressWarnings("ConstantConditions")
    private static final boolean DEBUG_MESSAGE = (BuildConfig.VERSION_CODE % 2) != 0;

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
                myLogDebug(TAG, "Response: > " + line);   //here u ll get whole response...... :-)
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

    @SuppressWarnings("SameParameterValue")
    private static void myLogDebug(String tag, String msg) {
        if (DEBUG_MESSAGE) {
            Log.d(tag, msg);
        }
    }

    private void loggerParser(String s, String severity, String s1) {
        if (!DEBUG_MESSAGE) return; // only show debug on stage version.
        myLogDebug("loggerParser", String.format("severity: %s s1: %s s: %s", severity, s1, s));
        switch (severity) {
            case "LS_INFO":
                switch (s1) {
                    case "EglRenderer":
                        if (s.contains("Render fps:")) {
                            String key = s.substring(0, s.indexOf("Duration"));
                            ArrayDeque<String> stream = mStreamFPS.get(key);
                            if (stream != null) {
                                String fps = s.substring(s.indexOf("Render fps:") + 11, s.indexOf("Average") - 2);
                                if (stream.offerFirst(fps)) {
                                    if (stream.size() > 10) {
                                        stream.removeLast();
                                    }
                                }
                                MutableLiveData<String> liveFPS = mFPS.get(key);
                                if (liveFPS != null) {
                                    liveFPS.postValue(stream.toString());
                                    mFPS.put(key, liveFPS);
                                }
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

    //-------------------------------------------------------------------------
    // endregion private Implementation
}
