#include "googlecast/googlecast_receiver.h"
#include <assert.h>

#include "util/log.h"

#include <sstream>

static const std::string kMirrorIdPrefix = "googlecast-";

static std::string FormatMirrorId(unsigned int seq) {
  std::stringstream strm;

  strm << kMirrorIdPrefix << seq;
  return strm.str();
}

GooglecastReceiver::GooglecastReceiver(
    MirrorListener& mirror_listener,
    jni::TextureRegistry& text_registry)
    : mirror_listener_(mirror_listener),
      texture_registry_(text_registry) {
  ALOGV("GooglecastReceiver()");
}

GooglecastReceiver::~GooglecastReceiver() {
  ALOGV("~GooglecastReceiver()");
}

bool GooglecastReceiver::Init() {
  assert(!host_);
  assert(!receiver_);

  if (host_ ||
      receiver_) {
    return false;
  }

  // create a receiver host
  host_ = openscreen::cast::CreateCastReceiverHost();

  // create a receiver from the host
  receiver_ = host_->CreateReceiver();

  // Run the event loop in the host
  thread_ = std::make_unique<std::thread>([this]() {
    host_->Run();
  });

  return true;
}

bool GooglecastReceiver::Start(
    const openscreen::cast::CastReceiver::Config& config) {
  assert(receiver_);
  if (!receiver_) {
    return false;
  }

  receiver_->Start(
      config,
      this);

  return true;
}

void GooglecastReceiver::Stop() {
  assert(receiver_);
  if (!receiver_) {
    return;
  }

  receiver_->Stop();

  // TODO:
  thread_->join();
}

// a mirror session starts
bool GooglecastReceiver::OnMirrorStart(
    openscreen::cast::CastMirrorSessionPtr sess) {
  ALOGD("OnMirrorStart()");

  mirror_increment_seq_ += 1;

  std::string mirror_id = FormatMirrorId(mirror_increment_seq_);

  // create a wrapper for the mirror session
  auto session = std::make_unique<GooglecastMirrorSession>(
      mirror_id,
      mirror_listener_,
      texture_registry_,
      sess);

  session->StartMirror();

  // notify that a mirror starts
  mirror_listener_.OnMirrorStart(
      std::move(session));

  return true;
}

void GooglecastReceiver::OnCredentialsRequest(
    int year,
    int month,
    int day) {
  mirror_listener_.OnCredentialsUpdate(
      year,
      month,
      day);
}
