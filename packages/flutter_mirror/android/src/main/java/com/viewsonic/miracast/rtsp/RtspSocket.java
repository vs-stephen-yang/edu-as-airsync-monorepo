package com.viewsonic.miracast.rtsp;

import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicBoolean;

class RtspSocket {
  private static final String TAG = "MiraRtspSocket";
  private Socket socket_;

  private String rtspHost_;
  private int rtspPort_;

  private OutputStream outputStream_;
  private InputStream inputStream_;
  private BufferedReader bufferedReader_;

  private Handler handler_;
  private AtomicBoolean isRunning_ = new AtomicBoolean(false);

  private OnReceiveRTSPListener receiveRTSPListener_;

  public RtspSocket(String host, int port) {
    rtspHost_ = host;
    rtspPort_ = port;
  }

  public int start(OnReceiveRTSPListener listener) {
    receiveRTSPListener_ = listener;

    if (TextUtils.isEmpty(rtspHost_)) {
      Log.d(TAG, "mRtspHost is null");
      return -1;
    }
    if (0 == rtspPort_) {
      Log.d(TAG, "mRtspPort is null");
      return -1;
    }
    socket_ = new Socket();
    SocketAddress socketAddress = new InetSocketAddress(rtspHost_, rtspPort_);
    try {
      socket_.connect(socketAddress, 5000);
      outputStream_ = socket_.getOutputStream();
      inputStream_ = socket_.getInputStream();
      bufferedReader_ = new BufferedReader(new InputStreamReader(inputStream_, "UTF-8"));
      socket_.setSoTimeout(1000);
    } catch (IOException e) {
      Log.e(TAG, "RTSPSocket start error:" + e.toString());
      return -1;
    }

    final Semaphore signal = new Semaphore(0);
    HandlerThread receiveThread = new HandlerThread("RTSPSocketThread") {
      protected void onLooperPrepared() {
        handler_ = new Handler();
        signal.release();
      }
    };
    isRunning_.set(true);
    receiveThread.start();
    signal.acquireUninterruptibly();

    if (!socket_.isClosed()) {
      handler_.post(receiveOperationRunnable);
    }
    return 0;
  }

  public void close() {
    Log.d(TAG, "RTSPSocket close");
    isRunning_.set(false);
    handler_.removeCallbacksAndMessages(null);
    handler_.post(new Runnable() {
      @Override
      public void run() {
        try {
          Log.d(TAG, "RTSPSocket clean resource");
          inputStream_.close();
          outputStream_.close();
          socket_.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    });
  }

  public void sendRequest(RtspRequestMessage request) {
    try {
      if (socket_ == null || !socket_.isConnected()) {
        Log.w(TAG, "Socket is not connected.");
        return;
      }
      Log.d(TAG, ">>>>>>>>>> RTSP Send Message:\r\n" +
          request.toStringMsg(false) +
          "<<<<<<<<<<");
      outputStream_.write(request.toByteArray(false));
      outputStream_.flush();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  public void sendResponse(RtspResponseMessage response) {
    try {
      Log.d(TAG, ">>>>>>>>>> RTSP Send Message:\r\n" +
          response.toStringMsg(false) +
          "<<<<<<<<<<");
      outputStream_.write(response.toByteArray(false));
      outputStream_.flush();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  public void sendRtspData(String data) {
    try {
      outputStream_.write(data.getBytes("UTF-8"));
      outputStream_.flush();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  private Runnable receiveOperationRunnable = new Runnable() {
    @Override
    public void run() {
      try {
        // Read start line
        String line = bufferedReader_.readLine();
        if (line != null && line.length() > 0) {
          String cmd[] = line.split("\\s");
          if (cmd.length == 3) {
            RtspMessage message;
            if (cmd[0].startsWith("RTSP/")) {
              // This is a response message
              RtspResponseMessage response = new RtspResponseMessage();
              response.protocolVersion = cmd[0];
              response.statusCode = Integer.parseInt(cmd[1]);
              message = response;
            } else {
              // This is a request message
              RtspRequestMessage request = new RtspRequestMessage();
              request.methodType = cmd[0];
              request.path = cmd[1];
              request.protocolVersion = cmd[2];
              message = request;
            }

            // Read headers
            int contentLength = 0;
            String header = bufferedReader_.readLine();
            while (header.length() > 0) {
              String ss[] = header.split(":\\s");
              if (ss.length == 2) {
                message.headers.put(ss[0], ss[1]);
                if (ss[0].equalsIgnoreCase("Content-Length")) {
                  contentLength = Integer.parseInt(ss[1]);
                }
              }
              header = bufferedReader_.readLine();
            }

            // Read body
            if (contentLength > 0) {
              char[] bodyCharArray = new char[contentLength];
              // read body into char[]
              bufferedReader_.read(bodyCharArray, 0, contentLength);
              // read body into hashMap
              message.bodyStr = String.valueOf(bodyCharArray);
              String[] bodyLineArray = message.bodyStr.split("\r\n");
              for (String bl : bodyLineArray) {
                String[] bodyLine = bl.split(":\\s");
                if (bodyLine.length == 2) {
                  message.bodyMap.put(bodyLine[0], bodyLine[1]);
                }
              }
            }
            Log.d(TAG, ">>>>>>>>>> RTSP Receive Message:\r\n" +
                message.toStringMsg(true) +
                "<<<<<<<<<<");
            if (receiveRTSPListener_ != null) {
              if (message instanceof RtspRequestMessage) {
                receiveRTSPListener_.onRtspRequest((RtspRequestMessage) message);
              } else {
                receiveRTSPListener_.onRtspResponse((RtspResponseMessage) message);
              }
            }
          } else {
            Log.d(TAG, "RTSP Receive Message is null.");
          }
        }
      } catch (SocketException e) {
        Log.i(TAG, "SocketException:" + e.toString());
      } catch (Exception e) {
        if(!(e instanceof SocketTimeoutException)) {
          Log.e(TAG, "Exception:" + e.toString());
        }
      }

      // Post another receive operation
      if (isRunning_.get() && !socket_.isClosed()) {
        handler_.post(receiveOperationRunnable);
      } else {
        Log.d(TAG, "RTSPSocket is closed.");
      }
    }
  };
}
