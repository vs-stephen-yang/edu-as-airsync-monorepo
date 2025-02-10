#ifndef FLUTTER_MIRROR_PLUGIN_MIRACAST_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_MIRACAST_RECEIVER_H_

#include <jni/miracast_receiver.h>
#include <map>
#include "miracast/miracast_mirror_session.h"

class MiracastReceiver {
 public:
  MiracastReceiver(
      jni::MiracastReceiverPtr proxy,
      MirrorListener& mirror_listener);

  void StopMirror(const std::string& mirrorId);

  void OnMirrorStart(
      const std::string& mirrorId,
      const std::string& device_name);

  void OnMirrorStop(const std::string& mirrorId);

  void OnAudioFormatUpdate(
      const std::string& mirrorId,
      const std::string& codecName,
      int sampleRate,
      int channelCount);
  void OnPacket(
      const std::string& mirrorId,
      const uint8_t* data,
      int length);

  void SendIdrRequest(const std::string& mirrorId);

 private:
  MiracastMirrorSessionPtr FindSession(const std::string& mirrorId);

  void RemoveSession(const std::string& mirrorId);

 private:
  jni::MiracastReceiverPtr proxy_;
  MirrorListener& mirror_listener_;

  std::map<std::string, MiracastMirrorSessionPtr> mirror_sessions_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MIRACAST_RECEIVER_H_
