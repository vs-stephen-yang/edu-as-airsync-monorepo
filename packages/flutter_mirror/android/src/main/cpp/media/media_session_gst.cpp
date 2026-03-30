#include "media/media_session_gst.h"

#include <algorithm>
#include <chrono>
#include <cstring>
#include <mutex>
#include <span>
#include <thread>

#include "media/video_csd_util.h"
#include "media/video_decoder_wrapper.h"
#include "util/log.h"

namespace {
std::once_flag g_gst_once;

constexpr GstClockTime kNsPerUs = 1000;
constexpr int64_t kVideoLeadWaitThresholdUs = 15000;
constexpr int64_t kVideoLeadMaxSleepUs = 15000;
constexpr int64_t kVideoLateDropThresholdUs = 50000;

const char* GetAudioCaps(AudioCodecType codec_type, const AudioFormat& audio_format) {
  switch (codec_type) {
    case AudioCodecType::kAac:
      return audio_format.has_adts
                 ? "audio/mpeg, mpegversion=(int)4, stream-format=(string)adts"
                 : "audio/mpeg, mpegversion=(int)4";
    case AudioCodecType::kOpus:
      return "audio/x-opus";
  }

  return nullptr;
}

}  // namespace

MediaSessionGst::MediaSessionGst(
    jni::TextureRegistry& texture_registry,
    const std::map<std::string, int>& additional_codec_params)
    : texture_registry_(texture_registry),
      additional_codec_params_(additional_codec_params) {
  std::call_once(
      g_gst_once,
      []() {
        int argc = 0;
        char** argv = nullptr;
        gst_init(&argc, &argv);
        gst_debug_set_default_threshold(GST_LEVEL_WARNING);
        gst_debug_remove_log_function(gst_debug_log_default);
      });
}

MediaSessionGst::~MediaSessionGst() {
  Stop();
}

bool MediaSessionGst::Start(
    MediaSession::Listener* listener,
    VideoCodecType video_codec,
    AudioCodecType audio_codec,
    AudioFormat audio_format) {
  listener_ = listener;
  video_codec_ = video_codec;
  audio_codec_ = audio_codec;
  audio_format_ = audio_format;

  texture_ = texture_registry_.CreateSurfaceTexture();
  if (!texture_.wnd) {
    ALOGE("MediaSessionGst failed to create surface texture");
    return false;
  }

  if (!CreatePipeline()) {
    Stop();
    return false;
  }

  GstStateChangeReturn ret = gst_element_set_state(pipeline_, GST_STATE_PLAYING);
  if (ret == GST_STATE_CHANGE_FAILURE) {
    ALOGE("MediaSessionGst failed to set PLAYING");
    Stop();
    return false;
  }

  return true;
}

SurfaceTexture MediaSessionGst::GetTexture() {
  return texture_;
}

void MediaSessionGst::Stop() {
  TeardownPipeline();

  if (texture_.wnd) {
    texture_registry_.ReleaseSurfaceTexture(texture_);
    texture_ = {};
  }
}

void MediaSessionGst::EnableAudio(bool enable) {
  audio_enabled_ = enable;
  ALOGI("MediaSessionGst::EnableAudio(%d)", enable);

  if (!audio_volume_) {
    ALOGW("MediaSessionGst::EnableAudio skipped because audio_volume_ is null");
    return;
  }

  g_object_set(audio_volume_, "mute", !enable, NULL);
}

void MediaSessionGst::OnAudioFrame(
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  if (!frame) {
    return;
  }

  ++audio_frame_count_;
  if (audio_frame_count_ == 1 || (audio_frame_count_ % 300) == 0) {
    ALOGI(
        "MediaSessionGst audio frame #%llu size=%zu pts_us=%llu enabled=%d",
        static_cast<unsigned long long>(audio_frame_count_),
        frame->size(),
        static_cast<unsigned long long>(timestamp_us),
        audio_enabled_);
  }

  if (PushAudioBuffer(frame->data(), frame->size(), timestamp_us)) {
    UpdateAudioClock(timestamp_us);
  } else {
    ++audio_push_fail_count_;
    ALOGW(
        "MediaSessionGst failed to push audio buffer count=%llu size=%zu pts_us=%llu",
        static_cast<unsigned long long>(audio_push_fail_count_),
        frame->size(),
        static_cast<unsigned long long>(timestamp_us));
  }
}

void MediaSessionGst::OnVideoFrame(
    bool key_frame,
    std::shared_ptr<std::vector<uint8_t>> frame,
    uint64_t timestamp_us) {
  if (!frame) {
    return;
  }

  // Compare the incoming video PTS against the current audio clock.
  // 比對目前 video PTS 與 audio clock 的差值。
  //
  // lead_us > 0: video is ahead of audio.
  // lead_us > 0：video 比 audio 快，畫面太早。
  //
  // lead_us < 0: video is behind audio.
  // lead_us < 0：video 比 audio 慢，畫面太晚。
  if (auto lead_us = GetVideoLeadUs(timestamp_us); lead_us.has_value()) {
    // 如果 video 已經落後太多，直接丟幀追進度。
    if (*lead_us < -kVideoLateDropThresholdUs) {
      ++video_drop_count_;
      if (video_drop_count_ == 1 || (video_drop_count_ % 60) == 0) {
        ALOGW(
            "MediaSessionGst dropping video frame count=%llu pts_us=%llu lead_us=%lld",
            static_cast<unsigned long long>(video_drop_count_),
            static_cast<unsigned long long>(timestamp_us),
            static_cast<long long>(*lead_us));
      }
      return;
    }

    // If video is too far ahead of audio, wait briefly before decoding.
    if (*lead_us > kVideoLeadWaitThresholdUs) {
      int64_t sleep_us = std::min(*lead_us - kVideoLeadWaitThresholdUs, kVideoLeadMaxSleepUs);
      std::this_thread::sleep_for(std::chrono::microseconds(sleep_us));
    }
  }

  std::lock_guard<std::mutex> lock(video_decoder_mutex_);
  if (!EnsureVideoDecoderLocked(frame->data(), frame->size(), key_frame)) {
    return;
  }
  awaiting_key_frame_ = false;

  if (!video_decoder_->Decode(frame->data(), frame->size(), timestamp_us)) {
    ALOGW("MediaSessionGst video decoder decode failed");
  }
}

bool MediaSessionGst::CreatePipeline() {
  pipeline_ = gst_pipeline_new("media_session_gst");
  if (!pipeline_) {
    ALOGE("MediaSessionGst failed to create pipeline");
    return false;
  }

  return CreateAudioBranch();
}

bool MediaSessionGst::CreateAudioBranch() {
  audio_appsrc_ = gst_element_factory_make("appsrc", "audio_appsrc");
  audio_convert_ = gst_element_factory_make("audioconvert", "audio_convert");
  audio_resample_ = gst_element_factory_make("audioresample", "audio_resample");
  audio_volume_ = gst_element_factory_make("volume", "audio_volume");
  audio_sink_ = gst_element_factory_make("openslessink", "audio_sink");

  switch (audio_codec_) {
    case AudioCodecType::kAac:
      audio_parser_ = gst_element_factory_make("aacparse", "audio_parser");
      audio_decoder_elem_ =
          gst_element_factory_make("avdec_aac", "audio_decoder");
      break;
    case AudioCodecType::kOpus:
      audio_parser_ = gst_element_factory_make("opusparse", "audio_parser");
      audio_decoder_elem_ =
          gst_element_factory_make("opusdec", "audio_decoder");
      break;
  }

  if (!audio_appsrc_ || !audio_parser_ || !audio_decoder_elem_ ||
      !audio_convert_ || !audio_resample_ || !audio_volume_ || !audio_sink_) {
    ALOGE("MediaSessionGst failed to create audio elements");
    return false;
  }

  gst_bin_add_many(
      GST_BIN(pipeline_),
      audio_appsrc_,
      audio_parser_,
      audio_decoder_elem_,
      audio_convert_,
      audio_resample_,
      audio_volume_,
      audio_sink_,
      NULL);

  if (!gst_element_link_many(
          audio_appsrc_,
          audio_parser_,
          audio_decoder_elem_,
          audio_convert_,
          audio_resample_,
          audio_volume_,
          audio_sink_,
          NULL)) {
    ALOGE("MediaSessionGst failed to link audio branch");
    return false;
  }

  g_object_set(
      audio_appsrc_,
      "is-live", TRUE,
      "format", GST_FORMAT_TIME,
      "do-timestamp", FALSE,
      "block", FALSE,
      NULL);

  GstCaps* caps = gst_caps_from_string(GetAudioCaps(audio_codec_, audio_format_));
  gst_app_src_set_caps(GST_APP_SRC(audio_appsrc_), caps);
  gst_caps_unref(caps);

  g_object_set(audio_volume_, "mute", TRUE, NULL);
  g_object_set(audio_sink_, "sync", FALSE, "async", FALSE, NULL);

  ALOGI(
      "MediaSessionGst audio branch created codec=%d sample_rate=%u channels=%u adts=%d mute_default=1",
      static_cast<int>(audio_codec_),
      audio_format_.sample_rate,
      audio_format_.channel_count,
      audio_format_.has_adts);

  return true;
}

void MediaSessionGst::TeardownPipeline() {
  {
    std::lock_guard<std::mutex> clock_lock(audio_clock_mutex_);
    have_audio_clock_ = false;
    last_audio_pts_us_ = 0;
    last_audio_clock_at_ = {};
  }

  {
    std::lock_guard<std::mutex> lock(video_decoder_mutex_);
    ResetVideoDecoderLocked();
  }

  if (pipeline_) {
    gst_element_set_state(pipeline_, GST_STATE_NULL);
    gst_object_unref(pipeline_);
    pipeline_ = nullptr;
  }

  audio_appsrc_ = nullptr;
  audio_parser_ = nullptr;
  audio_decoder_elem_ = nullptr;
  audio_convert_ = nullptr;
  audio_resample_ = nullptr;
  audio_volume_ = nullptr;
  audio_sink_ = nullptr;
}

bool MediaSessionGst::PushAudioBuffer(
    const uint8_t* data,
    size_t size,
    uint64_t timestamp_us) {
  if (!audio_appsrc_ || !data || size == 0) {
    return false;
  }

  GstBuffer* buffer = gst_buffer_new_allocate(NULL, size, NULL);
  if (!buffer) {
    return false;
  }

  gst_buffer_fill(buffer, 0, data, size);
  GST_BUFFER_PTS(buffer) = timestamp_us * kNsPerUs;
  GST_BUFFER_DTS(buffer) = timestamp_us * kNsPerUs;

  GstFlowReturn ret = gst_app_src_push_buffer(GST_APP_SRC(audio_appsrc_), buffer);
  return ret == GST_FLOW_OK;
}

bool MediaSessionGst::EnsureVideoDecoderLocked(
    const uint8_t* frame,
    size_t size,
    bool key_frame) {
  if (video_decoder_failed_ && key_frame) {
    video_decoder_failed_ = false;
  }

  if (frame && size > 0) {
    auto csd = ParseVideoCsd(
        video_codec_,
        std::span<const uint8_t>(frame, size));

    if (csd.has_value()) {
      bool size_changed = !csd_.has_value() ||
                          csd->width != csd_->width ||
                          csd->height != csd_->height;
      if (size_changed) {
        ALOGI("The video size has changed to %ux%u",
              csd->width,
              csd->height);
        csd_ = csd;
        video_decoder_failed_ = false;
        ResetVideoDecoderLocked();
      } else if (!csd_.has_value()) {
        csd_ = csd;
      }
    }
  }

  if (video_decoder_) {
    return true;
  }

  if (video_decoder_failed_ || !csd_.has_value() || !texture_.wnd) {
    return false;
  }

  bool attempts[2];
  size_t attempt_count = 0;

  if (decoder_use_software_) {
    attempts[attempt_count++] = true;
  } else {
    attempts[attempt_count++] = false;
    attempts[attempt_count++] = true;
  }

  for (size_t i = 0; i < attempt_count; ++i) {
    bool use_software = attempts[i];

    auto decoder = CreateVideoDecoder(
        video_codec_,
        use_software,
        *csd_,
        additional_codec_params_,
        texture_.wnd,
        this);

    if (!decoder) {
      continue;
    }

    if (!decoder->Start()) {
      decoder->Stop();
      continue;
    }

    video_decoder_ = std::move(decoder);
    decoder_use_software_ = use_software;
    video_decoder_failed_ = false;
    return true;
  }

  video_decoder_failed_ = true;
  return false;
}

void MediaSessionGst::ResetVideoDecoderLocked() {
  if (video_decoder_) {
    video_decoder_->Stop();
    video_decoder_.reset();
  }

  decoder_use_software_ = false;
  awaiting_key_frame_ = true;
}

void MediaSessionGst::UpdateAudioClock(uint64_t timestamp_us) {
  std::lock_guard<std::mutex> lock(audio_clock_mutex_);
  have_audio_clock_ = true;
  last_audio_pts_us_ = timestamp_us;
  last_audio_clock_at_ = std::chrono::steady_clock::now();
}

std::optional<int64_t> MediaSessionGst::GetVideoLeadUs(uint64_t video_pts_us) {
  std::lock_guard<std::mutex> lock(audio_clock_mutex_);
  if (!have_audio_clock_) {
    return std::nullopt;
  }

  auto elapsed_us = std::chrono::duration_cast<std::chrono::microseconds>(
                        std::chrono::steady_clock::now() - last_audio_clock_at_)
                        .count();
  uint64_t audio_clock_us = last_audio_pts_us_ + std::max<int64_t>(elapsed_us, 0);
  return static_cast<int64_t>(video_pts_us) - static_cast<int64_t>(audio_clock_us);
}

void MediaSessionGst::OnVideoFormatChanged(int width, int height) {
  if (listener_) {
    listener_->OnVideoFormatChanged(width, height);
  }
}

void MediaSessionGst::OnVideoFrameRate(int fps) {
  if (listener_) {
    listener_->OnVideoFrameRate(fps);
  }
}
