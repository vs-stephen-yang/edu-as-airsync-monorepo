#include "replay/replay_receiver.h"
#include <sstream>
#include "replay_mirror_session.h"

ReplayReceiver::ReplayReceiver(MirrorListener& mirror_listener)
    : mirror_listener_(mirror_listener) {
}

void ReplayReceiver::StartMirrorReplay(
    const std::string& mirror_id,
    const std::string& video_codec,
    const std::string& video_path) {
  // create a wrapper for the mirror session
  auto session = std::make_shared<ReplayMirrorSession>(
      mirror_id,
      mirror_listener_,
      video_codec,
      video_path);

  // notify that a mirror starts
  mirror_listener_.OnMirrorStart(session);
}
