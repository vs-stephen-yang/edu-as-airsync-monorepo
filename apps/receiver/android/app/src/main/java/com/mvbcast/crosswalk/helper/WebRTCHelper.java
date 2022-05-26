package com.mvbcast.crosswalk.helper;

import android.app.Activity;
import android.app.AlertDialog;
import android.os.Build;
import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.mvbcast.crosswalk.BuildConfig;

import org.webrtc.EglBase;
import org.webrtc.Logging;
import org.webrtc.SoftwareVideoDecoderFactory;

import java.util.ArrayDeque;

import owt.base.ContextInitialization;

/**
 * Created by ChangLo on 2022/05/26.
 * WebRTC Helper (Singleton)
 */

public class WebRTCHelper {
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
            boolean isForceSW = Build.MODEL.contains("50-2");

            if (isForceSW) mDecoder.postValue("Use Software Video Decoder.");

            ContextInitialization.create()
                    .setApplicationContext(activity)
                    .setVideoHardwareAccelerationOptions(
                            mRootEglBase.getEglBaseContext(),
                            mRootEglBase.getEglBaseContext())
                    .setCustomizedVideoDecoderFactory(isForceSW ? new SoftwareVideoDecoderFactory() : null)
                    .setCustomizedLoggableFactory((s, severity, s1) ->
                            loggerParser(s, severity.name(), s1), Logging.Severity.LS_VERBOSE)
                    .initialize();
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

    public EglBase.Context getRootEglBaseContext() {
        return mRootEglBase.getEglBaseContext();
    }

    public LiveData<String> getDecoder() {
        return mDecoder;
    }

    public LiveData<String> getFPS() {
        return mFPS;
    }

    //-------------------------------------------------------------------------
    // endregion public Implementation

    // region private Implementation
    //-------------------------------------------------------------------------
    private final MutableLiveData<String> mDecoder = new MutableLiveData<>();
    private final MutableLiveData<String> mFPS = new MutableLiveData<>();
    private final ArrayDeque<String> mStreamFPS = new ArrayDeque<>();
    @SuppressWarnings("ConstantConditions")
    private static final boolean DEBUG_MESSAGE = (BuildConfig.VERSION_CODE % 2) != 0;

    @SuppressWarnings("SameParameterValue")
    private static void myLogDebug(String tag, String msg) {
        if (DEBUG_MESSAGE) {
            Log.d(tag, msg);
        }
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

    //-------------------------------------------------------------------------
    // endregion private Implementation
}
