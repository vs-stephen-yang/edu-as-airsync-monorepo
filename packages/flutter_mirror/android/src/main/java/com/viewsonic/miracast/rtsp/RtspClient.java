package com.viewsonic.miracast.rtsp;

import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;

import com.viewsonic.miracast.rtp.OnReceiveRTPListener;
import com.viewsonic.miracast.rtp.RTPServer;
import com.viewsonic.miracast.uibc.UibcClient;

import android.util.Log;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;

public class RtspClient {
  private final static String TAG = "MiraRtspClient";

  private final static String METHOD_UDP = "udp";
  private final static String METHOD_TCP = "tcp";

  private final static int STATE_STARTED = 0x00;
  private final static int STATE_STARTING = 0x01;
  private final static int STATE_STOPPING = 0x02;
  private final static int STATE_STOPPED = 0x03;
  private final static int STATE_PLAYING = 0x04;
  private final static int STATE_PAUSE = 0x05;

  private final static String METHOD_OPTIONS = "OPTIONS";
  private final static String METHOD_GET_PARAMETER = "GET_PARAMETER";
  private final static String METHOD_SET_PARAMETER = "SET_PARAMETER";
  private final static String METHOD_PLAY = "PLAY";
  private final static String METHOD_PAUSE = "PAUSE";
  private final static String METHOD_TEARDOWN = "TEARDOWN";
  private final static String METHOD_SETUP = "SETUP";

  private final static String KEY_RTSP_VERSION = "RTSP/1.0";
  private final static String KEY_DATE = "Date";
  private final static String KEY_REQUIRE = "Require";
  private final static String KEY_SESSION = "Session";
  private final static String KEY_CSEQ = "CSeq";
  private final static String KEY_TRANSPORT = "Transport";
  private final static String KEY_PUBLIC = "Public";
  private final static String KEY_WFD_TRIGGER_METHOD = "wfd_trigger_method";
  private final static String KEY_WFD_AUDIO_CODECS = "wfd_audio_codecs";
  private final static String KEY_WFD_VIDEO_FORMATS = "wfd_video_formats";
  private final static String KEY_WFD_UIBC_CAP = "wfd_uibc_capability";
  private final static String KEY_WFD_UIBC_SETTING = "wfd_uibc_setting";

  private final static int MAX_CONN_TIME = 10;
  private final static long RETRY_CONN_INTERVAL = 1000; //ms
  private final static int MIN_REQUEST_IDR_INTERVAL = 1000; //ms

  HandlerThread rtspClientThread_;
  private Handler handler_;

  private int curConnTime_ = 0;
  private RtspSocket rtspSocket_;
  private int rtpPort_;

  private RtspParameters rtspParams_;

  private int curState_;

  private RTPServer rtpServer_;
  private UibcClient uibcClient_;

  private String audioCodecs_ = "";
  private WfdAudioCodec audioCodec_;
  private String videoFormats_ = "";
  private int uibcPort_ = 0;
  private boolean isUibcEnable_ = false;

  private OnReceiveRTPListener rtpListener_;
  private AudioFormatListener audioFormatListener_;
  private boolean activate_ = true;
  private long lastRequestIdrTime_ = 0;
  private String receiverName_ = "";

  public RtspClient(String method, String address) {
    String url = address.substring(address.indexOf("//") + 2);
    url = url.substring(0, url.indexOf("/"));
    String[] tmp = url.split(":");
    if (tmp.length == 1) {
      initClientConfig(method, tmp[0], address, 7236);
    } else if (tmp.length == 2) {
      initClientConfig(method, tmp[0], address, Integer.parseInt(tmp[1]));
    }
    initialHandler();
  }

  public RtspClient(String address, int port) {
    String host = address.substring(address.indexOf("//") + 2);
    host = host.substring(0, host.indexOf("/"));
    initClientConfig("udp", host, address, port);
    initialHandler();
  }

  public RtspClient(String method, String address, int port) {
    String host = address.substring(address.indexOf("//") + 2);
    host = host.substring(0, host.indexOf("/"));
    initClientConfig(method, host, address, port);
    initialHandler();
  }

  public void setRtpListener(OnReceiveRTPListener listener) {
    rtpListener_ = listener;
  }

  public void setReceiverName(String name) {
    receiverName_ = name;
  }

  public void setAudioFormatListener(AudioFormatListener listener) {
    audioFormatListener_ = listener;
  }

  public void start() {
    if (!isStopped())
      return;
    handler_.post(startConnectRunnable);
  }

  public void pause() {
    if (isPlaying()) {
      sendRequestPause();
    }
  }

  public void play() {
    if (isPause()) {
      sendRequestPlay();
    }
  }

  public void setActivate(boolean activate) {
    activate_ = activate;
  }

  public void stop() {
    handler_.post(stopConnectRunnable);
    try {
      rtspClientThread_.quitSafely();
      rtspClientThread_.join();
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }

  public void requestIdr() {
    long now = System.currentTimeMillis();
    long elapsed = now - lastRequestIdrTime_;

    if (elapsed > MIN_REQUEST_IDR_INTERVAL) {
      lastRequestIdrTime_ = now;
      rtspSocket_.postRequestIdr();
    }
  }

  public void requestTeardown() {
    rtspSocket_.postRequestTeardown();
  }

  public boolean isStarted() {
    return curState_ == STATE_STARTED;
  }

  public boolean isStarting() {
    return curState_ == STATE_STARTING;
  }

  public boolean isStopped() {
    return curState_ == STATE_STOPPED;
  }

  public boolean isStopping() {
    return curState_ == STATE_STOPPING;
  }

  public boolean isPause() {
    return curState_ == STATE_PAUSE;
  }

  public boolean isPlaying() {
    return curState_ == STATE_PLAYING;
  }

  public void onTouchEvent(int touchId, boolean touchDown, double x, double y) {
    if (uibcClient_ != null) {
      uibcClient_.onTouchEvent(touchId, touchDown, x, y);
    }
  }

  public interface AudioFormatListener {
    void onAudioFormatUpdate(String name, int sampleRate, int channelCount);
  }

  /**
   * @param host    host
   * @param address host+path
   * @param port    port
   */
  private void initClientConfig(String method, String host, String address, int port) {

    curState_ = STATE_STOPPED;

    rtspParams_ = new RtspParameters();
    rtspParams_.cSeq = 0;
    if (method.equalsIgnoreCase(METHOD_UDP)) {
      rtspParams_.isTCPTranslate = false;
    } else if (method.equalsIgnoreCase(METHOD_TCP)) {
      rtspParams_.isTCPTranslate = true;
    }
    rtspParams_.host = host;
    rtspParams_.port = port;
    rtspParams_.session = "";
    rtspParams_.address = address.substring(7);

    audioCodec_ = new WfdAudioCodec();
  }

  private void initialHandler() {
    rtspClientThread_ = new HandlerThread("rtspClientThread");
    rtspClientThread_.start();
    handler_ = new Handler(rtspClientThread_.getLooper());
  }

  private Runnable startConnectRunnable = new Runnable() {
    @Override
    public void run() {
      tryConnect();
    }
  };

  private Runnable stopConnectRunnable = new Runnable() {
    @Override
    public void run() {
      Log.d(TAG, "stop RTSP.");
      cleanResource();
    }
  };

  private void tryConnect() {
    try {
      if (curConnTime_ >= MAX_CONN_TIME) {
        Log.d(TAG, "try connect to the RTSP Socket " + MAX_CONN_TIME + " time failed.");
        return;
      }

      Log.d(TAG, "start try to connect the RTSP Socket,"
          + "socket host:" + rtspParams_.host + ", port:" + rtspParams_.port);

      curConnTime_++;

      curState_ = STATE_STARTING;

      rtspSocket_ = new RtspSocket(rtspParams_.host, rtspParams_.port);
      int ret = rtspSocket_.start(initialOnReceiveRTSPListener());
      if (ret == 0) {
        curState_ = STATE_STARTED;
      } else {
        curState_ = STATE_STOPPED;
        handler_.postDelayed(startConnectRunnable, RETRY_CONN_INTERVAL);
      }
    } catch (Exception e) {
      curState_ = STATE_STOPPED;
      Log.e(TAG, "tryConnect Exception:" + e.toString());
    }
  }

  private OnReceiveRTPListener initialOnReceiveRTPListener() {
    return new OnReceiveRTPListener() {
      @Override
      public void onRtpData(long seqNum, byte[] data, int size) {
        if (activate_ == false)
          return;
        if (rtpListener_ != null) {
          rtpListener_.onRtpData(seqNum, data, size);
        }
      }
    };
  }

  private OnReceiveRTSPListener initialOnReceiveRTSPListener() {
    return new OnReceiveRTSPListener() {
      @Override
      public void onRtspResponse(RtspResponseMessage rParams) {
        if (activate_ == false)
          return;

        if (rParams.statusCode == 200) { // 200 ok
          if (!TextUtils.isEmpty(rParams.headers.get(KEY_SESSION))
              && !TextUtils.isEmpty(rParams.headers.get(KEY_TRANSPORT))) {// source -> sink M6 response
            rtspParams_.session = rParams.headers.get(KEY_SESSION);
            sendRequestPlay();
            return;
          }
          // source -> sink M2/M7 response or TEARDOWN/PAUSE/PLAY OK response
        } else {
          Log.e(TAG,
              "onRtspResponse failed, reason:" + RtspResponseMessage.RTSP_STATUS.get(rParams.statusCode));
        }
      }

      @Override
      public void onRtspRequest(RtspRequestMessage rParams) {
        if (activate_ == false)
          return;

        try {
          if (TextUtils.isEmpty(rParams.headers.get(KEY_CSEQ))) {
            Log.e(TAG, "Cseq is null.");
            return;
          }
          // CSeq adjustment
          rtspParams_.cSeq = Integer.parseInt(rParams.headers.get(KEY_CSEQ));
          if (!TextUtils.isEmpty(rParams.methodType)) {
            switch (rParams.methodType) {
              case METHOD_OPTIONS: {
                startRTPReceiver();
                sendResponseM1();
                sendRequestM2();
                break;
              }
              case METHOD_GET_PARAMETER: {
                if (TextUtils.isEmpty(rParams.bodyStr)) {
                  sendResponseOK();
                } else {
                  sendResponseM3();
                }
                break;
              }
              case METHOD_SET_PARAMETER: {
                if (TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_TRIGGER_METHOD))) { // source->sink M4
                                                                                      // request
                  WfdAudioCodec audioCodecInfo = new WfdAudioCodec();
                  if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_AUDIO_CODECS))) {
                    audioCodecs_ = rParams.bodyMap.get(KEY_WFD_AUDIO_CODECS);
                    parseAudioCodecs(audioCodecs_, audioCodecInfo);
                    if (audioFormatListener_ != null) {
                      audioFormatListener_.onAudioFormatUpdate(audioCodecInfo.name,
                          audioCodecInfo.sampleRate,
                          audioCodecInfo.channelCount);
                    }
                  }
                  if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_VIDEO_FORMATS))) {
                    videoFormats_ = rParams.bodyMap.get(KEY_WFD_VIDEO_FORMATS);
                  }
                  if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_UIBC_CAP))) {
                    // uibcap e.g.
                    // "input_category_list=HIDC;generic_cap_list=none;hidc_cap_list=Keyboard/USB,
                    // Mouse/USB, MultiTouch/USB, Gesture/USB, RemoteControl/USB,
                    // Joystick/USB;port=50000\r\n"
                    String uibcCap = rParams.bodyMap.get(KEY_WFD_UIBC_CAP);
                    // Parse port from uibcCap
                    String[] uibcCapArray = uibcCap.split(";");
                    for (String uibcCapItem : uibcCapArray) {
                      if (uibcCapItem.contains("port=")) {
                        String[] uibcCapItemArray = uibcCapItem.split("=");
                        if (uibcCapItemArray.length == 2) {
                          uibcPort_ = Integer.parseInt(uibcCapItemArray[1]);
                          break;
                        }
                      }
                    }
                    Log.d(TAG, "UIBC port: " + uibcPort_);
                  }

                  if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_UIBC_SETTING))) {
                    // uibSetting e.g. "enable\r\n"
                    String uibcSetting = rParams.bodyMap.get(KEY_WFD_UIBC_SETTING);
                    boolean uibcEnable = false;
                    if (uibcSetting.contains("enable")) {
                      if (uibcPort_ != 0) {
                        uibcEnable = true;
                      }
                    } else {
                      uibcEnable = false;
                    }

                    if (uibcEnable != isUibcEnable_) {
                      isUibcEnable_ = uibcEnable;
                      if (isUibcEnable_) {
                        startUibc();
                      } else {
                        stopUibc();
                      }
                    }
                  }

                  Log.d(TAG, "Get audioCodecs: " + audioCodecs_ + ", videoFormats: " + videoFormats_);
                  sendResponseOK();
                } else {
                  if (rParams.bodyMap.get(KEY_WFD_TRIGGER_METHOD).equals(METHOD_SETUP)) { // source->sink
                                                                                          // M5
                                                                                          // request
                    sendResponseOK();
                    sendRequestM6();
                  }
                  if (rParams.bodyMap.get(KEY_WFD_TRIGGER_METHOD).equals(METHOD_TEARDOWN)) { // source->sink
                                                                                             // TearDown
                                                                                             // request
                    sendResponseTeardown();
                    cleanResource();
                  }
                }
                break;
              }
            }
          } else {
            Log.d(TAG, "methodType is null.");
          }
        } catch (Exception e) {
          Log.e(TAG, "Exception:" + e.toString());
        }
      }

      @Override
      public void onRequestIDR() {
        sendRequestIdr();
      }

      @Override
      public void onRequestTeardown() {
        sendRequestTeardown();
      }
    };
  }

  private void cleanResource() {
    try {
      curState_ = STATE_STOPPED;

      handler_.removeCallbacksAndMessages(null);

      if (rtpServer_ != null) {
        Log.d(TAG, "stop RTP&RTCP socket.");
        rtpServer_.stop();
        rtpServer_ = null;
      }

      rtpListener_ = null;

      stopUibc();

      if (rtspSocket_ != null) {
        Log.d(TAG, "stop RTSP socket.");
        rtspSocket_.close();
      }
    } catch (Exception e) {
      Log.d(TAG, "RTSP stop() Exception: " + e.toString());
    }
  }

  private void sendResponseM1() {
    RtspResponseMessage rm = new RtspResponseMessage();
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.statusCode = 200;
    rm.headers = addCommonHeader();
    String date = "yyyy HH:mm:ss z";
    SimpleDateFormat sdf = new SimpleDateFormat(date);
    rm.headers.put(KEY_DATE, sdf.format(new Date()));
    rm.headers.put(KEY_PUBLIC, "org.wfa.wfd1.0, GET_PARAMETER, SET_PARAMETER");
    rtspSocket_.sendResponse(rm);
  }

  private void sendRequestM2() {
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_OPTIONS;
    rm.path = "*";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_REQUIRE, "org.wfa.wfd1.0");
    rtspSocket_.sendRequest(rm);
  }

  private void sendResponseM3() {
    RtspResponseMessage rm = new RtspResponseMessage();
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.statusCode = 200;
    rm.headers = addCommonHeader();
    rm.bodyStr = "wfd_client_rtp_ports: RTP/AVP/" + (rtspParams_.isTCPTranslate ? "TCP" : "UDP") + ";unicast "
        + rtpPort_ + " 0 mode=play\r\n" +
        "wfd_audio_codecs: " + getWfdAudioCodecs() + "\r\n" +
        // "wfd2_video_formats: 30 01 01 0008 0000000194A0 000005155555 000000000555 00
        // 0000 0000 11, 01 04 0008 0000000194A0 000005155555 000000000555 00 0000 0000
        // 11 00\r\n" +
        "wfd_video_formats: " + getWfdVideoFormats() + "\r\n" +
        "wfd_uibc_capability: input_category_list=HIDC;hidc_cap_list=Keyboard/USB, Mouse/USB, MultiTouch/USB, Gesture/USB, RemoteControl/USB;port=none\r\n"
        +
        "wfd_content_protection: none\r\n" +
        "wfd_idr_request_capability: 1\r\n" +
        "wfd_display_edid: 0001 00ffffffffffff004dd90100010000003017010380301b782e2795a55550a2270b5054210800818081c08100a9c0b300d1c001010101023a801871382d40582c4500dd0c1100001e000000ff0031323334353637380a20202020000000fd00324c1e5311000a202020202020000000fc004169725365727665722055484400b8\r\n"
        +
        "intel_friendly_name: " + receiverName_ + "\r\n" +
        "intel_sink_manufacturer_name: Viewsonic\r\n" +
        "intel_sink_model_name: Display\r\n" +
        "intel_sink_device_URL: none\r\n" +
        "microsoft_latency_management_capability: supported\r\n" +
        "microsoft_format_change_capability: supported\r\n" +
        "microsoft_diagnostics_capability: supported\r\n" +
        "microsoft_multiscreen_projection: supported\r\n" +
        "microsoft_audio_mute: supported\r\n" +
        "microsoft_rtcp_capability: supported\r\n" +
        "microsoft_max_bitrate: 15000000\r\n" +
        "wfd_connector_type: 05\r\n";
    rtspSocket_.sendResponse(rm);
  }

  /**
   * sink->source M4/M5/KeepAlive response
   */
  private void sendResponseOK() {
    RtspResponseMessage rm = new RtspResponseMessage();
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.statusCode = 200;
    rm.headers = addCommonHeader();
    rtspSocket_.sendResponse(rm);
  }

  private void sendResponseTeardown() {
    curState_ = STATE_STOPPING;
    RtspResponseMessage rm = new RtspResponseMessage();
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.statusCode = 200;
    rm.headers = addCommonHeader();
    rtspSocket_.sendResponse(rm);
  }

  private void sendRequestM6() {
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_SETUP;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_TRANSPORT,
        "RTP/AVP/" + (rtspParams_.isTCPTranslate ? "TCP;" : "UDP;") + "unicast;client_port=" + rtpPort_);
    rtspSocket_.sendRequest(rm);
  }

  private void sendRequestPlay() {
    curState_ = STATE_PLAYING;

    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_PLAY;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_SESSION, rtspParams_.session);
    rtspSocket_.sendRequest(rm);
  }

  private void sendRequestTeardown() {
    Log.d(TAG, "sendRequestTeardown");
    curState_ = STATE_STOPPING;
    // String request = "TEARDOWN rtsp://" + mRtspParams.host + "/wfd1.0/streamid=0
    // RTSP/1.0\r\n" + addCommonHeader();
    // mRtspSocket.sendRtspData(request);
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_SET_PARAMETER;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_SESSION, rtspParams_.session);
    rm.bodyStr = "wfd_trigger_method: TEARDOWN";
    rtspSocket_.sendRequest(rm);
  }

  private void sendRequestIdr() {
    Log.d(TAG, "sendRequestIdr");
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_SET_PARAMETER;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_SESSION, rtspParams_.session);
    rm.bodyStr = "wfd_idr_request";
    rtspSocket_.sendRequest(rm);
  }

  private void sendRequestPause() {
    curState_ = STATE_PAUSE;
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_PAUSE;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rtspSocket_.sendRequest(rm);
  }

  private HashMap<String, String> addCommonHeader() {
    HashMap<String, String> headers = new HashMap<>();
    headers.put(KEY_CSEQ, String.valueOf(rtspParams_.cSeq++));
    return headers;
  }

  private String getWfdAudioCodecs() {
    return "AAC 00000001 00";
  }

  private class WfdAudioCodec {
    public String name = "AAC";
    public int sampleRate = 48000;
    public int channelCount = 2;
    public int bitsPerSample = 16;
  }

  private void parseAudioCodecs(String audioCodecs, WfdAudioCodec wfdAudioCodec) {
    // e.g. "AAC 00000001 00\\r\\n"
    String[] audioCodecArray = audioCodecs.split(" ");
    wfdAudioCodec.name = audioCodecArray[0];
    if (wfdAudioCodec.name.equals("AAC")) {
      wfdAudioCodec.sampleRate = 48000;
      wfdAudioCodec.bitsPerSample = 16;
      // bit 0:2channels, bit 1:4channels, bit 2:6channels, bit 3:8channels
      int channelIdx = Integer.parseInt(audioCodecArray[1], 16);
      switch (channelIdx) {
        case 1:
          wfdAudioCodec.channelCount = 2;
          break;
        case 2:
          wfdAudioCodec.channelCount = 4;
          break;
        case 4:
          wfdAudioCodec.channelCount = 6;
          break;
        case 8:
          wfdAudioCodec.channelCount = 8;
          break;
        default:
          wfdAudioCodec.channelCount = 2;
          break;
      }
    } else if (wfdAudioCodec.name.equals("LPCM")) {
      wfdAudioCodec.bitsPerSample = 16;
      wfdAudioCodec.channelCount = 2;
      int samplingRateIdx = Integer.parseInt(audioCodecArray[1], 16);
      switch (samplingRateIdx) {
        case 1:
          wfdAudioCodec.sampleRate = 44100;
          break;
        case 2:
          wfdAudioCodec.sampleRate = 48000;
          break;
        default:
          wfdAudioCodec.sampleRate = 48000;
          break;
      }
    }
  }

  private String getWfdVideoFormats() {

    // native: CEA index 8, 1080p p60 -> 0100 0000 -> 0x40
    // preferred-display-mode-supported: 0x00
    // profile: bit 0: CBP, bit 1: 0x01=CBP 0x02=CHP
    // level: 0x10: 4.2
    // CEA-Support: Index: 5(1280x720 p30), 7(1920x1080 p30), 10(1280x720 p25),
    // 12(1920x1080 p25), 15(1280x720 p24), 16(1920x1080 p24)
    // 0x000194A0
    // VESA-Support: 0x05555555
    // HH-Support: 0x00000555
    // Latency: 0x00
    // min-slice-size: 0x0000
    // slice-enc-params: 0x0000
    // frame-rate-control-support: 0x11
    // max-hres: none
    // max-vres: none

    return "40 00 01 10 000194A0 05155555 00000555 00 0000 0000 11 none none, 02 10 000194A0 05155555 00000555 00 0000 0000 11 none none";
  }

  private void startRTPReceiver() {
    rtpServer_ = new RTPServer(initialOnReceiveRTPListener());
    rtpServer_.start();
    rtpPort_ = rtpServer_.getRtpPort();
    Log.d(TAG, "Start to connect the RTP Server. RTP Port is: " + rtpPort_);
  }

  private void startUibc() {
    uibcClient_ = new UibcClient(rtspParams_.host, uibcPort_);
    uibcClient_.start();
  }

  private void stopUibc() {
    if (uibcClient_ != null) {
      Log.d(TAG, "stop UIBC connection.");
      uibcClient_.stop();
      uibcClient_ = null;
    }
  }

  private class RtspParameters {
    int cSeq = 0;
    Boolean isTCPTranslate = false;
    String host = "";
    String address = "";
    int port = 7236;
    String session = "";
  }

}
