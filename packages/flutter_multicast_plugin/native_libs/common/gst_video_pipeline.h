#pragma once

#include <gst/app/gstappsrc.h>
#include <gst/gst.h>
#include <vector>

class GstVideoPipeline {
  public:
    GstVideoPipeline();
    ~GstVideoPipeline();

    // window_handle: ANativeWindow* on Android, UIView* on iOS (cast to void*)
    bool init(void* window_handle);
    void push_au(const std::vector<uint8_t>& au);
    void stop();

  private:
    GstElement* pipeline_ = nullptr;
    GstElement* appsrc_ = nullptr;
};
