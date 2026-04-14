#pragma once

#include "gst_pipeline_observer.h"
#include <gst/app/gstappsrc.h>
#include <gst/gst.h>
#include <mutex>
#include <vector>

class GstAudioPipeline : public GstPipelineObserver {
  public:
    GstAudioPipeline();
    ~GstAudioPipeline();

    bool init();
    void push_opus_frame(const std::vector<uint8_t>& opus_data);
    void stop();

    void on_pipeline_error() override;

  private:
    GstElement* pipeline_ = nullptr;
    GstElement* appsrc_ = nullptr;
    std::mutex pipeline_mutex_;
    bool first_audio_received_ = false;
    GstClockTime timestamp_ = 0;
    GstClockTime sync_to_pipeline_time_();
    bool should_resync_timestamp_();
};
