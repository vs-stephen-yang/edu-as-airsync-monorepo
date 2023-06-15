#include "miracast/miracast_receiver.h"
#include <assert.h>
#include "miracast/miracast_mirror_session.h"
#include "util/log.h"

MiracastReceiver::MiracastReceiver(
    jni::MiracastReceiverPtr proxy,
    MirrorListener& mirror_listener)
    : proxy_(std::move(proxy)),
      mirror_listener_(mirror_listener) {
}

// a mirror session starts
void MiracastReceiver::OnMirrorStart(const std::string& mirrorId) {
  // create a wrapper for the mirror session
  auto session = std::make_shared<MiracastMirrorSession>(
      mirrorId,
      mirror_listener_,
      *this);

  mirror_sessions_[mirrorId] = session;

  // notify that a mirror starts
  mirror_listener_.OnMirrorStart(
      session);
}

void MiracastReceiver::OnMirrorStop(const std::string& mirrorId) {
  MiracastMirrorSessionPtr session = FindSession(mirrorId);
  if (!session) {
    return;
  }

  session->OnMirrorStop();

  RemoveSession(mirrorId);
}

void MiracastReceiver::StopMirror(const std::string& mirrorId) {
  RemoveSession(mirrorId);

  proxy_->StopMirror(mirrorId);
}

void MiracastReceiver::OnAudioFormatUpdate(
    const std::string& mirrorId,
    const std::string& codecName,
    int sampleRate,
    int channelCount) {
  MiracastMirrorSessionPtr session = FindSession(mirrorId);
  if (!session) {
    return;
  }

  session->UpdateAudioFormat(codecName, sampleRate, channelCount);
}

void MiracastReceiver::OnPacket(const std::string& mirrorId, const uint8_t* data, int length) {
  MiracastMirrorSessionPtr session = FindSession(mirrorId);
  if (!session) {
    return;
  }

  session->processRTPData(data, length);
}

void MiracastReceiver::SendIdrRequest(const std::string& mirrorId) {
  proxy_->sendIdrRequest(mirrorId);
}

MiracastMirrorSessionPtr MiracastReceiver::FindSession(const std::string& mirrorId) {
  auto itr = mirror_sessions_.find(mirrorId);
  if (itr == mirror_sessions_.end()) {
    return {};
  }

  return itr->second;
}

void MiracastReceiver::RemoveSession(const std::string& mirrorId) {
  auto itr = mirror_sessions_.find(mirrorId);
  if (itr == mirror_sessions_.end()) {
    return;
  }

  mirror_sessions_.erase(itr);
}
