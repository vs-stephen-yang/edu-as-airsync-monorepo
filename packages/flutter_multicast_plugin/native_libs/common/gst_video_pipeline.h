#pragma once

#include "gst_pipeline_observer.h"
#include <gst/app/gstappsrc.h>
#include <gst/gst.h>
#include <mutex>
#include <vector>
#ifdef __ANDROID__
#include <android/native_window.h>
#endif

class GstVideoPipeline : public GstPipelineObserver {
  public:
    GstVideoPipeline();
    ~GstVideoPipeline();

    // window_handle: ANativeWindow* on Android, UIView* on iOS (cast to void*)
    bool init(void* window_handle);
    void push_au(const std::vector<uint8_t>& au);
    void stop();
    void pause();
    void reinitialize(void* window_handle);
    void on_pipeline_error() override;

  private:
    GstElement* pipeline_ = nullptr;
    GstElement* appsrc_ = nullptr;
    std::mutex pipeline_mutex_;
#ifdef __ANDROID__
    ANativeWindow* window_handle_ = nullptr;
#endif
    std::atomic<bool> is_paused_{false};
    std::atomic<bool> is_reinitializing_{false};

    void release_window_handle_();
};
