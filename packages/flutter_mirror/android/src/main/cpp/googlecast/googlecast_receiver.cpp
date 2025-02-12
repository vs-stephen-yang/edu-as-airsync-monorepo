#include "googlecast/googlecast_receiver.h"
#include <assert.h>
#include <sstream>
#include "googlecast_utils.h"
#include "service_info.h"
#include "util/log.h"

static const std::string kMirrorIdPrefix = "googlecast-";

static std::string FormatMirrorId(unsigned int seq) {
  std::stringstream strm;

  strm << kMirrorIdPrefix << seq;
  return strm.str();
}

static std::string FormatSenderDeviceName(
    const std::string& sender_ip,
    unsigned int seq) {
  std::stringstream strm;

  strm << sender_ip << "-" << seq;
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

bool GooglecastReceiver::OnServiceRegister(
    const openscreen::cast::ServiceInfo& gc_info) {
  ServiceInfo info = ToServiceInfo(gc_info);

  return mirror_listener_.OnServiceRegister(info);
}

bool GooglecastReceiver::OnServiceUnregister(
    const std::string& service_name) {
  return mirror_listener_.OnServiceUnregister(service_name);
}

// a mirror session starts
bool GooglecastReceiver::OnMirrorStart(
    openscreen::cast::CastMirrorSessionPtr sess,
    const std::string& sender_ip,
    const openscreen::cast::MediaFormats& media_formats) {
  ALOGD("GooglecastReceiver::OnMirrorStart()");

  mirror_increment_seq_ += 1;

  std::string mirror_id = FormatMirrorId(mirror_increment_seq_);
  std::string device_name = FormatSenderDeviceName(sender_ip, mirror_increment_seq_);

  // create a wrapper for the mirror session
  auto session = std::make_shared<GooglecastMirrorSession>(
      mirror_id,
      device_name,
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

  mirror_listener_.OnCredentialsRequest(
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
