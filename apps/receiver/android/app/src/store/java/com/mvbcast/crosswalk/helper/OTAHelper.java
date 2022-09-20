package com.mvbcast.crosswalk.helper;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.mvbcast.crosswalk.BuildConfig;
import com.mvbcast.crosswalk.EulaActivity;
import com.mvbcast.crosswalk.R;

import java.lang.ref.WeakReference;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Observable;
import java.util.concurrent.TimeUnit;


/*
 * Created by ChangLo on 2020/02/25.
 * Update Helper (Singleton)
 * https://medium.com/@sembozdemir/force-your-users-to-update-your-app-with-using-firebase-33f1e0bcec5a
 * https://firebase.google.com/docs/remote-config/android
 */

/**
 * OTA from Firebase
 */
public final class OTAHelper extends Observable {
    private static final String TAG = OTAHelper.class.getSimpleName();
    private static final String KEY_STORE_VERSION_STAGE = "android_latest_version_stage";
    private static final String KEY_STORE_VERSION = "android_latest_version";
    private static final String KEY_STORE_URL = "android_store_url";
    private static final String STORE_URL =
            "https://play.google.com/store/apps/details?id=" + BuildConfig.APPLICATION_ID;

    // region Singleton Implementation
    // https://android.jlelse.eu/how-to-make-the-perfect-singleton-de6b951dfdb0
    //-------------------------------------------------------------------------
    private static volatile OTAHelper INSTANCE = null;

    // private constructor.
    private OTAHelper() {
        // Prevent form the reflection api.
        if (INSTANCE != null) {
            throw new RuntimeException("Use getInstance() method to get the single instance of this class.");
        }
    }

    public static OTAHelper getInstance() {
        // Double check locking pattern
        if (INSTANCE == null) {// Check for the first time
            synchronized (OTAHelper.class) {// Check for the second time.
                // if there is no instance available... create new one
                if (INSTANCE == null) INSTANCE = new OTAHelper();
            }
        }
        return INSTANCE;
    }
    //-------------------------------------------------------------------------
    // endregion Singleton Implementation

    // region private Implementation
    //-------------------------------------------------------------------------
    private Date lastTime = Calendar.getInstance().getTime();
    private boolean mForceCheckVersion = true; // Init true for startup without network connected.
    private boolean mIsChecking = false;
    private AlertDialog mAlertDialog;
    private WeakReference<EulaActivity> mActivityRef;

    @SuppressWarnings("all")
    private void initFireBaseDefaultSettings() {
        FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.getInstance();

        FirebaseRemoteConfigSettings configSettings = new FirebaseRemoteConfigSettings.Builder()
                .setMinimumFetchIntervalInSeconds(3600L).build();
        remoteConfig.setConfigSettingsAsync(configSettings);

        // set in-app defaults
        Map<String, Object> remoteConfigDefaults = new HashMap<>();
        if (BuildConfig.FLAVOR_stage.equals("stage")) {
            remoteConfigDefaults.put(KEY_STORE_VERSION_STAGE, getAppVersion());
            remoteConfigDefaults.put(KEY_STORE_URL, STORE_URL);
        } else {
            remoteConfigDefaults.put(KEY_STORE_VERSION, getAppVersion());
            remoteConfigDefaults.put(KEY_STORE_URL, STORE_URL);
        }

        remoteConfig.setDefaultsAsync(remoteConfigDefaults);
        remoteConfig.fetchAndActivate()
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        Log.d(TAG, "Fetch and activate succeeded. Config params updated: " + task.getResult());
                    } else {
                        Log.d(TAG, "Fetch Failed.");
                    }
                });
    }

    private boolean isValidString(String string) {
        return string != null && !string.isEmpty() && !string.equals("null");
    }

    private String getAppVersion() {
        String version = BuildConfig.VERSION_NAME;
        // noinspection ConstantConditions
        if (version.contains("-")) {
            version = version.substring(0, version.indexOf("-"));
        }
        return version;
    }

    /**
     * Compares two version strings.
     * <p>
     * Use this instead of String.compareTo() for a non-lexicographical
     * comparison that works for version strings. e.g. "1.10".compareTo("1.6").
     *
     * @param str1 a string of ordinal numbers separated by decimal points.
     * @param str2 a string of ordinal numbers separated by decimal points.
     * @return The result is a negative integer if str1 is _numerically_ less than str2.
     * The result is a positive integer if str1 is _numerically_ greater than str2.
     * The result is zero if the strings are _numerically_ equal.
     * @ note It does not work if "1.10" is supposed to be equal to "1.10.0".
     */
    private int versionCompare(String str1, String str2) {
        if (!isValidString(str1) || !isValidString(str2)) {
            return 0; // return equal for nothing.
        }
        Log.d(TAG, "remote:" + str1 + ", local:" + str2);
        String[] values1 = str1.split("\\.");
        String[] values2 = str2.split("\\.");
        int i = 0;
        // set index to first non-equal ordinal or length of shortest version string
        while (i < values1.length && i < values2.length && values1[i].equals(values2[i])) {
            i++;
        }
        // compare first non-equal ordinal number
        if (i < values1.length && i < values2.length) {
            int diff = Integer.valueOf(values1[i]).compareTo(Integer.valueOf(values2[i]));
            return Integer.signum(diff);
        }
        // the strings are equal or one string is a substring of the other
        // e.g. "1.2.3" = "1.2.3" or "1.2.3" < "1.2.3.4"
        return Integer.signum(values1.length - values2.length);
    }

    private boolean isTimeDiffExceeded(Date oldTime, Date newTime) {
        final long min = TimeUnit.MILLISECONDS.toMinutes(newTime.getTime() - oldTime.getTime());
        Log.d(TAG, "min: " + min + ", over 5 min? " + (min > 5));
        return min > 5;
    }
    //-------------------------------------------------------------------------
    // endregion private Implementation

    // region public Implementation
    //-------------------------------------------------------------------------
    public interface OnCheckLatestVersion {
        void noNewVersion();
    }

    public void clearForceCheckVersion() {
        mForceCheckVersion = false;
    }

    public void checkLatestVersion() {
        if (mActivityRef != null && mActivityRef.get() != null) {
            checkLatestVersion(mActivityRef.get(), null);
        }
    }

    public void checkLatestVersion(final Activity activity, OnCheckLatestVersion oncheckLatestVersion) {
        Log.d(TAG, "checkLatestVersion");
        if (mActivityRef == null && activity instanceof EulaActivity) {
            mActivityRef = new WeakReference<>((EulaActivity) activity);
        }

        Date currentTime = Calendar.getInstance().getTime();
        if (isTimeDiffExceeded(lastTime, currentTime) || mForceCheckVersion) {

            lastTime = currentTime;

            if (mIsChecking) return;
            mIsChecking = true;
            initFireBaseDefaultSettings();
            FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.getInstance();
            String version;
            //noinspection ConstantConditions
            if (BuildConfig.FLAVOR_stage.equals("stage")) {
                version = remoteConfig.getString(KEY_STORE_VERSION_STAGE);
            } else {
                version = remoteConfig.getString(KEY_STORE_VERSION);
            }
            if (versionCompare(version, getAppVersion()) > 0) {
                AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                builder.setIcon(R.mipmap.ic_launcher)
                        .setTitle(activity.getText(R.string.update_title))
                        .setMessage(activity.getText(R.string.update_goto_store_url))
                        .setPositiveButton(R.string.update_install_now, (dialog, which) -> {
                            final String updateUrl = remoteConfig.getString(KEY_STORE_URL);
                            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(updateUrl));
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            activity.startActivity(intent);
                            System.exit(0);
                        })
                        .setCancelable(false);
                mAlertDialog = builder.create();
                mAlertDialog.show();
                return;
            }
            if (oncheckLatestVersion != null) {
                oncheckLatestVersion.noNewVersion();
            }
            mIsChecking = false;
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    public void removeDownloadProcess(final Context context) {

        mIsChecking = false;
        if (mAlertDialog != null && mAlertDialog.isShowing()) mAlertDialog.dismiss();
    }

    @SuppressWarnings("UnusedDeclaration")
    public boolean onRequestPermissionsResult(Activity activity, int requestCode, @NonNull String[] permissions,
                                              @NonNull int[] grantResults) {
        return false;
    }

    @SuppressWarnings("UnusedDeclaration")
    public boolean onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        return false;
    }
    //-------------------------------------------------------------------------
    // endregion public Implementation
}
