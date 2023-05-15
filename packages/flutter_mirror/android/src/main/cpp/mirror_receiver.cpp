#include "mirror_receiver.h"
#include <assert.h>
#include "util/log.h"
#include "util/thread_checker.h"

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

void MirrorReceiver::InitializeOnce() {
  ALOGD("MirrorReceiver::InitializeOnce()");

  ApReceiver::InitOnce();
}

MirrorReceiver::MirrorReceiver(
    jni::MirrorReceiverPtr&& proxy,
    jni::TextureRegistryPtr&& texture_registry)
    : proxy_(std::move(proxy)),
      texture_registry_(std::move(texture_registry)) {
  ALOGV("MirrorReceiver()");

  thread_id_ = std::this_thread::get_id();
}

MirrorReceiver::~MirrorReceiver() {
  DCHECK_RUN_ON(thread_id_);

  ALOGV("~MirrorReceiver()");
}

void MirrorReceiver::StartAirplay(
    const ap::AirplayReceiver::Config& config) {
  DCHECK_RUN_ON(thread_id_);

  ALOGD("Starting airplay auth:%s",
        config.enable_auth ? "on" : "off");

  if (ap_receiver_) {
    return;
  }

  ap_receiver_ = std::make_unique<ApReceiver>(
      *this);

  ap_receiver_->Start(config);
}

void MirrorReceiver::StopAirplay() {
  DCHECK_RUN_ON(thread_id_);

  if (!ap_receiver_) {
    return;
  }

  ALOGD("Stopping airplay");
  ap_receiver_->Stop();
  ALOGD("Airplay has stopped");

  ap_receiver_.reset();
  ALOGD("Airplay has been freed");
}

void MirrorReceiver::StartGooglecast(
    const openscreen::cast::CastReceiver::Config& config) {
  DCHECK_RUN_ON(thread_id_);

  ALOGD("Starting googlecast");

  if (googlecast_receiver_) {
    return;
  }

  googlecast_receiver_ = std::make_unique<GooglecastReceiver>(
      *this);

  googlecast_receiver_->Init();
  googlecast_receiver_->Start(config);
}

void MirrorReceiver::StopGooglecast() {
  DCHECK_RUN_ON(thread_id_);

  ALOGD("Stopping googlecast");

  // TODO:
}

void MirrorReceiver::EnableAudio(
    const std::string& mirror_id,
    bool enable) {
  DCHECK_RUN_ON(thread_id_);

  MirrorSessionPtr session = FindSession(mirror_id);
  if (!session) {
    return;
  }
  session->EnableAudio(enable);
}

void MirrorReceiver::StopMirror(
    const std::string& mirror_id) {
  DCHECK_RUN_ON(thread_id_);

  MirrorSessionPtr session = FindSession(mirror_id);

  if (!session) {
    return;
  }
  session->StopMirror();

  RemoveSession(mirror_id);
}

void MirrorReceiver::UpdateGooglecastCredentials(
    const openscreen::cast::CastReceiver::Credentials& credetials) {
  DCHECK_RUN_ON(thread_id_);

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

  AddSession(session);
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
  RemoveSession(mirror_id);

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

void MirrorReceiver::AddSession(MirrorSessionPtr session) {
  std::string mirror_id = session->GetMirrorId();

  std::lock_guard<std::mutex> lock(mutex_);

  sessions_[mirror_id] = session;
}

MirrorSessionPtr MirrorReceiver::FindSession(const std::string& mirror_id) {
  std::lock_guard<std::mutex> lock(mutex_);

  auto itr = sessions_.find(mirror_id);
  if (itr == sessions_.end()) {
    return {};
  }

  return itr->second;
}
void MirrorReceiver::RemoveSession(const std::string& mirror_id) {
  std::lock_guard<std::mutex> lock(mutex_);

  auto itr = sessions_.find(mirror_id);

  assert(itr != sessions_.end());
  if (itr == sessions_.end()) {
    return;
  }

  sessions_.erase(itr);
}
