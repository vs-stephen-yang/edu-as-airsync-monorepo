#ifndef FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_

#include <map>

#include "jni/mirror_receiver.h"
#include "jni/texture_registry.h"

#include "mirror_listener.h"
#include "mirror_session.h"

#include "airplay/ap_receiver.h"
#include "googlecast/googlecast_receiver.h"

class MirrorReceiver
    : public MirrorListener {
 public:
  MirrorReceiver(
      jni::MirrorReceiverPtr&& mirror_receiver,
      jni::TextureRegistryPtr&& texture_registry);

  ~MirrorReceiver();

  // start airplay
  void StartAirplay(
      const ap::AirplayReceiver::Config& config);

  // start googlecast
  void StartGooglecast(
      const openscreen::cast::CastReceiver::Config& config);

  void EnableAudio(
      const std::string& mirror_id,
      bool enable);

  // stop a mirror session by its Id
  void StopMirror(
      const std::string& mirror_id);

  // MirrorListener
  virtual void OnMirrorAuth(
      const std::string& pin_code,
      unsigned int timeout_sec) override;

  virtual void OnMirrorStart(
      MirrorSessionPtr session) override;

  virtual void OnMirrorStop(
      MirrorSession* session) override;

  virtual void OnMirrorVideoResize(
      MirrorSession* session,
      int width,
      int height) override;

  virtual void OnCredentialsUpdate(
      int year,
      int month,
      int day) override;

 private:
  MirrorSessionPtr FindSession(const std::string& mirror_id);
  void RemoveMirror(const std::string& mirror_id);

 private:
  jni::MirrorReceiverPtr mirror_receiver_;
  jni::TextureRegistryPtr texture_registry_;

  // TODO: protect sessions_ with mutex
  std::map<std::string, MirrorSessionPtr> sessions_;

  // airplay
  std::unique_ptr<ApReceiver> ap_receiver_;

  // googlecast
  std::unique_ptr<GooglecastReceiver> googlecast_receiver_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_
