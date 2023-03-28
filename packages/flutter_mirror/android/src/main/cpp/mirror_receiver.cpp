#include "mirror_receiver.h"
#include <assert.h>
#include "util/log.h"

MirrorReceiver::MirrorReceiver(
    jni::MirrorReceiverPtr&& mirror_receiver,
    jni::TextureRegistryPtr&& texture_registry)
    : mirror_receiver_(std::move(mirror_receiver)),
      texture_registry_(std::move(texture_registry)) {
  ALOGV("MirrorReceiver()");
}

MirrorReceiver::~MirrorReceiver() {
  ALOGV("~MirrorReceiver()");
}

void MirrorReceiver::StartAirplay(
    const ap::AirplayReceiver::Config& config) {
  ALOGD("Starting airplay");

  if (ap_receiver_) {
    return;
  }

  ap_receiver_ = std::make_unique<ApReceiver>(
      *this,
      *texture_registry_);

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
      *this,
      *texture_registry_);

  googlecast_receiver_->Init();
  googlecast_receiver_->Start(config);
}

void MirrorReceiver::StopMirror(
    const std::string& mirror_id) {
  // TODO
}

// MirrorListener
void MirrorReceiver::OnMirrorAuth(
    const std::string& pin,
    unsigned int timeout_sec) {
  mirror_receiver_->OnMirrorAuth(
      pin,
      timeout_sec);
}

void MirrorReceiver::OnMirrorStart(
    MirrorSessionPtr session) {
  assert(session);

  std::string mirror_id = session->GetMirrorId();
  SurfaceTexture tex = session->GetTexture();

  sessions_[mirror_id] = std::move(session);

  mirror_receiver_->OnMirrorStart(mirror_id, tex.id);
}

void MirrorReceiver::OnMirrorStop(
    MirrorSession* session) {
  assert(session);

  session->StopMirror();

  std::string mirror_id = session->GetMirrorId();

  // delete the mirror session
  RemoveMirror(mirror_id);

  mirror_receiver_->OnMirrorStop(mirror_id);
}

void MirrorReceiver::OnMirrorVideoResize(
    MirrorSession* session,
    int width,
    int height) {
  assert(session);

  std::string mirror_id = session->GetMirrorId();

  mirror_receiver_->OnMirrorVideoResize(
      mirror_id,
      width,
      height);
}

void MirrorReceiver::OnCredentialsUpdate(
    int year,
    int month,
    int day) {
}

void MirrorReceiver::RemoveMirror(const std::string& mirror_id) {
  auto itr = sessions_.find(mirror_id);

  assert(itr != sessions_.end());
  if (itr == sessions_.end()) {
    return;
  }

  sessions_.erase(itr);
}
