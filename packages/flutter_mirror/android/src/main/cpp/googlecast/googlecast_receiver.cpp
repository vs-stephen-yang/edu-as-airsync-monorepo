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
    MirrorListener& mirror_listener)
    : mirror_listener_(mirror_listener) {
  ALOGV("GooglecastReceiver()");
}

GooglecastReceiver::~GooglecastReceiver() {
  ALOGV("~GooglecastReceiver()");
}

bool GooglecastReceiver::InitOnce() {
  openscreen::cast::InitOnce();

  return true;
}

bool GooglecastReceiver::Start(
    const openscreen::cast::CastReceiver::Config& config) {
  if (receiver_) {
    return false;
  }

  // create a receiver from the host
  receiver_ = openscreen::cast::CreateReceiver();

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
}

// a mirror session starts
bool GooglecastReceiver::OnMirrorStart(
    openscreen::cast::CastMirrorSessionPtr sess,
    const openscreen::cast::MediaFormats& media_formats) {
  ALOGD("GooglecastReceiver::OnMirrorStart()");

  mirror_increment_seq_ += 1;

  std::string mirror_id = FormatMirrorId(mirror_increment_seq_);

  // create a wrapper for the mirror session
  auto session = std::make_shared<GooglecastMirrorSession>(
      mirror_id,
      mirror_listener_,
      sess,
      media_formats);

  // notify that a mirror starts
  mirror_listener_.OnMirrorStart(
      session);

  return true;
}

void GooglecastReceiver::OnCredentialsRequest(
    int year,
    int month,
    int day) {
  ALOGD("GooglecastReceiver::OnCredentialsRequest(%d,%d,%d)", year, month, day);

  mirror_listener_.OnCredentialsUpdate(
      year,
      month,
      day);
}

void GooglecastReceiver::UpdateCredentials(
    const openscreen::cast::CastReceiver::Credentials& creds) {
  ALOGD("GooglecastReceiver::UpdateCredentials(%d,%d,%d)",
        creds.year,
        creds.month,
        creds.day);

  receiver_->UpdateCredentials(
      creds);
}
