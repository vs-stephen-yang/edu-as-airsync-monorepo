package com.mvbcast.crosswalk.helper;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DownloadManager;
import android.app.PendingIntent;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageInstaller;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;
import androidx.core.content.FileProvider;

import com.google.android.gms.common.GoogleApiAvailability;
import com.mvbcast.crosswalk.BuildConfig;
import com.mvbcast.crosswalk.EulaActivity;
import com.mvbcast.crosswalk.R;
import com.viewsonic.vsapi.VSContext;
import com.viewsonic.vsapi.VSServiceManager;
import com.viewsonic.vsapi.VSSystemManager;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.ref.WeakReference;
import java.util.Calendar;
import java.util.Date;
import java.util.Observable;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.net.ssl.HttpsURLConnection;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * OTA From AWS
 */
public final class OTAHelper extends Observable {
    private static final String TAG = OTAHelper.class.getSimpleName();
    private final int INSTALL_PACKAGES_REQUEST_CODE = 200;
    private final int GET_UNKNOWN_APP_SOURCES = 201;
    private Date lastTime = Calendar.getInstance().getTime();
    private boolean mForceCheckVersion = true; // Init true for startup without network connected.

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
    // Add "dot" to hide this temp folder.
    private String HIDDEN_TEMP_FOLDER = ".myViewBoardDisplayTemp";
    private boolean mIsChecking = false;
    private long mDownloadID = -1;
    private DownloadManager mDownloadManager;
    private File mFile;
    private boolean mbRegistered = false;
    private AlertDialog mAlertDialog;
    private WeakReference<EulaActivity> mActivityRef;
    private WeakReference<TextView> mTextProgressRef;
    private WeakReference<ProgressBar> mProgressBarRef;

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

    /**
     * https://blog.csdn.net/kris_fei/article/details/90171912
     * https://stackoverflow.com/questions/46036877/android-7-nullpointerexception-on-apk-installing-with-runtime-getruntime-exec
     * https://cloud.tencent.com/developer/ask/141262
     */
    @SuppressWarnings("ConstantConditions")
    private void OpenNewVersion(Activity activity) {
        if (BuildConfig.FLAVOR_channel.equals("ifp")) {
            new Handler(Looper.getMainLooper()).post(() -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    // for IFP52, IFP32 (Android 9): can not use Runtime command install
                    boolean result = installAppSilently(activity, mFile.getPath());
                    Log.d(TAG, "installAppSilently result:" + result);
                } else {
                    try {
                        String command = "pm install -r -i com.mvbcast.crosswalk --user 0 " + mFile.getPath();
                        Log.d(TAG, command);
                        Process proc = Runtime.getRuntime().exec(command);
                        proc.waitFor();
                        int exitValue = proc.exitValue();
                        if (mAlertDialog != null && mAlertDialog.isShowing())
                            mAlertDialog.dismiss();
                        if (exitValue != 0) {
                            Toast.makeText(activity, activity.getString(R.string.update_ota_failure_retry), Toast.LENGTH_LONG).show();
                            //noinspection ResultOfMethodCallIgnored
                            mFile.delete();
                            mForceCheckVersion = true;
                            mIsChecking = false;
                            checkLatestVersion(activity, mCheckLatestVersion);
                        }
                    } catch (IOException | InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            });
        } else if (BuildConfig.FLAVOR_channel.equals("open")) {
            mIsChecking = false;
            new AlertDialog.Builder(activity)
                    .setIcon(R.mipmap.ic_launcher)
                    .setTitle(activity.getText(R.string.update_title))
                    .setMessage(activity.getText(R.string.update_message))
                    .setCancelable(false)
                    .setPositiveButton(R.string.update_install_now, (dialog, which) -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                                !activity.getPackageManager().canRequestPackageInstalls()) {
                            ActivityCompat.requestPermissions(activity,
                                    new String[]{Manifest.permission.REQUEST_INSTALL_PACKAGES},
                                    INSTALL_PACKAGES_REQUEST_CODE);
                        } else {
                            installAPK(activity);
                        }
                    })
                    .create()
                    .show();
        }
    }

    private void installAPK(final Activity activity) {
        if (mAlertDialog != null && mAlertDialog.isShowing()) mAlertDialog.dismiss();
        if (mCheckLatestVersion != null) {
            mCheckLatestVersion.noNewVersion();
        }

        if (mFile == null || !mFile.exists()) return;
        Uri uri;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            uri = FileProvider.getUriForFile(activity, BuildConfig.APPLICATION_ID, mFile);
        } else {
            uri = Uri.fromFile(mFile);
        }
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(uri, "application/vnd.android.package-archive");
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_GRANT_READ_URI_PERMISSION);
        activity.startActivity(intent);
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            activity.finish();
            System.exit(0);
        }, (isArc(activity) ? 5000 : 1000));
    }

    private final BroadcastReceiver onComplete = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            //check if the broadcast message is for our Enqueued download
            long referenceId = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1);
            if (referenceId != mDownloadID) {
                return;
            }

            Cursor c = null;
            try {
                c = mDownloadManager.query(new DownloadManager.Query().setFilterById(mDownloadID));
            } catch (Exception e) {
                e.printStackTrace();
                Toast.makeText(context, context.getString(R.string.update_ota_query_status_failure), Toast.LENGTH_LONG).show();
                removeDownloadProcess(context);
            }
            if (c != null) {
                if (c.moveToFirst()) {
                    int index = c.getColumnIndex(DownloadManager.COLUMN_STATUS);
                    if (index >= 0) {
                        int status = c.getInt(index);
                        if (status == DownloadManager.STATUS_SUCCESSFUL) {
                            mDownloadID = -1;
                            if (context instanceof Activity) {
                                Activity activity = (Activity) context;
                                activity.runOnUiThread(() -> {
                                    if (mProgressBarRef.get() != null)
                                        mProgressBarRef.get().setProgress(100);
                                    if (mTextProgressRef.get() != null)
                                        mTextProgressRef.get()
                                                .setText(String.format(activity.getString(R.string.update_progress_text), 100));
                                });
                                OpenNewVersion(activity);
                            }
                        } else if (status == DownloadManager.STATUS_FAILED) {
                            Log.e(TAG, "Download file failure.");
                            removeDownloadProcess(context);
                        }
                    }
                }
                c.close();
            }
            if (mbRegistered) {
                context.unregisterReceiver(this);
                mbRegistered = false;
            }
        }
    };

    private void downloadAndInstall(final Activity activity, final String stringFileUrl) {
        String strDownloadFolder = activity.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS) + "/";
        if (mDownloadID != -1) {
            Log.e(TAG, "Downloading");
            return;
        }
        // Get filename
        final String filename = stringFileUrl.substring(stringFileUrl.lastIndexOf("/") + 1);
        // The place where the downloaded file will be put
        mFile = new File(strDownloadFolder, filename);
        if (mFile.exists()) {
            PackageInfo packageInfo =
                    activity.getPackageManager().getPackageArchiveInfo(mFile.getAbsolutePath(), 0);
            if (packageInfo != null) {
                Log.e(TAG, packageInfo.packageName);
                // you can be sure that it is a valid apk
                // If we have downloaded the file before, just go ahead to install it.
                activity.runOnUiThread(() -> {
                    if (mProgressBarRef.get() != null)
                        mProgressBarRef.get().setProgress(100);
                    if (mTextProgressRef.get() != null)
                        mTextProgressRef.get()
                                .setText(String.format(activity.getString(R.string.update_progress_text), 100));
                });
                OpenNewVersion(activity);
                return;
            } else {
                // not a valid apk
                Log.e(TAG, "Downloaded package is invalid.");
                //noinspection ResultOfMethodCallIgnored
                mFile.delete();
            }
        }

        // Create the download request
        DownloadManager.Request dmReq = new DownloadManager.Request(Uri.parse(stringFileUrl));
        dmReq.setDestinationInExternalFilesDir(activity, Environment.DIRECTORY_DOWNLOADS + "/", filename);
        dmReq.setNotificationVisibility(DownloadManager.Request.VISIBILITY_HIDDEN);
        mDownloadManager = (DownloadManager) activity.getSystemService(Context.DOWNLOAD_SERVICE);

        activity.registerReceiver(onComplete, new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
        mbRegistered = true;

        // Enqueue the request
        mDownloadID = mDownloadManager.enqueue(dmReq);

        // Update download status.
        new Thread(() -> {
            boolean downloading = true;
            while (downloading) {
                if (mDownloadID != -1) {
                    Cursor c = null;
                    try {
                        c = mDownloadManager.query(new DownloadManager.Query().setFilterById(mDownloadID));
                    } catch (Exception e) {
                        e.printStackTrace();
                        Toast.makeText(activity, activity.getString(R.string.update_ota_query_status_failure), Toast.LENGTH_LONG).show();
                        removeDownloadProcess(activity);
                    }
                    if (c != null) {
                        if (c.moveToFirst()) {
                            int downloaded = c.getColumnIndex(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR);
                            int total_bytes = c.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES);
                            if (downloaded >= 0 && total_bytes >= 0) {
                                int so_far = c.getInt(downloaded);
                                int total = c.getInt(total_bytes);

                                int status = c.getColumnIndex(DownloadManager.COLUMN_STATUS);
                                if (c.getInt(status) ==
                                        DownloadManager.STATUS_SUCCESSFUL) {
                                    downloading = false;
                                }

                                final int dl_progress = total > 0 ? (int) ((so_far * 100L) / total) : 0;
                                activity.runOnUiThread(() -> {
                                    if (mProgressBarRef.get() != null)
                                        mProgressBarRef.get().setProgress(dl_progress);
                                    if (mTextProgressRef.get() != null)
                                        mTextProgressRef.get()
                                                .setText(String.format(activity.getString(R.string.update_progress_text),
                                                        dl_progress));
                                });
                                setChanged();
                                notifyObservers(dl_progress);
                            }
                        } else {
                            downloading = false;
                        }
                        c.close();
                    }
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                } else {
                    downloading = false;
                }
            }

        }).start();

    }

    private boolean isTimeDiffExceeded(Date oldTime, Date newTime) {
        final long min = TimeUnit.MILLISECONDS.toMinutes(newTime.getTime() - oldTime.getTime());
        Log.d(TAG, "min: " + min + ", over 5 min? " + (min > 5));
        return min > 5;
    }

    private boolean installAppSilently(final Context context, final String filePath) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (installViaVsApi(context, filePath)) {
                Log.d(TAG, "installViaVsApi success.");
                return true;
            }
            Log.e(TAG, "installViaVsApi failure. Fall back to old mechanism.");
        }
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
                ? installViaPackageInstaller(context, filePath)
                : installViaCommandExe(context, filePath);
    }

    /**
     * Executing command will hang the UI, move to new Thread to execute.
     */
    private boolean installViaCommandExe(Context context, String filePath) {
        final AtomicBoolean result = new AtomicBoolean(false);
        Thread thread = new Thread(() -> {
            try {
                String command = "pm install -r -i " + context.getPackageName() + " --user 0 " + filePath;
                Log.d(TAG, command);

                Process p = Runtime.getRuntime().exec(command);
                p.waitFor();

                BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
                BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));

                String s;
                while ((s = stdInput.readLine()) != null) {
                    Log.d(TAG, "stdInput s = " + s);
                    result.set(true);
                }
                // read any errors from the attempted command
                while ((s = stdError.readLine()) != null) {
                    Log.d(TAG, "stdError s = " + s);
                    result.set(false);
                }
            } catch (IOException | InterruptedException e) {
                Log.d(TAG, "installViaCommandExe e = " + e);
                e.printStackTrace();
                result.set(false);
            }
        });

        thread.start();
        try {
            thread.join();
        } catch (InterruptedException e) {
            Log.d(TAG, "installViaCommandExe e = " + e);
            e.printStackTrace();
            result.set(false);
        }
        Log.d(TAG, "installViaCommandExe result: " + result.get());
        return result.get();
    }

    @SuppressWarnings("ConstantConditions")
    private boolean installViaVsApi(Context context, String filePath) {
        final AtomicBoolean result = new AtomicBoolean(false);
        Thread thread = new Thread(() -> {
            try {
                VSSystemManager vsSystemManager = (VSSystemManager) VSServiceManager.getService(context, VSContext.VS_SYSTEM_SERVICE);
                if (vsSystemManager != null) {
                    vsSystemManager.installApp(copyFileToPublicFolder(new File(filePath)).getPath());
                    result.set(true);
                } else {
                    result.set(false);
                }
            } catch (IOException e) {
                e.printStackTrace();
                result.set(false);
            }
        });

        thread.start();
        try {
            thread.join();
        } catch (InterruptedException e) {
            Log.e(TAG, "installViaVsApi e = " + e);
            e.printStackTrace();
            result.set(false);
        }
        Log.d(TAG, "installViaVsApi result: " + result.get());
        return result.get();
    }

    private File createTempFolderIfNotExists() {
        File publicDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        File temp = new File(publicDirectory, HIDDEN_TEMP_FOLDER);
        if (!temp.exists()) {
            //noinspection ResultOfMethodCallIgnored
            temp.mkdir();
        }
        return temp;
    }

    private void removeTempFolder() {
        File temp = createTempFolderIfNotExists();
        deleteRecursive(temp);
    }

    private boolean deleteRecursive(File fileOrDirectory) {
        boolean fail = false;
        if (fileOrDirectory.isDirectory()) {
            File[] children = fileOrDirectory.listFiles();
            if (children != null) {
                for (File child : children)
                    fail |= !deleteRecursive(child);
            }
        }

        fail |= !fileOrDirectory.delete();
        return fail;
    }

    @SuppressWarnings("IOStreamConstructor")
    private File copyFileToPublicFolder(File src) throws IOException {
        File temp = createTempFolderIfNotExists();
        File dest = new File(temp, src.getName());
        Log.d(TAG, "dest path: " + dest.getPath());
        try (InputStream is = new FileInputStream(src); OutputStream os = new FileOutputStream(dest)) {
            byte[] buffer = new byte[1024];
            int len;
            while ((len = is.read(buffer)) != -1) {
                os.write(buffer, 0, len);
            }
            //noinspection ResultOfMethodCallIgnored
            src.delete();
        }
        return dest;
    }

    @RequiresApi(Build.VERSION_CODES.P)
    public boolean installViaPackageInstaller(Context context, String apkFilePath) {
        Log.d(TAG, "installViaPackageInstaller path=" + apkFilePath);
        File apkFile = new File(apkFilePath);
        PackageInstaller packageInstaller = context.getPackageManager().getPackageInstaller();
        PackageInstaller.SessionParams sessionParams
                = new PackageInstaller.SessionParams(PackageInstaller
                .SessionParams.MODE_FULL_INSTALL);
        sessionParams.setSize(apkFile.length());

        int sessionId = createSession(packageInstaller, sessionParams);
        Log.d(TAG, "installViaPackageInstaller  sessionId=" + sessionId);
        if (sessionId != -1) {
            boolean copySuccess = copyInstallFile(packageInstaller, sessionId, apkFilePath);
            Log.d(TAG, "installViaPackageInstaller  copySuccess=" + copySuccess);
            if (copySuccess) {
                execInstallCommand(context, packageInstaller, sessionId);
            }
        }
        return true;
    }

    private int createSession(PackageInstaller packageInstaller,
                                     PackageInstaller.SessionParams sessionParams) {
        int sessionId = -1;
        try {
            sessionId = packageInstaller.createSession(sessionParams);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return sessionId;
    }

    private boolean copyInstallFile(PackageInstaller packageInstaller,
                                           int sessionId, String apkFilePath) {
        InputStream in = null;
        OutputStream out = null;
        PackageInstaller.Session session = null;
        boolean success = false;
        try {
            File apkFile = new File(apkFilePath);
            session = packageInstaller.openSession(sessionId);
            out = session.openWrite("base.apk", 0, apkFile.length());
            in = new FileInputStream(apkFile);
            int total = 0, c;
            byte[] buffer = new byte[65536];
            while ((c = in.read(buffer)) != -1) {
                total += c;
                out.write(buffer, 0, c);
            }
            session.fsync(out);
            Log.i(TAG, "streamed " + total + " bytes");
            success = true;
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(out);
            closeQuietly(in);
            closeQuietly(session);
        }
        return success;
    }

    private void execInstallCommand(Context context, PackageInstaller packageInstaller, int sessionId) {
        PackageInstaller.Session session = null;
        try {
            session = packageInstaller.openSession(sessionId);
            Intent intent = new Intent("com.viewsonic.action.SILENT_INSTALL_APK_RESULT");
            PendingIntent pendingIntent;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                pendingIntent = PendingIntent.getBroadcast(context,
                        1, intent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            } else {
                pendingIntent = PendingIntent.getBroadcast(context,
                        1, intent,
                        PendingIntent.FLAG_UPDATE_CURRENT);
            }
            session.commit(pendingIntent.getIntentSender());
            Log.i(TAG, "begin session");
        } catch (Exception e) {
            Log.i(TAG, "execInstallCommand exception: "+ e.getMessage());
            e.printStackTrace();
        } finally {
            closeQuietly(session);
        }
    }

    private void closeQuietly(Closeable c) {
        if (c != null) {
            try {
                c.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private boolean isArc(Context context) {
        // Android Runtime for Chrome (ARC)
        // https://stackoverflow.com/questions/39784415/how-to-detect-programmatically-if-android-app-is-running-in-chrome-book-or-in
        // https://github.com/google/talkback/blame/9b1d5132b074174d02886faccf731e814d69363c/utils/src/main/java/FeatureSupport.java
        boolean arc = context.getPackageManager().hasSystemFeature("org.chromium.arc.device_management");
        return (Build.DEVICE != null && Build.DEVICE.matches(".+_cheets|cheets_.+")) || arc;
    }

    private boolean isCastSDKAvailable(Context context) {
        // check Google Play services availability
        int googlePlayServicesAvailability =
                GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(context);

        // check Cast SDK availability
        return googlePlayServicesAvailability ==
                com.google.android.gms.common.ConnectionResult.SUCCESS;
    }
    //-------------------------------------------------------------------------
    // endregion private Implementation

    // region public Implementation
    //-------------------------------------------------------------------------
    private OnCheckLatestVersion mCheckLatestVersion;
    private final OkHttpClient mHttpClient = new OkHttpClient();

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

        removeTempFolder();
        Date currentTime = Calendar.getInstance().getTime();
        if (isTimeDiffExceeded(lastTime, currentTime) || mForceCheckVersion) {

            lastTime = currentTime;

            if (mIsChecking) {
                Log.d(TAG, "OTA already on checking");
                return;
            }
            mIsChecking = true;
            Log.d(TAG, "latest version checking...");
            mCheckLatestVersion = oncheckLatestVersion;

            String requestUrl = activity.getString(R.string.app_ota_url);
            Request request = new Request.Builder()
                    .url(requestUrl)
                    .get()
                    .build();
            Call call = mHttpClient.newCall(request);
            call.enqueue(new Callback() {
                @Override
                public void onResponse(@NotNull Call call, @NotNull Response response) {
                    if (response.body() == null) return;
                    new Handler(Looper.getMainLooper()).post(() -> {
                        try {
                            Log.d(TAG, "response code:" + response.code());
                            if (response.code() == HttpsURLConnection.HTTP_OK) {
                                try {
                                    ResponseBody body = response.body();
                                    if (body == null) {
                                        if (mCheckLatestVersion != null) {
                                            Log.d(TAG, "response body is null");
                                            mCheckLatestVersion.noNewVersion();
                                        }
                                        mIsChecking = false;
                                        return;
                                    }

                                    JSONObject otaObject = new JSONObject(body.string());
                                    JSONArray result = otaObject.getJSONArray("list");
                                    if (result.length() < 2) {
                                        if (mCheckLatestVersion != null) {
                                            Log.d(TAG, "result format is wrong");
                                            mCheckLatestVersion.noNewVersion();
                                        }
                                        mIsChecking = false;
                                        return;
                                    }

                                    String[][] list = new String[result.length()][4];
                                    for (int i = 0; i < result.length(); i++) {
                                        JSONObject object = result.getJSONObject(i);
                                        list[i][0] = object.optString("file_name");
                                        list[i][1] = object.optString("last_time");
                                        list[i][2] = object.optString("url");
                                        list[i][3] = object.optString("size");
                                    }
                                    // noinspection ConstantConditions
                                    final String url = list[BuildConfig.FLAVOR_channel.equals("open") ? 1 : 0][2];
                                    String version = url.substring(url.lastIndexOf("v") + 1, url.lastIndexOf("" + "."));

                                    if (versionCompare(version, getAppVersion()) > 0) {
                                        if (activity.isFinishing() || activity.isDestroyed())
                                            return;

                                        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                                        builder.setIcon(R.mipmap.ic_launcher)
                                                .setTitle(activity.getString(R.string.update_title))
                                                .setMessage(activity.getString(R.string.update_message))
                                                .setCancelable(false);
                                        LayoutInflater inflater =
                                                (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                                        @SuppressLint("InflateParams")
                                        View view = inflater.inflate(R.layout.alert_dialog_progress_bar, null);
                                        builder.setView(view);
                                        mTextProgressRef = new WeakReference<>(view.findViewById(R.id.textPercent));
                                        mTextProgressRef.get().setText(String.format(activity.getString(R.string.update_progress_text), 0));
                                        mProgressBarRef = new WeakReference<>(view.findViewById(R.id.progress));
                                        mProgressBarRef.get().setMax(100);
                                        mProgressBarRef.get().setProgress(0);
                                        mAlertDialog = builder.create();
                                        mAlertDialog.show();
                                        downloadAndInstall(activity, url);
                                        return;
                                    }
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                            if (mCheckLatestVersion != null) {
                                mCheckLatestVersion.noNewVersion();
                            }
                            mIsChecking = false;
                        } catch (Exception err) {
                            err.printStackTrace();
                        }
                    });
                }

                @Override
                public void onFailure(@NotNull Call call, @NotNull IOException e) {
                    e.printStackTrace();
                }
            });
        }
    }

    @SuppressWarnings("UnusedDeclaration")
    public void removeDownloadProcess(final Context context) {
        if (mDownloadID != -1) {
            mDownloadManager.remove(mDownloadID);
            if (mbRegistered) {
                context.unregisterReceiver(onComplete);
                mbRegistered = false;
            }
            mDownloadID = -1;
        }

        mIsChecking = false;
        if (mAlertDialog != null && mAlertDialog.isShowing()) mAlertDialog.dismiss();
    }

    @SuppressWarnings("UnusedDeclaration")
    public boolean onRequestPermissionsResult(Activity activity, int requestCode, @NonNull String[] permissions,
                                              @NonNull int[] grantResults) {
        boolean handle = false;
        if (requestCode == INSTALL_PACKAGES_REQUEST_CODE) {
            handle = true;
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                installAPK(activity);
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                            Uri.parse("package:" + activity.getPackageName()));
                    activity.startActivityForResult(intent, GET_UNKNOWN_APP_SOURCES);
                } catch (ActivityNotFoundException e) {
                    Toast.makeText(activity, activity.getString(R.string.update_permission), Toast.LENGTH_LONG).show();
                    e.printStackTrace();
                }
            }
        }
        return handle;
    }

    @SuppressWarnings("UnusedDeclaration")
    public boolean onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        boolean handle = false;
        if (requestCode == GET_UNKNOWN_APP_SOURCES) {
            handle = true;
            if (resultCode == RESULT_OK) {
                OpenNewVersion(activity);
            } else if (resultCode == RESULT_CANCELED && isCastSDKAvailable(activity)) {
                // Duo to Chromecast use different UI,
                // user will use "Back" key to return previous menu.
                // However the "Back" key will sent "RESULT_CANCELED",
                // we need some workaround here to install apk.
                OpenNewVersion(activity);
            } else {
                Toast.makeText(activity, activity.getString(R.string.update_permission), Toast.LENGTH_LONG).show();
                if (mCheckLatestVersion != null) {
                    mCheckLatestVersion.noNewVersion();
                }
            }
        }
        return handle;
    }
    //-------------------------------------------------------------------------
    // endregion public Implementation
}
