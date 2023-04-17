#include "miracast/miracast_receiver.h"
#include <assert.h>
#include "miracast/miracast_mirror_session.h"
#include "util/log.h"

MiracastReceiver::MiracastReceiver(
    jni::MiracastReceiverPtr proxy,
    jni::TextureRegistryPtr texture_registry)
    : proxy_(std::move(proxy)),
      texture_registry_(std::move(texture_registry)) {
}

// a mirror session starts
void MiracastReceiver::OnMirrorStart(int mirrorId) {
  // create a wrapper for the mirror session
  auto session = std::make_unique<MiracastMirrorSession>(
      mirrorId,
      *texture_registry_,
      *this);

  // start the mirror session
  session->StartMirror();

  SurfaceTexture texture = session->GetTexture();
  assert(texture.wnd != nullptr);

  mirror_sessions_[mirrorId] = std::move(session);

  proxy_->onMirrorStart(mirrorId, texture.id);
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
  proxy_->onMirrorVideoResize(
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
  proxy_->sendIdrRequest(mirrorId);
}
