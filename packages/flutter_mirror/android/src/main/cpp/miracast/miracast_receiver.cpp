#include "miracast/miracast_receiver.h"
#include "miracast/miracast_mirror_session.h"
#include "util/log.h"

MiracastReceiver::MiracastReceiver(
    jni::MiracastReceiverPtr miracast_receiver_proxy,
    jni::TextureRegistryPtr texture_registry_proxy)
    : miracast_receiver_proxy_(std::move(miracast_receiver_proxy)),
      texture_registry_proxy_(std::move(texture_registry_proxy)) {
}

// a mirror session starts
void MiracastReceiver::OnMirrorStart(int mirrorId) {
  // create a wrapper for the mirror session
  auto session = std::make_unique<MiracastMirrorSession>(
      mirrorId,
      *texture_registry_proxy_,
      *this);
  SurfaceTexture texture = session->GetTexture();

  // start the mirror session
  session->StartMirror();

  mirror_sessions_[mirrorId] = std::move(session);

  miracast_receiver_proxy_->onMirrorStart(mirrorId, texture.id);
}

void MiracastReceiver::OnMirrorStop(int mirrorId) {
  auto itr = mirror_sessions_.find(mirrorId);
  if (itr == mirror_sessions_.end()) {
    return;
  }

  MiracastMirrorSession* session = itr->second.get();

  session->StopMirror();

  mirror_sessions_.erase(itr);
}
void MiracastReceiver::OnAudioFormatUpdate(
    int mirrorId,
    const std::string& codecName,
    int sampleRate,
    int channelCount) {
  auto itr = mirror_sessions_.find(mirrorId);
  if (itr == mirror_sessions_.end()) {
    return;
  }

  MiracastMirrorSession* session = itr->second.get();
  session->UpdateAudioFormat(codecName, sampleRate, channelCount);
}

void MiracastReceiver::OnVideoFormatChanged(
    MiracastMirrorSession& session,
    int width,
    int height) {
  miracast_receiver_proxy_->onMirrorVideoResize(
      session.Id(),
      width,
      height);
}

void MiracastReceiver::OnPacket(int mirrorId, const uint8_t* data, int length) {
  auto itr = mirror_sessions_.find(mirrorId);
  if (itr == mirror_sessions_.end()) {
    return;
  }

  MiracastMirrorSession* session = itr->second.get();
  session->processRTPData(data, length);
}

void MiracastReceiver::SendIdrRequest(int mirrorId) {
  miracast_receiver_proxy_->sendIdrRequest(mirrorId);
}
