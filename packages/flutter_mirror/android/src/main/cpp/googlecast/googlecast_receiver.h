#ifndef FLUTTER_MIRROR_PLUGIN_GOOGLECAST_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_GOOGLECAST_RECEIVER_H_

#include "cast/cast_receiver.h"
#include "cast/cast_receiver_host.h"

#include <thread>
#include "googlecast/googlecast_mirror_session.h"
#include "jni/texture_registry.h"

class GooglecastReceiver
    : public openscreen::cast::CastReceiver::Listener {
 public:
  GooglecastReceiver(
      MirrorListener& mirror_listener);
  ~GooglecastReceiver();

  bool Init();

  bool Start(
      const openscreen::cast::CastReceiver::Config& config);

  void Stop();

  void UpdateCredentials(
      const openscreen::cast::CastReceiver::Credentials& creds);

  // implements CastReceiver::Listener
  virtual bool OnMirrorStart(
      openscreen::cast::CastMirrorSessionPtr session) override;

  virtual void OnCredentialsRequest(
      int year,
      int month,
      int day) override;

 private:
  MirrorListener& mirror_listener_;

  openscreen::cast::CastReceiverHostPtr host_;
  openscreen::cast::CastReceiverPtr receiver_;

  std::unique_ptr<std::thread> thread_;

  unsigned int mirror_increment_seq_ = 0;
};

#endif  // FLUTTER_MIRROR_PLUGIN_GOOGLECAST_RECEIVER_H_
