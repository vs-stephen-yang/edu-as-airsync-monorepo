#ifndef FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_

#include <map>
#include "jni/mirror_receiver.h"
#include "jni/texture_registry.h"
#include "mirror_listener.h"
#include "mirror_session.h"

#include "airplay/ap_receiver.h"

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

  // stop a mirror session by its Id
  void StopMirror(
      const std::string& mirror_id);

  // MirrorListener
  virtual void OnMirrorAuth(
      const std::string& pin_code,
      unsigned int expiry_sec) override;

  virtual void OnMirrorStart(
      MirrorSessionPtr session) override;

  virtual void OnMirrorStop(
      MirrorSession* session) override;

  virtual void OnMirrorVideoResize(
      MirrorSession* session,
      int width,
      int height) override;

 private:
  void RemoveMirror(const std::string& mirror_id);

 private:
  jni::MirrorReceiverPtr mirror_receiver_;
  jni::TextureRegistryPtr texture_registry_;

  std::map<std::string, MirrorSessionPtr> sessions_;

  // airplay
  std::unique_ptr<ApReceiver> ap_receiver_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_
