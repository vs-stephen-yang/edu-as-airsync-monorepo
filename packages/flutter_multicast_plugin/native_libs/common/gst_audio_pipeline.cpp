#include "gst_audio_pipeline.h"
#include "gst_util.h"
#include "log.h"
#include <algorithm> // 用於 std::sort, std::min, std::max
#include <cstring>   // 用於 memcpy, strcat
#include <gst/app/gstappsink.h>
#include <gst/app/gstappsrc.h>
#include <gst/video/videooverlay.h>
#include <iostream>
#include <map> // 用於 std::map
#include <mutex>
#include <string> // 用於 std::string
#include <vector> // 用於 std::vector
#ifdef PLATFORM_IOS
#include "gst_ios_init.h"
#endif

bool is_silence_frame(const std::vector<uint8_t>& opus_data) {
    // 靜音幀通常很小 (3-10 bytes)
    if (opus_data.size() <= 10) {
        ALOGI("Small frame detected: %zu bytes", opus_data.size());
        return true;
    }

    return false;
}

GstAudioPipeline::GstAudioPipeline() {}

GstAudioPipeline::~GstAudioPipeline() {
    stop();
}

bool GstAudioPipeline::init() {
#ifdef PLATFORM_IOS
    gst_ios_init();
#else
    gst_init(nullptr, nullptr);
#endif

#ifdef PLATFORM_IOS
    const char* desc = "appsrc name=appsrc is-live=true format=time stream-type=stream caps=audio/x-opus,rate=48000,channels=1,channel-mapping-family=0 ! "
                       "queue name=decode_queue max-size-buffers=20 leaky=2 ! "
                       "opusdec name=opusdec ! "
                       "queue name=audio_buffer max-size-buffers=10 max-size-time=200000000 leaky=1 ! "
                       "audioconvert name=audioconvert ! "
                       "osxaudiosink sync=false async=false";
#elif defined(PLATFORM_MACOS)
    const char* desc = "appsrc name=appsrc is-live=true format=time stream-type=stream caps=audio/x-opus,rate=48000,channels=1,channel-mapping-family=0 ! "
                       "queue name=decode_queue max-size-buffers=20 leaky=2 ! "
                       "opusdec name=opusdec ! "
                       "queue name=audio_buffer max-size-buffers=10 max-size-time=200000000 leaky=1 ! "
                       "audioconvert name=audioconvert ! "
                       "osxaudiosink sync=false async=false";
#else
    const char* desc = "appsrc name=appsrc is-live=true format=time stream-type=stream "
                       "caps=audio/x-opus,rate=48000,channels=1,channel-mapping-family=0 ! "
                       "queue name=decode_queue max-size-buffers=10 max-size-time=200000000 leaky=2 ! "
                       "opusdec name=opusdec ! "
                       "queue name=audio_buffer max-size-buffers=15 max-size-time=300000000 leaky=1 ! "
                       "audioconvert name=audioconvert ! "
                       "autoaudiosink name=audiosink sync=false";
#endif

    gst_debug_set_default_threshold(GST_LEVEL_WARNING);
    gst_debug_set_threshold_for_name("appsrc", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("appsink", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("opusdec", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("audioconvert", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("GST_CAPS", GST_LEVEL_LOG);

    GError* error = nullptr;
    pipeline_ = gst_parse_launch(desc, &error);
    if (!pipeline_) {
        ALOGE("Failed to create pipeline: %s", error ? error->message : "Unknown");
        if (error)
            g_clear_error(&error);
        return false;
    }

    gst_element_set_state(pipeline_, GST_STATE_NULL);

    // register bus handler
    GstBus* bus = gst_pipeline_get_bus(GST_PIPELINE(pipeline_));
    gst_bus_set_sync_handler(bus, (GstBusSyncHandler)bus_sync_handler, this, nullptr);
    gst_object_unref(bus);

    ALOGI("Setting pipeline to READY state...");
    GstStateChangeReturn ret = gst_element_set_state(pipeline_, GST_STATE_READY);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        ALOGE("Failed to set pipeline to READY state");
        return false;
    }

    if (ret == GST_STATE_CHANGE_ASYNC) {
        GstState current, pending;
        ret = gst_element_get_state(pipeline_, &current, &pending, 5 * GST_SECOND);
        if (ret == GST_STATE_CHANGE_FAILURE) {
            ALOGE("Pipeline failed to reach READY state within timeout");
            return false;
        }
        ALOGI("Pipeline reached READY state: current=%d, pending=%d", current, pending);
    }

    // 現在再獲取 appsrc
    appsrc_ = gst_bin_get_by_name(GST_BIN(pipeline_), "appsrc");
    if (!appsrc_) {
        ALOGI("Failed to get appsrc from pipeline");
        return false;
    }

    ALOGI("Successfully got appsrc: %p", appsrc_);

    const char* elements_to_probe[] = {"appsrc", "opusdec", "identity", "audioconvert"};

    for (const char* name : elements_to_probe) {
        GstElement* elem = gst_bin_get_by_name(GST_BIN(pipeline_), name);
        if (elem) {
            GstPad* srcpad = gst_element_get_static_pad(elem, "src");
            if (srcpad) {
                gst_pad_add_probe(srcpad, GST_PAD_PROBE_TYPE_BUFFER, enhanced_probe_callback, (gpointer)name, nullptr);
                ALOGI("Added probe to %s", name);
                gst_object_unref(srcpad);
            }
            gst_object_unref(elem);
        } else {
            ALOGI("Element not found: %s", name);
        }
    }

    ALOGI("Setting pipeline to PAUSED state...");
    ret = gst_element_set_state(pipeline_, GST_STATE_PAUSED);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        ALOGE("Failed to set pipeline to PAUSED state");
        return false;
    }
    if (ret == GST_STATE_CHANGE_ASYNC) {
        GstState current, pending;
        ret = gst_element_get_state(pipeline_, &current, &pending, 5 * GST_SECOND);
        if (ret == GST_STATE_CHANGE_FAILURE) {
            ALOGE("Pipeline failed to reach PAUSED state within timeout");
            return false;
        }
        ALOGI("Pipeline reached PAUSED state: current=%d, pending=%d", current, pending);
    }

    ALOGI("Setting pipeline to PLAYING state...");
    ret = gst_element_set_state(pipeline_, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        ALOGE("Failed to set pipeline to PLAYING state");
        return false;
    }

    ALOGI("Pipeline successfully initialized and playing");

    return true;
}

void GstAudioPipeline::push_opus_frame(const std::vector<uint8_t>& opus_data) {
    std::lock_guard<std::mutex> lock(pipeline_mutex_);

    if (!pipeline_ || !appsrc_) {
        ALOGW("[push_au] Skip: pipeline or appsrc is not ready");
        return;
    }

    // 檢查 appsrc 狀態
    GstState state;
    gst_element_get_state(appsrc_, &state, NULL, 0);
    if (state < GST_STATE_PLAYING) {
        ALOGW("[push_au] Skip: appsrc state is %d, not PLAYING", state);
        return;
    }

    static const GstClockTime frame_duration = 20 * GST_MSECOND; // OPUS 20ms frame
    static int frame_count = 0;

    frame_count++;

    if (!first_audio_received_) {
        if (is_silence_frame(opus_data)) {
            ALOGD("[push_opus] Dropping silence frame #%d", frame_count);
            return;
        } else {
            first_audio_received_ = true;

            timestamp_ = sync_to_pipeline_time_();
        }
    }

    // 檢測中斷並決定是否重新同步
    if (should_resync_timestamp_()) {
        timestamp_ = sync_to_pipeline_time_();
    }

    ALOGD("[push_opus] Attempting to push OPUS frame size: %zu", opus_data.size());

    // 創建 buffer
    GstBuffer* buffer = gst_buffer_new_allocate(NULL, opus_data.size(), NULL);
    if (!buffer) {
        ALOGE("[push_opus] ERROR: Failed to allocate buffer!");
        return;
    }

    // 映射和複製數據
    GstMapInfo map;
    if (!gst_buffer_map(buffer, &map, GST_MAP_WRITE)) {
        ALOGE("[push_opus] ERROR: Failed to map buffer!");
        gst_buffer_unref(buffer);
        return;
    }

    memcpy(map.data, opus_data.data(), opus_data.size());
    gst_buffer_unmap(buffer, &map);

    GST_BUFFER_PTS(buffer) = timestamp_;
    GST_BUFFER_DTS(buffer) = timestamp_;
    GST_BUFFER_DURATION(buffer) = frame_duration;

    ALOGD("[push_opus] Using timestamp: %.3f sec", (double)timestamp_ / GST_SECOND);

    timestamp_ += frame_duration;

    // 推送 buffer
    GstFlowReturn ret = gst_app_src_push_buffer(GST_APP_SRC(appsrc_), buffer);
    ALOGD("[push_opus] Push result: %d (%s)", ret, gst_flow_get_name(ret));

    if (ret != GST_FLOW_OK) {
        ALOGE("[push_opus] ERROR: Push failed with: %s", gst_flow_get_name(ret));
    }
}

bool GstAudioPipeline::should_resync_timestamp_() {
    // 定期檢查 timestamp 是否與 pipeline 時間差距過大
    GstClock* clock = gst_pipeline_get_clock(GST_PIPELINE(pipeline_));
    if (clock) {
        GstClockTime pipeline_time = gst_clock_get_time(clock) - gst_element_get_base_time(pipeline_);
        GstClockTime diff = std::abs((int64_t)pipeline_time - (int64_t)timestamp_);

        gst_object_unref(clock);

        if (diff > 500 * GST_MSECOND) {
            return true;
        }
    }
    return false;
}

GstClockTime GstAudioPipeline::sync_to_pipeline_time_() {
    GstClock* clock = gst_pipeline_get_clock(GST_PIPELINE(pipeline_));
    if (clock) {
        GstClockTime current_time = gst_clock_get_time(clock);
        GstClockTime base_time = gst_element_get_base_time(pipeline_);
        timestamp_ = current_time - base_time;
        gst_object_unref(clock);
        ALOGI("[push_opus] *** SYNC TO PIPELINE: %.3f sec ***", (double)timestamp_ / GST_SECOND);
    }
    return timestamp_;
}

void GstAudioPipeline::stop() {
    if (pipeline_) {
        gst_element_set_state(pipeline_, GST_STATE_NULL);
        gst_object_unref(pipeline_);
        pipeline_ = nullptr;
    }
    appsrc_ = nullptr;
}

void GstAudioPipeline::on_pipeline_error() {
    std::lock_guard<std::mutex> lock(pipeline_mutex_);

    ALOGE("[Audio] Pipeline error received — restarting...");
    stop();
    init();
}