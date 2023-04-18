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
void MiracastReceiver::OnMirrorStart(int mirrorId) {
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

void MiracastReceiver::OnMirrorStop(int mirrorId) {
  MiracastMirrorSessionPtr session = FindSession(mirrorId);
  if (!session) {
    return;
  }

  session->OnMirrorStop();

  RemoveSession(mirrorId);
}

void MiracastReceiver::StopMirror(int mirrorId) {
  // TODO
}

void MiracastReceiver::OnAudioFormatUpdate(
    int mirrorId,
    const std::string& codecName,
    int sampleRate,
    int channelCount) {
  MiracastMirrorSessionPtr session = FindSession(mirrorId);
  if (!session) {
    return;
  }

  session->UpdateAudioFormat(codecName, sampleRate, channelCount);
}

void MiracastReceiver::OnPacket(int mirrorId, const uint8_t* data, int length) {
  MiracastMirrorSessionPtr session = FindSession(mirrorId);
  if (!session) {
    return;
  }

  session->processRTPData(data, length);
}

void MiracastReceiver::SendIdrRequest(int mirrorId) {
  proxy_->sendIdrRequest(mirrorId);
}

MiracastMirrorSessionPtr MiracastReceiver::FindSession(int mirrorId) {
  auto itr = mirror_sessions_.find(mirrorId);
  if (itr == mirror_sessions_.end()) {
    return {};
  }

  return itr->second;
}

void MiracastReceiver::RemoveSession(int mirrorId) {
  auto itr = mirror_sessions_.find(mirrorId);
  if (itr == mirror_sessions_.end()) {
    return;
  }

  mirror_sessions_.erase(itr);
}
