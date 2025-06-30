#include "gst_audio_pipeline.h"
#include "log.h"
#include <algorithm> // 用於 std::sort, std::min, std::max
#include <cstring>   // 用於 memcpy, strcat
#include <gst/app/gstappsink.h>
#include <gst/app/gstappsrc.h>
#include <gst/video/videooverlay.h>
#include <iostream>
#include <map>    // 用於 std::map
#include <string> // 用於 std::string
#include <vector> // 用於 std::vector
#ifdef __APPLE__
#include "gst_ios_init.h"
#endif

GstAudioPipeline::GstAudioPipeline() {}

GstAudioPipeline::~GstAudioPipeline() {
    stop();
}

static GstPadProbeReturn enhanced_probe_callback(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
    const char* element_name = (const char*)user_data;

    if (info->type & GST_PAD_PROBE_TYPE_BUFFER) {
        GstBuffer* buffer = GST_PAD_PROBE_INFO_BUFFER(info);
        GstMapInfo map;

        if (gst_buffer_map(buffer, &map, GST_MAP_READ)) {
            // 計算時間戳（秒）
            gdouble pts_seconds = (gdouble)GST_BUFFER_PTS(buffer) / GST_SECOND;

            ALOGI("🔍 [PROBE] %s:", element_name);
            ALOGI("  📏 Size: %zu bytes", map.size);
            ALOGI("  ⏰ PTS: %.3f sec (raw: %" G_GUINT64_FORMAT ")", pts_seconds, GST_BUFFER_PTS(buffer));

            // 準備 Head 數據字符串 (前8個bytes)
            std::string head_str = "";
            for (gsize i = 0; i < 8 && i < map.size; i++) {
                char temp[8];
                snprintf(temp, sizeof(temp), "%02x ", map.data[i]);
                head_str += temp;
            }
            ALOGI("  🔢 Head: %s", head_str.c_str());

            // 如果數據夠長，顯示中間和結尾
            if (map.size >= 16) {
                // 中間8個bytes
                gsize mid = map.size / 2;
                std::string mid_str = "";
                for (gsize i = 0; i < 8 && (mid + i) < map.size; i++) {
                    char temp[8];
                    snprintf(temp, sizeof(temp), "%02x ", map.data[mid + i]);
                    mid_str += temp;
                }
                ALOGI("  🔢 Mid:  %s", mid_str.c_str());

                // 結尾8個bytes
                std::string tail_str = "";
                for (gsize i = 0; i < 8; i++) {
                    char temp[8];
                    snprintf(temp, sizeof(temp), "%02x ", map.data[map.size - 8 + i]);
                    tail_str += temp;
                }
                ALOGI("  🔢 Tail: %s", tail_str.c_str());
            }

            // 檢查是否為重複模式
            bool isRepeatingPattern = true;
            if (map.size > 8) {
                for (gsize i = 1; i < 8 && i < map.size; i++) {
                    if (map.data[i] != map.data[0]) {
                        isRepeatingPattern = false;
                        break;
                    }
                }
            }

            if (isRepeatingPattern && map.size > 8) {
                ALOGW("  ⚠️  WARNING: Repeating pattern detected!");
            }

            // 統計數據分佈
            int histogram[256] = {0};
            gsize sampleSize = std::min(map.size, (gsize)1000);
            for (gsize i = 0; i < sampleSize; i++) {
                histogram[map.data[i]]++;
            }

            // 找出最常見的字節值
            int maxCount = 0;
            int mostCommonByte = 0;
            for (int i = 0; i < 256; i++) {
                if (histogram[i] > maxCount) {
                    maxCount = histogram[i];
                    mostCommonByte = i;
                }
            }

            double dominance = (double)maxCount / sampleSize * 100.0;
            if (dominance > 90.0) {
                ALOGW("  ⚠️  Data highly uniform: 0x%02x appears %.1f%% of time", mostCommonByte, dominance);
            }

            gst_buffer_unmap(buffer, &map);
        }

        // 取得當前 caps 資訊
        GstCaps* caps = gst_pad_get_current_caps(pad);
        if (caps) {
            gchar* caps_str = gst_caps_to_string(caps);
            ALOGI("  📝 Caps: %s", caps_str);
            g_free(caps_str);
            gst_caps_unref(caps);
        }
    }

    return GST_PAD_PROBE_OK;
}

bool GstAudioPipeline::init() {
#ifdef __APPLE__
    gst_ios_init();
#else
    gst_init(nullptr, nullptr);
#endif

#ifdef __APPLE__
    const char* desc ='';
#else
    const char* desc =
        "appsrc name=appsrc is-live=true format=time stream-type=stream caps=audio/x-opus,rate=48000,channels=1,channel-mapping-family=0 ! "
        "opusdec name=opusdec ! identity name=identity ! audioconvert name=audioconvert ! autoaudiosink";
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

    // 檢查 bus 上的錯誤
    GstBus* bus = gst_pipeline_get_bus(GST_PIPELINE(pipeline_));
    GstMessage* msg;

    while ((msg = gst_bus_pop(bus)) != NULL) {
        switch (GST_MESSAGE_TYPE(msg)) {
            case GST_MESSAGE_ERROR: {
                GError* error;
                gchar* debug_info;
                gst_message_parse_error(msg, &error, &debug_info);
                ALOGE("GStreamer ERROR: %s", error->message);
                ALOGE("GStreamer DEBUG: %s", debug_info ? debug_info : "No debug info");
                g_error_free(error);
                g_free(debug_info);
                break;
            }
            case GST_MESSAGE_WARNING: {
                GError* warning;
                gchar* debug_info;
                gst_message_parse_warning(msg, &warning, &debug_info);
                ALOGW("GStreamer WARNING: %s", warning->message);
                ALOGW("GStreamer DEBUG: %s", debug_info ? debug_info : "No debug info");
                g_error_free(warning);
                g_free(debug_info);
                break;
            }
            default:
                break;
        }
        gst_message_unref(msg);
    }
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
    ALOGI("[push_opus] Attempting to push OPUS frame size: %zu", opus_data.size());

    // 創建 buffer
    GstBuffer* buffer = gst_buffer_new_allocate(NULL, opus_data.size(), NULL);
    if (!buffer) {
        ALOGI("[push_opus] ERROR: Failed to allocate buffer!");
        return;
    }

    // 映射和複製數據
    GstMapInfo map;
    if (!gst_buffer_map(buffer, &map, GST_MAP_WRITE)) {
        ALOGI("[push_opus] ERROR: Failed to map buffer!");
        gst_buffer_unref(buffer);
        return;
    }

    memcpy(map.data, opus_data.data(), opus_data.size());
    gst_buffer_unmap(buffer, &map);

    // 設置音頻時間戳
    static GstClockTime timestamp = 0;
    static const GstClockTime frame_duration = 20 * GST_MSECOND; // OPUS 20ms frame

    GST_BUFFER_PTS(buffer) = timestamp;
    GST_BUFFER_DTS(buffer) = timestamp;
    GST_BUFFER_DURATION(buffer) = frame_duration;

    timestamp += frame_duration;

    // 推送 buffer
    GstFlowReturn ret = gst_app_src_push_buffer(GST_APP_SRC(appsrc_), buffer);
    ALOGI("[push_opus] Push result: %d (%s)", ret, gst_flow_get_name(ret));

    if (ret != GST_FLOW_OK) {
        ALOGI("[push_opus] ERROR: Push failed with: %s", gst_flow_get_name(ret));
    }
}

void GstAudioPipeline::stop() {
    if (pipeline_) {
        gst_element_set_state(pipeline_, GST_STATE_NULL);
        gst_object_unref(pipeline_);
        pipeline_ = nullptr;
    }
    appsrc_ = nullptr;
}