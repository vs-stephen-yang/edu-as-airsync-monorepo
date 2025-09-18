package com.viewsonic.miracast;

import android.util.Log;
import android.view.Surface;

import com.viewsonic.miracast.net.EventBase;
import com.viewsonic.miracast.wifidirect.WiFiDirectListener;

import java.util.HashMap;
import java.util.Map;

public class MiraMgr
  implements WiFiDirectListener, MiraSessionListener {
  private MiraMgrListener listener_;
  private int mirror_increment_seq_ = 0;
  private static final String kMirrorIdPrefix_ = "miracast-";
  private final Map<String, MiraSession> mirror_sessions_ = new HashMap<>();

  private final Map<String, Long> session_textures_ = new HashMap<>();

  private final EventBase eventBase_;
  private SurfaceTextureProvider surfaceProvider_;

  static String formatMirrorId(int seq) {
    return kMirrorIdPrefix_ + seq;
  }

  public MiraSession createSession(
    String peerMacAddress,
    String peerName,
    String peerIp,
    int peerPort,
    String receiverName) {
    mirror_increment_seq_++;
    MiraSession session = new MiraSession(
      formatMirrorId(mirror_increment_seq_),
      peerIp,
      peerPort,
      peerMacAddress,
      peerName,
      receiverName,
      eventBase_,
      this);
    mirror_sessions_.put(formatMirrorId(mirror_increment_seq_), session);
    return session;
  }

  public String removeSessionByPeerAddress(String peerMacAddress) {
    for (Map.Entry<String, MiraSession> entry : mirror_sessions_.entrySet()) {
      if (entry.getValue().getPeerAddress().equals(peerMacAddress)) {
        String sessionId = entry.getKey();
        mirror_sessions_.remove(sessionId);

        Log.d(TAG, String.format("Remaining mira sessions = %d", mirror_sessions_.size()));
        return sessionId;
      }
    }
    return null;
  }

  private String receiverName_;

  private static final String TAG = "MiraMgr";

  MiraMgr(EventBase eventBase) {
    assert eventBase != null;

    eventBase_ = eventBase;
  }

  public void start(
    MiraMgrListener listener,
    String receiverName,
    SurfaceTextureProvider surfaceProvider
  ) {
    receiverName_ = receiverName;
    surfaceProvider_ = surfaceProvider;

    if (listener != null) {
      listener_ = listener;
    }
  }

  public void stop() {
    for (Map.Entry<String, MiraSession> entry : mirror_sessions_.entrySet()) {
      entry.getValue().stop();
      mirror_sessions_.remove(entry.getKey());
      if (listener_ != null) {
        listener_.onSessionEnd(entry.getKey());
      }
    }
  }

  public void rtspRequestIdr(String mirrorId) {
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.requestIdr();
    }
  }

  public void stopMirror(String mirrorId) {
    Log.d(TAG, String.format("MiraMgr.stopMirror(%s)", mirrorId));

    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.stop();
    }
  }

  public void onTouchEvent(String mirrorId_, int touchId, boolean touch, double x, double y) {
    MiraSession session = mirror_sessions_.get(mirrorId_);
    if (session != null) {
      session.onTouchEvent(touchId, touch, x, y);
    }
  }

  private void connectionPrompt(String peerMacAddress, String peerName, String peerIp, int peerPort) {
    MiraSession session = createSession(peerMacAddress, peerName, peerIp, peerPort, receiverName_);
    session.startRtsp();

    if (surfaceProvider_ != null) {
      surfaceProvider_.createSurfaceTextureAsync(session.getId(), new SurfaceTextureProviderCallback() {
        @Override
        public void onResult(long textureId) {
          Log.d(TAG, "Created SurfaceTexture id=" + textureId);
          try {
            Surface surface = surfaceProvider_.getSurfaceTexture(textureId);

            if (surface == null) {
              Log.e(TAG, "Surface is null!");
              return;
            }

            Log.d(TAG, "Surface is valid: " + surface.isValid());

            session.setSurface(surface);
            listener_.onMiracastStart(session.getId(), textureId, peerName);
            session_textures_.put(session.getId(), textureId);
          } catch (Exception e) {
            Log.e(TAG, "get surface failed" + e);
          }
        }
      });
    }
  }

  @Override
  public void onPeerConnected(String peerMacAddress, String name, String ip, int port) {
    Log.d(TAG, "onPeerConnected: " + peerMacAddress);
    connectionPrompt(peerMacAddress, name, ip, port);
  }

  @Override
  public void onPeerDisconnected(String peerMacAddress) {
    Log.d(TAG, "onPeerDisconnected:" + peerMacAddress);
    String removeSessionId = removeSessionByPeerAddress(peerMacAddress);
    if (removeSessionId != null) {
      if (listener_ != null) {
        listener_.onSessionEnd(removeSessionId);
      }

      Long textureId = session_textures_.get(removeSessionId);
      if (textureId != null) {
        surfaceProvider_.releaseSurfaceTexture(textureId);
      }
    }
  }

  @Override
  public void onWifiDirectError(String errorMessage) {
    if (listener_ != null) {
      listener_.onMiracastError(errorMessage);
    }
  }

  @Override
  public void onRtspConnected(String mirrorId, String deviceName) {
    // Miracast already started when peer connect
  }

  @Override
  public void onAudioFormatUpdate(String mirrorId, String codecName, int sampleRate, int channelCount) {
    if (listener_ != null) {
      try {
        listener_.onAudioFormatUpdate(mirrorId, codecName, sampleRate, channelCount);
      } catch (Exception e) {
        Log.e(TAG, "Failed to onAudioFormatUpdate() ", e);
      }
    }
  }

  @Override
  public void onMiracastSessionError(String mirrorId, String errorMessage) {
    if (listener_ != null) {
      listener_.onMiracastError(errorMessage);
    }
  }

  @Override
  public void onVideoResolution(String mirrorId, int width, int height) {
    if (listener_ != null) {
      listener_.onVideoResolution(mirrorId, width, height);
    }
  }

  @Override
  public void onSourceCapabilities(String mirrorId, boolean isUibcSupported) {
    if (listener_ != null) {
      listener_.onSourceCapabilities(mirrorId, isUibcSupported);
    }
  }

  public void pausePlayer(String mirrorId) {
    Log.d(TAG, "Surface destroyed - pause player: " + mirrorId);
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.pausePlayer();
    }
  }

  public void restartPlayer(String mirrorId, Surface surface) {
    Log.d(TAG, "Surface ready - restart player: " + mirrorId);
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.restartPlayer(surface);
    }
  }

  public void mutePlayer(String mirrorId, boolean mute) {
    MiraSession session = mirror_sessions_.get(mirrorId);
    if (session != null) {
      session.mutePlayer(mute);
    }
  }
}
