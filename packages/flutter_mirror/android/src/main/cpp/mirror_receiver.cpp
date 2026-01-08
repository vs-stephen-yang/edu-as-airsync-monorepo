#include "mirror_receiver.h"
#include <assert.h>
#include "media/media_session_dump.h"
#include "media/media_session_impl.h"
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
  GooglecastReceiver::InitOnce();
}

MirrorReceiver::MirrorReceiver(
    jni::MirrorReceiverPtr&& proxy,
    jni::TextureRegistryPtr&& texture_registry,
    std::map<std::string, int>&& additional_codec_params)
    : proxy_(std::move(proxy)),
      texture_registry_(std::move(texture_registry)),
      additional_codec_params_(std::move(additional_codec_params)) {
  ALOGV("MirrorReceiver()");

  thread_id_ = std::this_thread::get_id();

  replay_receiver_ = std::make_unique<ReplayReceiver>(*this);
}

MirrorReceiver::~MirrorReceiver() {
  DCHECK_RUN_ON(thread_id_);

  ALOGV("~MirrorReceiver()");
}

void MirrorReceiver::EnableDump(const std::string& path) {
  dump_path_ = path;
}

void MirrorReceiver::StartMirrorReplay(
    const std::string& mirror_id,
    const std::string& video_codec,
    const std::string& video_path) {
  replay_receiver_->StartMirrorReplay(mirror_id, video_codec, video_path);
}

void MirrorReceiver::StartAirplay(
    const ap::AirplayReceiver::Config& config) {
  DCHECK_RUN_ON(thread_id_);

  ALOGD("Starting airplay auth:%s device ID:%s",
        config.enable_auth ? "on" : "off",
        config.device_id.c_str());

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

  StopSessionsByType(MirrorType::Airplay);

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

  googlecast_receiver_->Start(config);
}

void MirrorReceiver::StopGooglecast() {
  DCHECK_RUN_ON(thread_id_);

  if (!googlecast_receiver_) {
    return;
  }

  ALOGD("Stopping googlecast");
  googlecast_receiver_->Stop();
  ALOGD("googlecast has stopped");

  StopSessionsByType(MirrorType::Googlecast);

  googlecast_receiver_.reset();
  ALOGD("Googlecast has been freed");
}

void MirrorReceiver::EnableAudio(
    const std::string& mirror_id,
    bool enable) {
  DCHECK_RUN_ON(thread_id_);
  ALOGD("MirrorReceiver::EnableAudio(%s)", mirror_id.c_str());

  MirrorSessionPtr session = FindSession(mirror_id);
  if (!session) {
    return;
  }
  session->EnableAudio(enable);
}

void MirrorReceiver::StopMirror(
    const std::string& mirror_id) {
  DCHECK_RUN_ON(thread_id_);
  ALOGD("MirrorReceiver::StopMirror(%s)", mirror_id.c_str());

  MirrorSessionPtr session = FindSession(mirror_id);

  if (!session) {
    return;
  }
  session->StopMirror();
}

std::vector<MirrorSessionPtr> MirrorReceiver::FindSessionsByType(
    MirrorType mirrorType) {
  std::vector<MirrorSessionPtr> found;

  std::lock_guard<std::mutex> lock(mutex_);

  for (auto itr = sessions_.begin(); itr != sessions_.end(); ++itr) {
    MirrorSessionPtr session = itr->second;

    if (session->GetMirrorType() == mirrorType) {
      found.push_back(session);
    }
  }
  return found;
}

void MirrorReceiver::StopSessionsByType(
    MirrorType mirrorType) {
  auto sessions = FindSessionsByType(mirrorType);

  for (auto session : sessions) {
    session->Close();
    std::string mirror_id = session->GetMirrorId();

    bool isRemoved = RemoveSession(mirror_id);
    if (isRemoved) {
      proxy_->OnMirrorStop(mirror_id);
    }
  }
}

void MirrorReceiver::UpdateGooglecastCredentials(
    const openscreen::cast::CastReceiver::Credentials& credetials) {
  DCHECK_RUN_ON(thread_id_);

  if (!googlecast_receiver_) {
    return;
  }

  googlecast_receiver_->UpdateCredentials(credetials);
}

bool MirrorReceiver::IsAirplayServiceRunning() const {
  // AirPlay service running status check
  // If ap_receiver_ pointer is not null, the service is running
  return ap_receiver_ != nullptr;
}

bool MirrorReceiver::IsGooglecastServiceRunning() const {
  // Google Cast service running status check
  // If googlecast_receiver_ pointer is not null, the service is running
  return googlecast_receiver_ != nullptr;
}

// MirrorListener
bool MirrorReceiver::OnServiceRegister(
    const ServiceInfo& info) {
  return proxy_->OnServiceRegister(info);
}
bool MirrorReceiver::OnServiceUnregister(
    const std::string& service_name) {
  return proxy_->OnServiceUnregister(service_name);
}

void MirrorReceiver::OnMirrorAuth(
    const std::string& pin,
    unsigned int timeout_sec) {
  proxy_->OnMirrorAuth(
      pin,
      timeout_sec);
}

MediaSessionPtr MirrorReceiver::CreateMediaSession() {
  auto session = std::make_unique<MediaSessionImpl>(
      *texture_registry_,
      additional_codec_params_);

  if (!dump_path_.empty()) {
    return std::make_unique<MediaSessionDump>(
        std::move(session),
        dump_path_);
  } else {
    return session;
  }
}

void MirrorReceiver::OnMirrorStart(
    MirrorSessionPtr sess) {
  assert(sess);

  MirrorSession* session = sess.get();
  // After calling AddSession(sess),
  // sess has been moved and is no longer available!
  AddSession(sess);

  std::string mirror_id = session->GetMirrorId();
  ALOGD("MirrorReceiver::OnMirrorStart(%s)", mirror_id.c_str());

  auto media_session = CreateMediaSession();

  if (!session->StartMirror(
          std::move(media_session))) {
    session->StopMirror();

    // TODO: Should we always notify when a mirror session starts,
    // even if something goes wrong?
    return;
  }

  SurfaceTexture tex = session->GetTexture();

  std::string device_name = session->GetSourceDisplayName();
  std::string device_model = session->GetSourceDeviceModel();

  MirrorType mirror_type = session->GetMirrorType();

  proxy_->OnMirrorStart(
      mirror_id,
      tex.id,
      device_name,
      device_model,
      MirrorTypeToName(mirror_type));
}

void MirrorReceiver::OnMirrorStop(
    MirrorSession* session) {
  assert(session);

  std::string mirror_id = session->GetMirrorId();
  ALOGD("MirrorReceiver::OnMirrorStop(%s)", mirror_id.c_str());

  // delete the mirror session
  bool isRemoved = RemoveSession(mirror_id);
  if (isRemoved) {
    proxy_->OnMirrorStop(mirror_id);
  }
}

void MirrorReceiver::OnMirrorVideoResize(
    MirrorSession* session,
    int width,
    int height) {
  assert(session);

  std::string mirror_id = session->GetMirrorId();
  ALOGD("MirrorReceiver::OnMirrorVideoResize(%s,%d,%d)", mirror_id.c_str(), width, height);

  proxy_->OnMirrorVideoResize(
      mirror_id,
      width,
      height);
}

void MirrorReceiver::OnMirrorVideoFrameRate(
    MirrorSession* session,
    int fps) {
  std::string mirror_id = session->GetMirrorId();
  // ALOGD("MirrorReceiver::OnMirrorVideoFrameRate(%s,%d)", mirror_id.c_str(), fps);

  proxy_->OnMirrorVideoFrameRate(
      mirror_id,
      fps);
}

void MirrorReceiver::OnCredentialsRequest(
    int year,
    int month,
    int day) {
  proxy_->OnCredentialsRequest(
      year,
      month,
      day);
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
bool MirrorReceiver::RemoveSession(const std::string& mirror_id) {
  ALOGD("MirrorReceiver::RemoveSession(%s)", mirror_id.c_str());

  std::lock_guard<std::mutex> lock(mutex_);

  auto itr = sessions_.find(mirror_id);

  if (itr == sessions_.end()) {
    return false;
  }

  sessions_.erase(itr);
  ALOGD("Remaining mirror sessions = %u", (unsigned int)sessions_.size());
  return true;
}
