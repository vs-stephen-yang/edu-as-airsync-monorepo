#ifndef FLUTTER_MIRROR_PLUGIN_MIRROR_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_MIRROR_SESSION_H_

#include <memory>
#include <string>
#include "media/media_session.h"
#include "media/surface_texture.h"

enum class MirrorType {
  Airplay,
  Googlecast,
  Miracast
};

class MirrorSession {
 public:
  virtual ~MirrorSession() = default;

  virtual bool StartMirror(
      MediaSessionPtr media_session) = 0;

  virtual std::string GetMirrorId() = 0;
  virtual SurfaceTexture GetTexture() = 0;

  virtual std::string GetSourceDisplayName() = 0;
  virtual std::string GetSourceDeviceModel() = 0;

  virtual MirrorType GetMirrorType() = 0;

  virtual void EnableAudio(bool enable) = 0;

  // StopMirror() stops the underlying session.
  // Once the session stops, Close() will be automatically invoked.
  virtual void StopMirror() = 0;

  // Make sure to call Close() only after confirming that the underlying session has stopped.
  // Close() is unnecessary in the case of StopMirror() since it will be automatically invoked after the underlying session stops.
  virtual void Close() = 0;
};

typedef std::shared_ptr<MirrorSession> MirrorSessionPtr;

#endif  // FLUTTER_MIRROR_PLUGIN_MIRROR_SESSION_H_
