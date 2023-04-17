#ifndef FLUTTER_MIRROR_PLUGIN_MIRACAST_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_MIRACAST_RECEIVER_H_

#include <jni/miracast_receiver.h>
#include <map>
#include "miracast/miracast_mirror_session.h"

class MiracastReceiver {
 public:
  MiracastReceiver(
      jni::MiracastReceiverPtr proxy,
      jni::TextureRegistryPtr texture_registry);

  void OnMirrorStart(int mirrorId);

  void OnMirrorStop(int mirrorId);

  void OnAudioFormatUpdate(
      int mirrorId,
      const std::string& codecName,
      int sampleRate,
      int channelCount);

  void OnVideoFormatChanged(
      MiracastMirrorSession& session,
      int width,
      int height);

  void OnPacket(
      int mirrorId,
      const uint8_t* data,
      int length);

  void SendIdrRequest(int mirrorId);

 private:
  jni::MiracastReceiverPtr proxy_;
  jni::TextureRegistryPtr texture_registry_;

  std::map<int, MiracastMirrorSessionPtr> mirror_sessions_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MIRACAST_RECEIVER_H_
