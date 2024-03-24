#ifndef FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_

#include <map>
#include <thread>

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
      jni::MirrorReceiverPtr&& proxy,
      jni::TextureRegistryPtr&& texture_registry);

  ~MirrorReceiver();

  static void InitializeOnce();

  // start airplay
  void StartAirplay(
      const ap::AirplayReceiver::Config& config);

  // stop airplay
  void StopAirplay();

  // start googlecast
  void StartGooglecast(
      const openscreen::cast::CastReceiver::Config& config);

  // stop Googlecast
  void StopGooglecast();

  void EnableAudio(
      const std::string& mirror_id,
      bool enable);

  // stop a mirror session by its Id
  void StopMirror(
      const std::string& mirror_id);

  // update googlecast's credentials for device authentication
  void UpdateGooglecastCredentials(
      const openscreen::cast::CastReceiver::Credentials& credetials);

  // MirrorListener
  virtual bool OnServiceRegister(
      const ServiceInfo& info) override;

  virtual bool OnServiceUnregister(
      const std::string& service_name) override;

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

  virtual void OnCredentialsRequest(
      int year,
      int month,
      int day) override;

 private:
  void AddSession(MirrorSessionPtr session);
  MirrorSessionPtr FindSession(const std::string& mirror_id);
  // returns true if the mirro_id exists and is removed successfully
  bool RemoveSession(const std::string& mirror_id);

  void StopSessionsByType(
      MirrorType mirrorType);

  std::vector<MirrorSessionPtr> FindSessionsByType(
      MirrorType mirrorType);

 private:
  jni::MirrorReceiverPtr proxy_;
  jni::TextureRegistryPtr texture_registry_;

  std::thread::id thread_id_;
  std::mutex mutex_;
  std::map<std::string, MirrorSessionPtr> sessions_;

  // airplay
  std::unique_ptr<ApReceiver> ap_receiver_;

  // googlecast
  std::unique_ptr<GooglecastReceiver> googlecast_receiver_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MIRROR_RECEIVER_H_
