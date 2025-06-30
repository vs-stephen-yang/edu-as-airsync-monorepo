#pragma once

#include <gst/app/gstappsrc.h>
#include <gst/gst.h>
#include <vector>

class GstAudioPipeline {
  public:
    GstAudioPipeline();
    ~GstAudioPipeline();

    bool init();
    void push_opus_frame(const std::vector<uint8_t>& opus_data);
    void stop();

  private:
    GstElement* pipeline_ = nullptr;
    GstElement* appsrc_ = nullptr;
};
