#ifndef FLUTTER_MIRROR_PLUGIN_AP_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_AP_RECEIVER_H_

#include "airplay/airplay_receiver.h"

#include <thread>
#include "airplay/ap_mirror_session.h"

class ApReceiver
    : public ap::AirplayReceiver::Listener {
 public:
  ApReceiver(
      MirrorListener& mirror_listener);

  ~ApReceiver();

  bool Init();

  bool Start(
      const ap::AirplayReceiver::Config& config);

  void Stop();

  // implements AirplayReceiver::Listener
  virtual void OnAuthRequest(
      const std::string& pin,
      unsigned int timeout_sec) override;

  virtual bool OnMirrorStart(
      ap::AirplayMirrorSessionPtr session) override;

 private:
  MirrorListener& mirror_listener_;

  ap::AirplayReceiverPtr receiver_;

  std::unique_ptr<std::thread> thread_;

  unsigned int mirror_increment_seq_ = 0;
};

#endif  // FLUTTER_MIRROR_PLUGIN_AP_RECEIVER_H_
