#ifndef FLUTTER_MIRROR_PLUGIN_GOOGLECAST_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_GOOGLECAST_RECEIVER_H_

#include "cast/cast_receiver.h"

#include <thread>
#include "googlecast/googlecast_mirror_session.h"
#include "jni/texture_registry.h"

class GooglecastReceiver
    : public openscreen::cast::CastReceiver::Listener {
 public:
  GooglecastReceiver(
      MirrorListener& mirror_listener);
  ~GooglecastReceiver();

  static bool InitOnce();

  bool Start(
      const openscreen::cast::CastReceiver::Config& config);

  void Stop();

  void UpdateCredentials(
      const openscreen::cast::CastReceiver::Credentials& creds);

  // implements CastReceiver::Listener
  virtual bool OnServiceRegister(
      const openscreen::cast::ServiceInfo& info) override;

  virtual bool OnServiceUnregister(
      const std::string& service_name) override;

  virtual bool OnMirrorStart(
      openscreen::cast::CastMirrorSessionPtr session,
      const std::string& sender_ip,
      const openscreen::cast::MediaFormats& formats) override;

  virtual void OnCredentialsRequest(
      int year,
      int month,
      int day) override;

 private:
  MirrorListener& mirror_listener_;

  openscreen::cast::CastReceiverPtr receiver_;

  unsigned int mirror_increment_seq_ = 0;
};

#endif  // FLUTTER_MIRROR_PLUGIN_GOOGLECAST_RECEIVER_H_
