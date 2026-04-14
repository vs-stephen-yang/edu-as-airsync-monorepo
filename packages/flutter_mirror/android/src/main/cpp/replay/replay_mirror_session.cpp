#include "replay/replay_mirror_session.h"
#include <assert.h>
#include <media/video_frame_reader.h>
#include <optional>
#include "cast/media_formats.h"
#include "util/log.h"

static VideoCodecType mapVideoCodecType(const std::string& codecType) {
  if (codecType == "VP80") {
    return VideoCodecType::kVp8;
  } else if (codecType == "H264") {
    return VideoCodecType::kH264;
  } else {
    throw std::runtime_error("Unknown video codec");
  }
}

ReplayMirrorSession::ReplayMirrorSession(
    const std::string& mirror_id,
    MirrorListener& mirror_listener,
    const std::string& videoCodec,
    const std::string& videoPath)
    : mirror_id_(mirror_id),
      mirror_listener_(mirror_listener),
      videoCodec_(videoCodec),
      videoPath_(videoPath) {
  ALOGV("ReplayMirrorSession()");
}

ReplayMirrorSession::~ReplayMirrorSession() {
  ALOGV("~ReplayMirrorSession()");
}

bool ReplayMirrorSession::StartMirror(MediaSessionPtr media_session) {
  ALOGD("ReplayMirrorSession::StartMirror()");

  VideoCodecType video_codec = mapVideoCodecType(videoCodec_);
  AudioCodecType audio_codec = AudioCodecType::kAac;

  AudioFormat audio_format;
  audio_format.sample_rate = 44100;
  audio_format.channel_count = 2;
  audio_format.has_adts = true;

  media_session_ = std::move(media_session);

  if (!media_session_->Start(
          this,
          video_codec,
          audio_codec,
          audio_format)) {
    return false;
  }

  // Start the video thread
  running_ = true;
  video_thread_ = std::thread(&ReplayMirrorSession::VideoReaderThread, this);

  return true;
}

void ReplayMirrorSession::EnableAudio(bool enable) {
}

void ReplayMirrorSession::StopMirror() {
  ALOGD("ReplayMirrorSession::StopMirror()");

  running_ = false;  // Signal the thread to stop

  if (video_thread_.joinable()) {
    video_thread_.join();
  }

  Close();
}

void ReplayMirrorSession::Close() {
  media_session_->Stop();
  media_session_.reset();
}

void ReplayMirrorSession::OnVideoFormatChanged(int width, int height) {
  mirror_listener_.OnMirrorVideoResize(this, width, height);
}
void ReplayMirrorSession::OnVideoFrameRate(int fps) {
  mirror_listener_.OnMirrorVideoFrameRate(this, fps);
}

std::string ReplayMirrorSession::GetMirrorId() {
  return mirror_id_;
}

SurfaceTexture ReplayMirrorSession::GetTexture() {
  return media_session_->GetTexture();
}
std::string ReplayMirrorSession::GetSourceDisplayName() {
  return "";
}

std::string ReplayMirrorSession::GetSourceDeviceModel() {
  return "";
}

MirrorType ReplayMirrorSession::GetMirrorType() {
  return MirrorType::Googlecast;
}

void ReplayMirrorSession::VideoReaderThread() {
  ALOGD("ReplayMirrorSession::VideoReaderThread started");

  try {
    // Use VideoFrameReader to read the video file
    VideoFrameReader frameReader(videoPath_);

    uint64_t start_timestamp_us = 0;                                      // Start timestamp in microseconds
    std::chrono::time_point<std::chrono::system_clock> start_time_point;  // Start time as a time_point

    while (running_) {
      auto payload = std::make_shared<std::vector<uint8_t>>();
      uint64_t frame_timestamp_us = 0;  // Timestamp of the current frame in microseconds

      // Read a frame
      if (!frameReader.readFrame(*payload, frame_timestamp_us)) {
        ALOGD("End of video file or read error.");
        break;
      }

      if (start_timestamp_us == 0) {
        // Initialize the start timestamp and start time point
        start_timestamp_us = frame_timestamp_us;
        start_time_point = std::chrono::system_clock::now();
      }

      // Calculate elapsed time in microseconds
      auto now_time_point = std::chrono::system_clock::now();
      uint64_t elapsed_real_us = std::chrono::duration_cast<std::chrono::microseconds>(now_time_point - start_time_point).count();

      // Calculate the elapsed time based on frame timestamps
      uint64_t frame_elapsed_us = frame_timestamp_us - start_timestamp_us;

      // Adjust playback delay based on frame timestamps
      if (frame_elapsed_us > elapsed_real_us) {
        uint64_t delay_us = frame_elapsed_us - elapsed_real_us;
        std::this_thread::sleep_for(std::chrono::microseconds(delay_us));
      }

      // Feed the frame to the decoder
      media_session_->OnVideoFrame(false, payload, frame_timestamp_us);
    }
  } catch (const std::exception& ex) {
    ALOGE("Error in VideoReaderThread: %s", ex.what());
  }

  ALOGD("ReplayMirrorSession::VideoReaderThread ended");
}
