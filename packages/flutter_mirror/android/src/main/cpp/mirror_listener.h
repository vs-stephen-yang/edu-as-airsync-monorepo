#ifndef FLUTTER_MIRROR_PLUGIN_MIRROR_LISTENER_H_
#define FLUTTER_MIRROR_PLUGIN_MIRROR_LISTENER_H_

#include <string>
#include "mirror_session.h"

class MirrorListener {
 public:
  virtual ~MirrorListener() = default;

  virtual void OnMirrorAuth(
      const std::string& pin_code,
      unsigned int expiry_sec) = 0;

  virtual void OnMirrorStart(
      MirrorSessionPtr session) = 0;

  virtual void OnMirrorStop(
      MirrorSession* session) = 0;

  virtual void OnMirrorVideoResize(
      MirrorSession* session,
      int width,
      int height) = 0;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MIRROR_LISTENER_H_
