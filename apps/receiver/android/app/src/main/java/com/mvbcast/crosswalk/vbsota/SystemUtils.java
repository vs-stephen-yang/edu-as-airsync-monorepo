package com.mvbcast.crosswalk.vbsota;

import android.util.Log;

import java.io.DataOutputStream;
import java.io.IOException;

public class SystemUtils {

    @SuppressWarnings("UnusedDeclaration")
    public static int RootCommand(String command) {
        Process process = null;
        DataOutputStream os = null;
        try {
            process = Runtime.getRuntime().exec("su");
            os = new DataOutputStream(process.getOutputStream());
            os.writeBytes(command + "\n");
            os.writeBytes("exit\n");
            os.flush();
            int i = process.waitFor();

            Log.d("SystemManager", "i:" + i);
            return i;
        } catch (Exception e) {
            Log.d("SystemManager", e.getMessage() != null ? e.getMessage() : "message is null");
            return -1;
        } finally {
            try {
                if (os != null) {
                    os.close();
                }
                if (process != null) {
                    process.destroy();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void setPermission(String filePath) {
        String command = "chmod " + "777" + " " + filePath;
        Runtime runtime = Runtime.getRuntime();
        try {
            runtime.exec(command);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
