package com.viewsonic.miracast.uibc;

import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;
import java.util.concurrent.Semaphore;

class UibcSocket {
  private static final String TAG = "UibcSocket";
  private Socket socket_;

  private String host_;
  private int port_;

  private OutputStream outputStream_;
  private InputStream inputStream_;
  private BufferedReader bufferedReader_;
  private byte[] data_;

  public UibcSocket(String host, int port) {
    host_ = host;
    port_ = port;
  }

  public int start() {

    if (TextUtils.isEmpty(host_)) {
      Log.d(TAG, "Host is null");
      return -1;
    }
    if (0 == port_) {
      Log.d(TAG, "Port is null");
      return -1;
    }
    socket_ = new Socket();
    SocketAddress socketAddress = new InetSocketAddress(host_, port_);
    try {
      socket_.connect(socketAddress, 5000);
      outputStream_ = socket_.getOutputStream();
      inputStream_ = socket_.getInputStream();
      bufferedReader_ = new BufferedReader(new InputStreamReader(inputStream_, "UTF-8"));
    } catch (IOException e) {
      Log.e(TAG, "UIBC socket start error:" + e.toString());
      return -1;
    }

    return 0;
  }

  public void close() {
    try {
      inputStream_.close();
      outputStream_.close();
      socket_.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  public void sendUibcData(byte[] data) {
    try {
      outputStream_.write(data);
      outputStream_.flush();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
}
