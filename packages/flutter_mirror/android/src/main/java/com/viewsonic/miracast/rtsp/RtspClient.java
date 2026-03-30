package com.viewsonic.miracast.rtsp;

import android.text.TextUtils;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.rtp.OnPlayerListener;
import com.viewsonic.miracast.rtp.RtpMpegTsPlayer;

import android.util.Log;
import android.view.Surface;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;

public class RtspClient
    implements OnReceiveRTSPListener, OnPlayerListener {
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
  private final static String KEY_SERVER = "Server";
  private final static String KEY_WFD_TRIGGER_METHOD = "wfd_trigger_method";
  private final static String KEY_WFD_AUDIO_CODECS = "wfd_audio_codecs";
  private final static String KEY_WFD_VIDEO_FORMATS = "wfd_video_formats";
  private final static String KEY_WFD_UIBC_CAP = "wfd_uibc_capability";
  private final static String KEY_WFD_UIBC_SETTING = "wfd_uibc_setting";

  private final static String WINDOWS_SOURCE_PRODUCT_ID = "MSMiracastSource";

  private int rtpPort_;

  private RtspParameters rtspParams_;

  private int curState_;

  private String audioCodecs_ = "";
  private WfdAudioCodec audioCodec_;
  private String videoFormats_ = "";
  private int uibcPort_ = 0;
  private boolean isUibcEnable_ = false;

  private AudioFormatListener audioFormatListener_;
  private SourceCapabilityListener sourceCapabilityListener_;

  private VideoResolutionListener videoResolutionListener_;

  private PacketLostListener packetLostListener_;

  private boolean activate_ = true;
  private String receiverName_ = "";

  private RtspHandler rtspHandler_;
  private RtspSender sender_;

  private String sourceProductId_ = "";
  private boolean isWindowsSource_ = false;
  private RtpMpegTsPlayer rtpPlayer_;

  private Surface surface_;

  private final EventBase eventBase_;

  public RtspClient(EventBase eventBase, String method, String address) {
    eventBase_ = eventBase;
    String url = address.substring(address.indexOf("//") + 2);
    url = url.substring(0, url.indexOf("/"));
    String[] tmp = url.split(":");
    if (tmp.length == 1) {
      initClientConfig(method, tmp[0], address, 7236);
    } else if (tmp.length == 2) {
      initClientConfig(method, tmp[0], address, Integer.parseInt(tmp[1]));
    }
  }

  public RtspClient(EventBase eventBase, String address, int port) {
    eventBase_ = eventBase;
    String host = address.substring(address.indexOf("//") + 2);
    host = host.substring(0, host.indexOf("/"));
    initClientConfig("udp", host, address, port);
  }

  public RtspClient(EventBase eventBase, String method, String address, int port) {
    eventBase_ = eventBase;
    String host = address.substring(address.indexOf("//") + 2);
    host = host.substring(0, host.indexOf("/"));
    initClientConfig(method, host, address, port);
  }

  public void setReceiverName(String name) {
    receiverName_ = name;
  }

  public void setRtspHandler(RtspHandler handler) {
    rtspHandler_ = handler;
  }

  public void setRtspSender(RtspSender sender) {
    sender_ = sender;
  }

  public void setAudioFormatListener(AudioFormatListener listener) {
    audioFormatListener_ = listener;
  }

  public void setSourceCapabilityListener(SourceCapabilityListener listener) {
    sourceCapabilityListener_ = listener;
  }

  public void setVideoResolutionListener(VideoResolutionListener listener) {
    videoResolutionListener_ = listener;
  }

  public void setPacketLostListener(PacketLostListener listener) {
    packetLostListener_ = listener;
  }

  public void setRtpPort(int rtpPort) {
    rtpPort_ = rtpPort;
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

  public void pausePlayer() {
    if (rtpPlayer_ == null) {
      return;
    }

    rtpPlayer_.pause();
  }

  public void restartPlayer(Surface surface) {
    if (rtpPlayer_ == null) {
      return;
    }

    rtpPlayer_.restart(surface);
  }

  public void stopPlayer() {
    if (rtpPlayer_ == null) {
      return;
    }
    try {
      rtpPlayer_.stop();
    } catch (Exception e) {
    }
    rtpPlayer_.release();
    rtpPlayer_ = null;
  }

  public void mutePlayer(boolean mute) {
    if (rtpPlayer_ == null) {
      return;
    }

    rtpPlayer_.setMute(mute);
  }

  public void setActivate(boolean activate) {
    activate_ = activate;
  }

  public void requestIdr() {
    sendRequestIdr();
  }

  public void requestTeardown() {
    sendRequestTeardown();
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

  @Override
  public void onVideoResolution(int width, int height) {
    if (videoResolutionListener_ != null) {
      videoResolutionListener_.onVideoResolution(width, height);
    }
  }

  @Override
  public void onPacketLost() {
    packetLostListener_.onPacketLost();
  }

  public interface AudioFormatListener {
    void onAudioFormatUpdate(String name, int sampleRate, int channelCount);
  }

  public interface SourceCapabilityListener {
    void onUibcCapability(boolean isUibcSupported);
  }

  public interface VideoResolutionListener {
    void onVideoResolution(int width, int height);
  }

  public interface PacketLostListener {
    void onPacketLost();
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

  @Override
  public void onRtspResponse(RtspResponseMessage rParams) {
    if (activate_ == false)
      return;

    if (rParams.statusCode == 200) { // 200 ok
      if (TextUtils.isEmpty(sourceProductId_)) {
        handleSourceProductId(rParams);
      }

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
            startRTPReceiver(surface_);
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
            if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_TRIGGER_METHOD))) {
              handleTriggerMethod(rParams);
            } else {
              // source->sink M4 request
              handleAudioCodecs(rParams);
              handleVideoFormats(rParams);
              handleUibcCap(rParams);
              handleUibcSetting(rParams);
              Log.d(TAG, "Get audioCodecs: " + audioCodecs_ + ", videoFormats: " + videoFormats_);
              sendResponseOK();
            }
            break;
          }
        }
      } else {
        Log.d(TAG, "methodType is null.");
      }
    } catch (Exception e) {
      Log.e(TAG, "Exception:" + e);
    }
  }

  public void setSurface(Surface surface) {
    surface_ = surface;
  }

  private void handleSourceProductId(RtspResponseMessage rParams) {
    if (!TextUtils.isEmpty(rParams.headers.get(KEY_SERVER))) {
      String serverHeader = rParams.headers.get(KEY_SERVER);
      String[] serverArray = serverHeader.split(" ");
      if (serverArray.length > 0) {
        sourceProductId_ = serverArray[0];
        if (sourceProductId_.contains(WINDOWS_SOURCE_PRODUCT_ID)) {
          isWindowsSource_ = true;
        }
        Log.d(TAG, "========== RTSP SOURCE DEVICE INFO ==========");
        Log.d(TAG, "Server Header: " + serverHeader);
        Log.d(TAG, "Product ID: " + sourceProductId_);
        Log.d(TAG, "Is Windows Source: " + isWindowsSource_);
      }
    }
  }

  // SET_PARAMETER - wfd_trigger_method
  private void handleTriggerMethod(RtspRequestMessage rParams) {
    String triggerMethod = rParams.bodyMap.get(KEY_WFD_TRIGGER_METHOD);
    switch (triggerMethod) {
      case METHOD_SETUP: {
        sendResponseOK();
        sendRequestM6();
        break;
      }
      case METHOD_TEARDOWN: {
        sendResponseTeardown();
        cleanResource();
        break;
      }
    }
  }

  // SET_PARAMETER - wfd_audio_codecs
  private void handleAudioCodecs(RtspRequestMessage rParams) {
    if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_AUDIO_CODECS))) {
      audioCodecs_ = rParams.bodyMap.get(KEY_WFD_AUDIO_CODECS);
      WfdAudioCodec audioCodecInfo = new WfdAudioCodec();
      parseAudioCodecs(audioCodecs_, audioCodecInfo);
      if (audioFormatListener_ != null) {
        audioFormatListener_.onAudioFormatUpdate(audioCodecInfo.name,
            audioCodecInfo.sampleRate,
            audioCodecInfo.channelCount);
      }
    }
  }

  // SET_PARAMETER - wfd_video_formats
  private void handleVideoFormats(RtspRequestMessage rParams) {
    if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_VIDEO_FORMATS))) {
      videoFormats_ = rParams.bodyMap.get(KEY_WFD_VIDEO_FORMATS);
    }
  }

  // SET_PARAMETER - wfd_uibc_capability
  private void handleUibcCap(RtspRequestMessage rParams) {
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
  }

  // SET_PARAMETER - wfd_uibc_setting
  private void handleUibcSetting(RtspRequestMessage rParams) {
    if (!TextUtils.isEmpty(rParams.bodyMap.get(KEY_WFD_UIBC_SETTING))) {
      // uibSetting e.g. "enable\r\n"
      String uibcSetting = rParams.bodyMap.get(KEY_WFD_UIBC_SETTING);
      boolean uibcEnable = uibcSetting.contains("enable") && uibcPort_ != 0;
      if (uibcEnable != isUibcEnable_) {
        isUibcEnable_ = uibcEnable;
        if (isUibcEnable_) {
          startUibc();
        } else {
          stopUibc();
        }
      }
    }
  }

  private void cleanResource() {
    curState_ = STATE_STOPPED;
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
    sendResponse(rm);
  }

  private void sendRequestM2() {
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_OPTIONS;
    rm.path = "*";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_REQUIRE, "org.wfa.wfd1.0");
    sendRequest(rm);
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
        "wfd_uibc_capability: " + getUibcCaps() + "\r\n" +
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
    sendResponse(rm);
  }

  /**
   * sink->source M4/M5/KeepAlive response
   */
  private void sendResponseOK() {
    RtspResponseMessage rm = new RtspResponseMessage();
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.statusCode = 200;
    rm.headers = addCommonHeader();
    sendResponse(rm);
  }

  private void sendResponseTeardown() {
    curState_ = STATE_STOPPING;
    RtspResponseMessage rm = new RtspResponseMessage();
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.statusCode = 200;
    rm.headers = addCommonHeader();
    sendResponse(rm);
  }

  private void sendRequestM6() {
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_SETUP;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_TRANSPORT,
        "RTP/AVP/" + (rtspParams_.isTCPTranslate ? "TCP;" : "UDP;") + "unicast;client_port=" + rtpPort_);
    sendRequest(rm);
  }

  private void sendRequestPlay() {
    curState_ = STATE_PLAYING;

    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_PLAY;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    rm.headers.put(KEY_SESSION, rtspParams_.session);
    sendRequest(rm);

    // IMPROVE
    if (sourceCapabilityListener_ != null) {
      boolean isUibcSupported = uibcPort_ != 0;
      sourceCapabilityListener_.onUibcCapability(isUibcSupported);
    }
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
    sendRequest(rm);
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
    sendRequest(rm);
  }

  private void sendRequestPause() {
    curState_ = STATE_PAUSE;
    RtspRequestMessage rm = new RtspRequestMessage();
    rm.methodType = METHOD_PAUSE;
    rm.path = "rtsp://" + rtspParams_.host + "/wfd1.0/streamid=0";
    rm.protocolVersion = KEY_RTSP_VERSION;
    rm.headers = addCommonHeader();
    sendRequest(rm);
  }

  private HashMap<String, String> addCommonHeader() {
    HashMap<String, String> headers = new HashMap<>();
    headers.put(KEY_CSEQ, String.valueOf(rtspParams_.cSeq++));
    return headers;
  }

  private String getWfdAudioCodecs() {
    return "AAC 00000001 00";
  }

  private static class WfdAudioCodec {
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

  private String getUibcCaps() {
    return "input_category_list=HIDC;hidc_cap_list=Keyboard/USB, Mouse/USB, MultiTouch/USB, Gesture/USB, RemoteControl/USB;port=none";

  }

  private void startRTPReceiver(Surface surface) {
    if (rtpPort_ == 0) {
      Log.e(TAG, "RTP receiver port is not configured");
      rtpPort_ = 0;
      return;
    }
    Log.d(TAG, "Native Miracast RTP receiver started on port: " + rtpPort_);
  }

  private void startUibc() {
    assert rtspHandler_ != null;

    rtspHandler_.startUibc(rtspParams_.host, uibcPort_);
  }

  private void stopUibc() {
    assert rtspHandler_ != null;
    rtspHandler_.stopUibc();
  }

  private void sendRequest(RtspRequestMessage rm) {
    sender_.sendRequest(rm);
  }

  private void sendResponse(RtspResponseMessage rm) {
    sender_.sendResponse(rm);
  }

  private static class RtspParameters {
    int cSeq = 0;
    Boolean isTCPTranslate = false;
    String host = "";
    String address = "";
    int port = 7236;
    String session = "";
  }

}
