#include "mirror_receiver.h"
#include <assert.h>
#include "util/log.h"

std::string MirrorTypeToName(MirrorType mirror_type) {
  // The values must be same with the ones defined in lib\mirror_type.dart
  switch (mirror_type) {
    case MirrorType::Airplay:
      return "airplay";
    case MirrorType::Googlecast:
      return "googlecast";
    case MirrorType::Miracast:
      return "miracast";
  }
}

MirrorReceiver::MirrorReceiver(
    jni::MirrorReceiverPtr&& proxy,
    jni::TextureRegistryPtr&& texture_registry)
    : proxy_(std::move(proxy)),
      texture_registry_(std::move(texture_registry)) {
  ALOGV("MirrorReceiver()");
}

MirrorReceiver::~MirrorReceiver() {
  ALOGV("~MirrorReceiver()");
}

void MirrorReceiver::StartAirplay(
    const ap::AirplayReceiver::Config& config) {
  ALOGD("Starting airplay auth:%s",
        config.enable_auth ? "on" : "off");

  if (ap_receiver_) {
    return;
  }

  ap_receiver_ = std::make_unique<ApReceiver>(
      *this);

  ap_receiver_->Init();
  ap_receiver_->Start(config);
}

void MirrorReceiver::StartGooglecast(
    const openscreen::cast::CastReceiver::Config& config) {
  ALOGD("Starting googlecast");

  if (googlecast_receiver_) {
    return;
  }

  googlecast_receiver_ = std::make_unique<GooglecastReceiver>(
      *this);

  googlecast_receiver_->Init();
  googlecast_receiver_->Start(config);
}

void MirrorReceiver::EnableAudio(
    const std::string& mirror_id,
    bool enable) {
  MirrorSessionPtr session = FindSession(mirror_id);
  if (!session) {
    return;
  }
  session->EnableAudio(enable);
}

void MirrorReceiver::StopMirror(
    const std::string& mirror_id) {
  // TODO
}

void MirrorReceiver::UpdateGooglecastCredentials(
    const openscreen::cast::CastReceiver::Credentials& credetials) {
  if (!googlecast_receiver_) {
    return;
  }

  googlecast_receiver_->UpdateCredentials(credetials);
}

// MirrorListener
void MirrorReceiver::OnMirrorAuth(
    const std::string& pin,
    unsigned int timeout_sec) {
  proxy_->OnMirrorAuth(
      pin,
      timeout_sec);
}

void MirrorReceiver::OnMirrorStart(
    MirrorSessionPtr session) {
  assert(session);

  auto media_session = std::make_unique<MediaSession>(
      *texture_registry_);

  if (!session->StartMirror(
          std::move(media_session))) {
    return;
  }

  std::string mirror_id = session->GetMirrorId();
  SurfaceTexture tex = session->GetTexture();

  std::string device_name = session->GetSourceDisplayName();
  MirrorType mirror_type = session->GetMirrorType();

  sessions_[mirror_id] = session;

  proxy_->OnMirrorStart(
      mirror_id,
      tex.id,
      device_name,
      MirrorTypeToName(mirror_type));
}

void MirrorReceiver::OnMirrorStop(
    MirrorSession* session) {
  assert(session);

  session->StopMirror();

  std::string mirror_id = session->GetMirrorId();

  // delete the mirror session
  RemoveMirror(mirror_id);

  proxy_->OnMirrorStop(mirror_id);
}

void MirrorReceiver::OnMirrorVideoResize(
    MirrorSession* session,
    int width,
    int height) {
  assert(session);

  std::string mirror_id = session->GetMirrorId();

  proxy_->OnMirrorVideoResize(
      mirror_id,
      width,
      height);
}

void MirrorReceiver::OnCredentialsUpdate(
    int year,
    int month,
    int day) {
}

MirrorSessionPtr MirrorReceiver::FindSession(const std::string& mirror_id) {
  // TODO: protect sessions_ with mutex
  auto itr = sessions_.find(mirror_id);
  if (itr == sessions_.end()) {
    return {};
  }

  return itr->second;
}
void MirrorReceiver::RemoveMirror(const std::string& mirror_id) {
  // TODO: protect sessions_ with mutex
  auto itr = sessions_.find(mirror_id);

  assert(itr != sessions_.end());
  if (itr == sessions_.end()) {
    return;
  }

  sessions_.erase(itr);
}
