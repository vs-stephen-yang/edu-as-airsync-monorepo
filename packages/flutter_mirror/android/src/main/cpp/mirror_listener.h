#ifndef FLUTTER_MIRROR_PLUGIN_MIRROR_LISTENER_H_
#define FLUTTER_MIRROR_PLUGIN_MIRROR_LISTENER_H_

#include <string>
#include "mirror_session.h"
#include "service_info.h"

class MirrorListener {
 public:
  virtual ~MirrorListener() = default;

  virtual bool OnServiceRegister(
      const ServiceInfo& info) = 0;

  virtual bool OnServiceUnregister(
      const std::string& service_name) = 0;

  virtual void OnMirrorAuth(
      const std::string& pin_code,
      unsigned int timeout_sec) = 0;

  virtual void OnMirrorStart(
      MirrorSessionPtr session) = 0;

  virtual void OnMirrorStop(
      MirrorSession* session) = 0;

  virtual void OnMirrorVideoResize(
      MirrorSession* session,
      int width,
      int height) = 0;

  virtual void OnMirrorVideoFrameRate(
      MirrorSession* session,
      int fps) = 0;

  // for Googlecast device authentication
  virtual void OnCredentialsRequest(
      int year,
      int month,
      int day) = 0;
};

#endif  // FLUTTER_MIRROR_PLUGIN_MIRROR_LISTENER_H_
