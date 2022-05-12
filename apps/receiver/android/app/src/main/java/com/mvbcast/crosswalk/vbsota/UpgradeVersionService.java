package com.mvbcast.crosswalk.vbsota;

import android.annotation.SuppressLint;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.Build;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;
import android.util.SparseArray;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tonyodev.fetch2.Download;
import com.tonyodev.fetch2.Error;
import com.tonyodev.fetch2.Fetch;
import com.tonyodev.fetch2.FetchConfiguration;
import com.tonyodev.fetch2.FetchListener;
import com.tonyodev.fetch2.NetworkType;
import com.tonyodev.fetch2.Priority;
import com.tonyodev.fetch2core.DownloadBlock;

import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class UpgradeVersionService extends Service {
    private final DownloadBinder mBinder = new DownloadBinder();

    private SparseArray<String> packagePaths;
    private SparseArray<String> md5CheckSums;

    private final OkHttpClient client = new OkHttpClient();

    public static final int FLAG_RECEIVER_INCLUDE_BACKGROUND = Intent.FLAG_ACTIVITY_PREVIOUS_IS_TOP;
    private static final String COMMAND_FLAG_SUCCESS = "success";

    private final String OTA_DIR = Environment.getExternalStorageDirectory().getAbsolutePath();

    private final File RECOVERY_DIR = new File("/cache/recovery");
    private final File UPDATE_FLAG_FILE = new File(RECOVERY_DIR, "last_flag");

    private Fetch fetch;

    private byte[] calculateMD5ofFile(String location) throws IOException, NoSuchAlgorithmException {
        FileInputStream fs = new FileInputStream(location);
        MessageDigest md = MessageDigest.getInstance("MD5");
        byte[] buffer = new byte[8192];
        int bytes;
        do {
            bytes = fs.read(buffer, 0, 8192);
            if (bytes > 0)
                md.update(buffer, 0, bytes);

        } while (bytes > 0);
        return md.digest();
    }

    public String ByteArrayToHexString(byte[] bytes) {
        StringBuilder hexString = new StringBuilder();
        for (byte aByte : bytes) {
            String hex = Integer.toHexString(aByte & 0xFF);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }

    public void SendServiceBroadCast(String type, String value) {
        Intent intent = new Intent();
        intent.setAction("com.mvbcast.download.progress");
        intent.putExtra("type", type);
        intent.putExtra("value", value);
        sendBroadcast(intent);
    }

    private final FetchListener fetchListener = new FetchListener() {
        @Override
        public void onCompleted(@NonNull Download download) {
            Log.d("onDownload", "onCompleted:" + download.getId() + ",file:" + download.getFile());
            String packagePath = packagePaths.get(download.getId());
            String md5CheckSum = md5CheckSums.get(download.getId());
            SystemUtils.setPermission(packagePath);
            byte[] md5sum = new byte[0];
            try {
                md5sum = calculateMD5ofFile(packagePath);
            } catch (Exception e) {
                e.printStackTrace();
            }
            String md5 = ByteArrayToHexString(md5sum);
            boolean isMD5ok = md5.equals(md5CheckSum);
            Log.d("MD5", md5CheckSum + "," + md5 + "," + isMD5ok);
            if (isMD5ok) {
                Intent intent_update = new Intent();
                intent_update.setAction("android.aaeon.fota.update");
                intent_update.addFlags(FLAG_RECEIVER_INCLUDE_BACKGROUND);
                sendBroadcast(intent_update);
            } else {
                File file = new File(OTA_DIR, "ota.zip");
                fetch.deleteAll();
                if (file.exists()) {
                    //noinspection ResultOfMethodCallIgnored
                    file.delete();
                }
                SendRequest(false);
                //noinspection ConstantConditions
                SendServiceBroadCast("MD5", "isMD5ok:" + isMD5ok);
            }
        }

        @Override
        public void onStarted(Download download, @NonNull List<? extends DownloadBlock> list, int i) {
            Log.d("onStarted", "onStarted:" + download.getId());
        }

        @Override
        public void onDownloadBlockUpdated(@NonNull Download download, @NonNull DownloadBlock downloadBlock, int i) {
            //  Log.d("onDownloadBlockUpdated", "onDownloadBlockUpdated:" + download.getId());
        }

        @Override
        public void onError(@NonNull Download download, @NonNull Error error, @Nullable Throwable throwable) {
            // Log.d("onError", "onError:" + download.getId());
        }

        @Override
        public void onWaitingNetwork(Download download) {
            Log.d("onDownload", "onWaitingNetwork:" + download.getId());
        }

        @Override
        public void onAdded(Download download) {
            Log.d("onDownload", "onAdded:" + download.getId());
        }

        @Override
        public void onQueued(@NonNull Download download, boolean waitingOnNetwork) {
            Log.d("onDownload", "onQueued:" + download.getId());
        }

        @Override
        public void onProgress(@NonNull Download download, long etaInMilliSeconds, long downloadedBytesPerSecond) {
            int progress = download.getProgress();
            Log.d("onDownload", "progress:" + download.getId() + ":" + progress + "%" + " ETA:" + etaInMilliSeconds);
            SendServiceBroadCast("onDownloadProgress",
                    "{\"progress\":" + progress + ",\"eta\":" + etaInMilliSeconds + "}");
        }

        @Override
        public void onPaused(@NonNull Download download) {
            Log.d("onDownload", "onPaused:" + download.getId());
        }

        @Override
        public void onResumed(@NonNull Download download) {
            Log.d("onDownload", "onResumed:" + download.getId());
        }

        @Override
        public void onCancelled(@NonNull Download download) {
            Log.d("onDownload", "onCancelled:" + download.getId());
        }

        @Override
        public void onRemoved(@NonNull Download download) {
            Log.d("onDownload", "onRemoved:" + download.getId());
        }

        @Override
        public void onDeleted(@NonNull Download download) {
            Log.d("onDownload", "onDeleted:" + download.getId());
        }
    };

    //private

    public String getRecoveryCommand() {
        String TAG = "getRecoveryCommand";
        if (UPDATE_FLAG_FILE.exists()) {
            Log.d(TAG, "UPDATE_FLAG_FILE is exists");
            char[] buf = new char[128];
            int readCount = 0;
            try {
                FileReader reader = new FileReader(UPDATE_FLAG_FILE);
                readCount = reader.read(buf, 0, buf.length);
                Log.d(TAG, "readCount = " + readCount + " buf.length = " + buf.length);
            } catch (IOException e) {
                Log.e(TAG, "can not read /cache/recovery/last_flag!");
            } finally {
                //noinspection ResultOfMethodCallIgnored
                UPDATE_FLAG_FILE.delete();
            }
            StringBuilder sBuilder = new StringBuilder();
            for (int i = 0; i < readCount; i++) {
                if (buf[i] == 0) {
                    break;
                }
                sBuilder.append(buf[i]);
            }
            return sBuilder.toString();
        }
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("info", "start service");

        packagePaths = new SparseArray<>();
        md5CheckSums = new SparseArray<>();

        FetchConfiguration fetchConfiguration = new FetchConfiguration.Builder(this)
                .setDownloadConcurrentLimit(1)
                .build();

        fetch = Fetch.Impl.getInstance(fetchConfiguration);
        fetch.addListener(fetchListener);

        //clearDownloads();
    }


    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    public class DownloadBinder extends Binder {
        public void startDownload() {
            //判斷OTA結果
            String command = getRecoveryCommand();
            String TAG = "getRecoveryCommand";

            File file = new File(OTA_DIR, "ota.zip");
            if (file.exists()) {
                Log.d("OTA_FILE EXSI", file.getAbsolutePath());
                //   boolean deleted = file.delete();
            }

            if (command == null) {
                //沒有進行OTA
                Log.d(TAG, "last_flag: null");
                SendRequest(false);
                SendServiceBroadCast("last_flag", "null");
            } else if (command.contains("$path")) {
                String path = command.substring(command.indexOf('=') + 1);
                Log.d(TAG, "last_flag: path = " + path);
                if (command.startsWith(COMMAND_FLAG_SUCCESS)) {
                    //OTA 成功
                    Log.d(TAG, "last_flag: COMMAND_FLAG_SUCCESS");
                    if (file.exists()) {
                        //noinspection ResultOfMethodCallIgnored
                        file.delete();
                    }
                    SendRequest(false);
                    SendServiceBroadCast("last_flag", "COMMAND_FLAG_SUCCESS");
                } else {
                    //OTA 失敗
                    Log.d(TAG, "last_flag: UPDATE_FAILED");
                    if (file.exists()) {
                        //noinspection ResultOfMethodCallIgnored
                        file.delete();
                    }
                    SendRequest(true);
                    SendServiceBroadCast("last_flag", "UPDATE_FAILED");
                }
            }

        }
    }

    @SuppressLint("HardwareIds")
    private void SendRequest(boolean forceUpdate) {
//        String buildVersion = "AD81D.RK3399.VBS100.53"; //debug
        String buildVersion = Build.VERSION.INCREMENTAL;
        Log.d("buildVersion", buildVersion);
        String androidId = Build.SERIAL;
        Log.d("androidId", androidId);
        String url = getResourceFromContext(this, "vbs_ota_url");
        String requestUrl = url + "?version=" + buildVersion + "&code=" + androidId;
        if (forceUpdate) {
            requestUrl = url + "?ignoreVersion=true" + "&code=" + androidId;
        }
        Log.d("requestUrl", requestUrl);
        Request request = new Request.Builder()
                .url(requestUrl)
                .get()
                .build();
        Call call = client.newCall(request);
        call.enqueue(new Callback() {
            @Override
            public void onResponse(@NonNull Call call, @NonNull Response response) {
                Log.d("call", "forceUpdate:" + forceUpdate);
                if (response.body() == null) return;
                try {
                    JSONObject json = new JSONObject(Objects.requireNonNull(response.body()).string());
                    String status = json.get("status").toString();
                    Log.d("thisBuild", status);
                    SendServiceBroadCast("isUpdate", status);

                    if (status.equals("uptodate")) {
                        return;
                    }

                    // String version = json.get("version").toString();
                    String md5CheckSum = json.get("md5").toString();
                    String fileUrl = json.get("fileUrl").toString();
                    //String OTA_DIR = Environment.getExternalStorageDirectory().getAbsolutePath();
                    Log.d("downloadFileUrl", fileUrl);
                    Log.d("savePath", OTA_DIR);
                    File file = new File(OTA_DIR, "ota.zip");

                    final com.tonyodev.fetch2.Request request = new com.tonyodev.fetch2.Request(fileUrl,
                            file.getAbsolutePath());
                    request.setPriority(Priority.HIGH);
                    request.setNetworkType(NetworkType.ALL);
                    request.getId();
                    request.getFile();
                    packagePaths.put(request.getId(), file.getAbsolutePath());
                    md5CheckSums.put(request.getId(), md5CheckSum);
                    if (file.exists()) {
                        try {
                            byte[] md5sum = calculateMD5ofFile(file.getAbsolutePath());
                            String md5 = ByteArrayToHexString(md5sum);
                            boolean isMD5ok = md5.equals(md5CheckSum);
                            Log.d("MD5", md5CheckSum + "," + md5 + "," + isMD5ok);
                            if (isMD5ok) {
                                Intent intent_update = new Intent();
                                intent_update.setAction("android.aaeon.fota.update");
                                intent_update.addFlags(FLAG_RECEIVER_INCLUDE_BACKGROUND);
                                sendBroadcast(intent_update);
                            } else {
                                fetch.enqueue(request, updatedRequest -> {
                                    //Request was successfully enqueued for download.
                                }, error -> {
                                    //An error occurred enqueuing the request.
                                });

                            }
                        } catch (Exception err) {
                            err.printStackTrace();
                        }
                    } else {
                        fetch.enqueue(request, updatedRequest -> {
                            //Request was successfully enqueued for download.
                        }, error -> {
                            //An error occurred enqueuing the request.
                        });
                    }
                } catch (Exception err) {
                    SendRequest(forceUpdate);
                    err.printStackTrace();
                }
            }

            @Override
            public void onFailure(@NonNull Call call, @NonNull IOException e) {
                Log.d("callError", "forceUpdate:" + forceUpdate);

                Observable.timer(5, TimeUnit.SECONDS).subscribe(new Observer<Long>() {
                    @Override
                    public void onError(@NonNull Throwable e) {

                    }

                    @Override
                    public void onComplete() {
                        SendRequest(forceUpdate);
                    }

                    @Override
                    public void onSubscribe(@NonNull Disposable d) {

                    }

                    @Override
                    public void onNext(@NonNull Long aLong) {

                    }
                });

                e.printStackTrace();
            }
        });
    }

    @Override
    public void onDestroy() {
        //unregisterReceiver(mReceiver);
        try {
            fetch.removeListener(fetchListener);
        } catch (Exception error) {
            error.printStackTrace();
        }
        super.onDestroy();
    }

    private static String getResourceFromContext(@NonNull Context context, @SuppressWarnings("SameParameterValue") String resName) {
        final int stringRes = context.getResources().getIdentifier(resName, "string", context.getPackageName());
        if (stringRes == 0) {
            throw new IllegalArgumentException(String.format("The 'R.string.%s' value it's not defined in your project's resources file.", resName));
        }
        return context.getString(stringRes);
    }
}
