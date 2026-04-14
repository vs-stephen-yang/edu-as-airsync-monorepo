#ifndef FLUTTER_MIRROR_PLUGIN_REPLAY_RECEIVER_H_
#define FLUTTER_MIRROR_PLUGIN_REPLAY_RECEIVER_H_

#include "cast/cast_receiver.h"

#include <mirror_listener.h>

class ReplayReceiver {
 public:
  ReplayReceiver(MirrorListener& mirror_listener);

  void StartMirrorReplay(
      const std::string& mirror_id,
      const std::string& video_codec,
      const std::string& video_path);

 private:
  MirrorListener& mirror_listener_;
};

#endif  // FLUTTER_MIRROR_PLUGIN_REPLAY_RECEIVER_H_
