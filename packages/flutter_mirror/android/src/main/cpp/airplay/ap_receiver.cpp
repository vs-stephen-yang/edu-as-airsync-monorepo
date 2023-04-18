#include "airplay/ap_receiver.h"

#include <assert.h>

#include "airplay/ap_mirror_session.h"
#include "util/log.h"

#include <sstream>

static const std::string kMirrorIdPrefix = "airplay-";

static std::string FormatMirrorId(unsigned int seq) {
  std::stringstream strm;

  strm << kMirrorIdPrefix << seq;
  return strm.str();
}

ApReceiver::ApReceiver(
    MirrorListener& mirror_listener)
    : mirror_listener_(mirror_listener) {
  ALOGV("ApReceiver()");
}

ApReceiver::~ApReceiver() {
  ALOGV("~ApReceiver()");
}

bool ApReceiver::Init() {
  assert(!host_);
  assert(!receiver_);

  // create a airplay receiver host
  host_ = ap::CreateAirplayReceiverHost();
  host_->InitLogger(ap::LogLevel::kInfo);

  // create a receiver from the host
  receiver_ = host_->CreateReceiver();

  // Run the event loop in the host
  thread_ = std::make_unique<std::thread>([this]() {
    host_->Run();
  });

  return true;
}

bool ApReceiver::Start(
    const ap::AirplayReceiver::Config& config) {
  assert(receiver_);
  if (!receiver_) {
    return false;
  }

  receiver_->Start(
      config,
      this);

  return true;
}

void ApReceiver::Stop() {
  assert(receiver_);
  if (!receiver_) {
    return;
  }

  receiver_->Stop();

  // TODO:
  thread_->join();
}

void ApReceiver::OnAuthRequest(
    const std::string& pin,
    unsigned int timeout_sec) {
  ALOGD("OnAuthRequest()");

  mirror_listener_.OnMirrorAuth(
      pin,
      timeout_sec);
}

// a mirror session starts
bool ApReceiver::OnMirrorStart(
    ap::AirplayMirrorSessionPtr sess) {
  ALOGD("OnMirrorStart()");

  mirror_increment_seq_ += 1;

  std::string mirror_id = FormatMirrorId(mirror_increment_seq_);

  // create a wrapper for the mirror session
  auto session = std::make_shared<ApMirrorSession>(
      mirror_id,
      mirror_listener_,
      sess);

  // notify that a mirror starts
  mirror_listener_.OnMirrorStart(
      session);

  return true;
}
