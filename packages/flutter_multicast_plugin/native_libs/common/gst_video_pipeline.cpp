#include "gst_video_pipeline.h"
#include "gst_util.h"
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

// 宣告 C 介面函數
extern "C" {
void update_flutter_texture_from_cpp(const uint8_t* data, size_t width, size_t height, size_t stride);
}

struct PadAddedData {
    void* window_handle;
    // 可以加入其他需要的參數
};

GstVideoPipeline::GstVideoPipeline() {}

GstVideoPipeline::~GstVideoPipeline() {
    stop();
}

// 修改 appsink callback
static GstFlowReturn on_new_video_sample(GstElement* appsink, gpointer user_data) {
    GstSample* sample = gst_app_sink_pull_sample(GST_APP_SINK(appsink));
    if (!sample) {
        return GST_FLOW_OK;
    }

    GstBuffer* buffer = gst_sample_get_buffer(sample);
    GstCaps* caps = gst_sample_get_caps(sample);

    if (!buffer || !caps) {
        gst_sample_unref(sample);
        return GST_FLOW_OK;
    }

    // 取得影像資訊
    GstStructure* structure = gst_caps_get_structure(caps, 0);
    gint width, height;
    if (!gst_structure_get_int(structure, "width", &width) ||
        !gst_structure_get_int(structure, "height", &height)) {
        ALOGE("Failed to get video dimensions");
        gst_sample_unref(sample);
        return GST_FLOW_OK;
    }

    // 映射 buffer 資料
    GstMapInfo map;
    if (gst_buffer_map(buffer, &map, GST_MAP_READ)) {
        // 計算 stride
        size_t stride = width * 4; // BGRA = 4 bytes per pixel

        ALOGI("📹 Updating Flutter texture: %dx%d, stride=%zu, size=%zu",
              width, height, stride, map.size);

        // 呼叫新的 C 函數更新 texture
        update_flutter_texture_from_cpp(map.data, width, height, stride);

        gst_buffer_unmap(buffer, &map);
    }

    gst_sample_unref(sample);
    return GST_FLOW_OK;
}

static void decodebin_pad_added_cb(GstElement* decodebin, GstPad* new_pad, gpointer user_data) {
    GstElement* pipe = GST_ELEMENT(gst_element_get_parent(decodebin));

    ALOGI("[PAD_ADDED] New pad from decodebin");

    // 檢查是否為視頻流
    GstCaps* caps = gst_pad_get_current_caps(new_pad);
    if (!caps) {
        caps = gst_pad_query_caps(new_pad, NULL);
    }

    if (caps) {
        gchar* caps_str = gst_caps_to_string(caps);
        ALOGI("[PAD_ADDED] Pad caps: %s", caps_str);
        g_free(caps_str);

        GstStructure* structure = gst_caps_get_structure(caps, 0);
        const gchar* media_type = gst_structure_get_name(structure);

        if (!g_str_has_prefix(media_type, "video/")) {
            ALOGI("[PAD_ADDED] Not a video pad, ignoring");
            gst_caps_unref(caps);
            gst_object_unref(pipe);
            return;
        }
        gst_caps_unref(caps);
    }

    // 檢查是否已經建立視頻鏈
    GstElement* existing_glsink = gst_bin_get_by_name(GST_BIN(pipe), "glsink");
    if (existing_glsink) {
        ALOGI("[PAD_ADDED] Video chain already exists, ignoring");
        gst_object_unref(existing_glsink);
        gst_object_unref(pipe);
        return;
    }

    // 創建元素
    GstElement* videoconvert = gst_element_factory_make("videoconvert", "videoconvert");
    GstElement* capsfilter = gst_element_factory_make("capsfilter", "capsfilter");
    GstElement* glsink = gst_element_factory_make("glimagesink", "glsink");

    if (!videoconvert || !capsfilter || !glsink || !pipe) {
        ALOGE("[PAD_ADDED] Failed to create required elements");
        if (videoconvert)
            gst_object_unref(videoconvert);
        if (capsfilter)
            gst_object_unref(capsfilter);
        if (glsink)
            gst_object_unref(glsink);
        gst_object_unref(pipe);
        return;
    }

#ifdef __ANDROID__
    PadAddedData* pad_data = static_cast<PadAddedData*>(user_data);
    if (pad_data && pad_data->window_handle) {
        // Android: 設定 window handle
        gst_video_overlay_set_window_handle(
            GST_VIDEO_OVERLAY(glsink),
            (guintptr)pad_data->window_handle);
        ALOGI("Set Android window handle for glimagesink");
    }
#endif

    ALOGI("[PAD_ADDED] Created videoconvert, capsfilter, and glsink");

    // 設定 RGBA 格式 caps
    GstCaps* rgba_caps = gst_caps_new_simple("video/x-raw",
                                             "format", G_TYPE_STRING, "RGBA",
                                             NULL);
    g_object_set(G_OBJECT(capsfilter), "caps", rgba_caps, NULL);
    gst_caps_unref(rgba_caps);

    // 配置 glimagesink（iOS 特定設置）
    g_object_set(G_OBJECT(glsink),
                 "sync", FALSE,
                 "async", FALSE,
                 "enable-last-sample", FALSE,
                 NULL);
    ALOGI("[PAD_ADDED] Configured elements");

    // 獲取 pipeline 當前狀態（在添加元素之前）
    GstState current_state, pending_state;
    gst_element_get_state(pipe, &current_state, &pending_state, 0);
    ALOGI("[PAD_ADDED] Pipeline current state: %s", gst_element_state_get_name(current_state));

    // 添加元素到 pipeline
    // 先用 gst_bin_add_many 添加 videoconvert 和 capsfilter（已知可以工作）
    gst_bin_add_many(GST_BIN(pipe), videoconvert, capsfilter, NULL);
    ALOGI("[PAD_ADDED] Added videoconvert and capsfilter using gst_bin_add_many");

    // 單獨添加 glimagesink（避免在 gst_bin_add_many 中的問題）
    if (!gst_bin_add(GST_BIN(pipe), glsink)) {
        ALOGE("[PAD_ADDED] Failed to add glsink to pipeline");
        gst_object_unref(glsink);
        gst_object_unref(pipe);
        return;
    }
    ALOGI("[PAD_ADDED] Added glsink separately");

    // 關鍵：正確的狀態設置順序
    if (current_state >= GST_STATE_READY) {
        ALOGI("[PAD_ADDED] Setting new elements to READY state...");

        // 設置 videoconvert 到 READY
        GstStateChangeReturn ret1 = gst_element_set_state(videoconvert, GST_STATE_READY);
        if (ret1 == GST_STATE_CHANGE_FAILURE) {
            ALOGE("[PAD_ADDED] Failed to set videoconvert to READY");
            gst_object_unref(pipe);
            return;
        }

        // 設置 capsfilter 到 READY
        GstStateChangeReturn ret2 = gst_element_set_state(capsfilter, GST_STATE_READY);
        if (ret2 == GST_STATE_CHANGE_FAILURE) {
            ALOGE("[PAD_ADDED] Failed to set capsfilter to READY");
            gst_object_unref(pipe);
            return;
        }

        // 重要：設置 glsink 到 READY（這步是必需的！）
        GstStateChangeReturn ret3 = gst_element_set_state(glsink, GST_STATE_READY);
        if (ret3 == GST_STATE_CHANGE_FAILURE) {
            ALOGE("[PAD_ADDED] Failed to set glsink to READY");
            gst_object_unref(pipe);
            return;
        }

        ALOGI("[PAD_ADDED] ✅ All elements set to READY: vc=%d, cf=%d, gs=%d", ret1, ret2, ret3);
    }

    // 同步所有元素狀態到 pipeline
    gst_element_sync_state_with_parent(videoconvert);
    gst_element_sync_state_with_parent(capsfilter);
    gst_element_sync_state_with_parent(glsink);
    ALOGI("[PAD_ADDED] Synced all elements with parent");

    // 連接元素鏈
    // decodebin pad → videoconvert:sink
    GstPad* convert_sinkpad = gst_element_get_static_pad(videoconvert, "sink");
    if (!convert_sinkpad) {
        ALOGE("[PAD_ADDED] Failed to get videoconvert sink pad");
        gst_object_unref(pipe);
        return;
    }

    GstPadLinkReturn ret = gst_pad_link(new_pad, convert_sinkpad);
    gst_object_unref(convert_sinkpad);

    if (GST_PAD_LINK_FAILED(ret)) {
        ALOGE("[PAD_ADDED] Failed to link decodebin pad to videoconvert: %d", ret);
        gst_object_unref(pipe);
        return;
    }
    ALOGI("[PAD_ADDED] ✅ Linked decodebin → videoconvert");

    // videoconvert → capsfilter
    if (!gst_element_link(videoconvert, capsfilter)) {
        ALOGE("[PAD_ADDED] Failed to link videoconvert to capsfilter");
        gst_object_unref(pipe);
        return;
    }
    ALOGI("[PAD_ADDED] ✅ Linked videoconvert → capsfilter");

    // capsfilter → glimagesink
    GstPad* glsink_pad = gst_element_get_static_pad(glsink, "sink");
    if (!glsink_pad) {
        ALOGE("[PAD_ADDED] glimagesink sink pad not available");
        gst_object_unref(pipe);
        return;
    }

    GstPad* filter_srcpad = gst_element_get_static_pad(capsfilter, "src");
    if (!filter_srcpad) {
        ALOGE("[PAD_ADDED] capsfilter src pad not available");
        gst_object_unref(glsink_pad);
        gst_object_unref(pipe);
        return;
    }

    ret = gst_pad_link(filter_srcpad, glsink_pad);
    gst_object_unref(filter_srcpad);
    gst_object_unref(glsink_pad);

    if (GST_PAD_LINK_FAILED(ret)) {
        ALOGE("[PAD_ADDED] Failed to link capsfilter to glimagesink: %d", ret);
        gst_object_unref(pipe);
        return;
    }
    ALOGI("[PAD_ADDED] ✅ Linked capsfilter → glimagesink");

    // 如果 pipeline 正在播放，確保新元素也進入播放狀態
    if (current_state == GST_STATE_PLAYING) {
        ALOGI("[PAD_ADDED] Pipeline is playing, setting new elements to PLAYING...");
        gst_element_set_state(videoconvert, GST_STATE_PLAYING);
        gst_element_set_state(capsfilter, GST_STATE_PLAYING);
        gst_element_set_state(glsink, GST_STATE_PLAYING);
        ALOGI("[PAD_ADDED] ✅ New elements set to PLAYING");
    }

    // 添加 probe 來監控數據流
    gst_pad_add_probe(new_pad, GST_PAD_PROBE_TYPE_BUFFER,
                      enhanced_probe_callback, (gpointer) "decodebin_output", nullptr);

    GstPad* convert_srcpad = gst_element_get_static_pad(videoconvert, "src");
    if (convert_srcpad) {
        gst_pad_add_probe(convert_srcpad, GST_PAD_PROBE_TYPE_BUFFER,
                          enhanced_probe_callback, (gpointer) "videoconvert_output", nullptr);
        gst_object_unref(convert_srcpad);
    }
    ALOGI("[PAD_ADDED] Added probes for monitoring");

    // 記錄實際使用的解碼器
    GstElement* actual_decoder = gst_pad_get_parent_element(new_pad);
    if (actual_decoder) {
        gchar* decoder_name = gst_element_get_name(actual_decoder);
        const gchar* factory_name = gst_plugin_feature_get_name(
            GST_PLUGIN_FEATURE(gst_element_get_factory(actual_decoder)));
        ALOGI("[PAD_ADDED] 🎯 Actual decoder used: %s (factory: %s)", decoder_name, factory_name);
        g_free(decoder_name);
        gst_object_unref(actual_decoder);
    }

    ALOGI("[PAD_ADDED] 🎉 COMPLETE: decodebin → videoconvert → capsfilter(RGBA) → glimagesink");
    ALOGI("[PAD_ADDED] 📱 iOS video should now be visible!");

    gst_object_unref(pipe);
}

bool GstVideoPipeline::init(void* window_handle) {
#ifdef __APPLE__
    gst_ios_init();
#else
    gst_init(nullptr, nullptr);
#endif

#ifdef __APPLE__
    const char* desc =
        "appsrc name=mysrc is-live=true format=time caps=video/x-h264,stream-format=byte-stream,alignment=au ! "
        "h264parse name=h264parse config-interval=-1 ! "
        "queue name=decode_queue max-size-buffers=5 max-size-time=167000000 leaky=2 ! "
        "avdec_h264 name=avdec_h264 ! "
        "videoconvert name=videoconvert ! "
        "video/x-raw,format=BGRA ! "
        "queue name=sink_queue max-size-buffers=2 max-size-time=67000000 leaky=2 ! "
        "appsink name=videosink emit-signals=true sync=false async=false max-buffers=1 drop=true";
#else
    const char* desc =
        "appsrc name=mysrc is-live=true format=time caps=video/x-h264,stream-format=byte-stream,alignment=au ! "
        "h264parse name=h264parse ! "
        "queue name=decode_queue max-size-buffers=5 max-size-time=167000000 leaky=2 ! "
        "decodebin name=decodebin";
#endif

    gst_debug_set_default_threshold(GST_LEVEL_WARNING);
    gst_debug_set_threshold_for_name("mysrc", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("h264parse", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("avdec_h264", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("decodebin", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("videoconvert", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("appsink", GST_LEVEL_LOG);
    gst_debug_set_threshold_for_name("GST_CAPS", GST_LEVEL_LOG);

    GError* error = nullptr;
    pipeline_ = gst_parse_launch(desc, &error);
    if (!pipeline_) {
        ALOGE("Failed to create pipeline: %s", error ? error->message : "Unknown");
        if (error)
            g_clear_error(&error);
        return false;
    }

#ifdef __APPLE__
    // iOS: 設定 appsink callback
    GstElement* appsink = gst_bin_get_by_name(GST_BIN(pipeline_), "videosink");
    if (appsink) {
        g_signal_connect(appsink, "new-sample", G_CALLBACK(on_new_video_sample), nullptr);
        ALOGI("Connected appsink new-sample signal for iOS Flutter Texture");
        gst_object_unref(appsink);
    } else {
        ALOGE("Failed to find appsink element");
        return false;
    }
#else
    // Android: 準備 user_data
    PadAddedData* pad_data = new PadAddedData();
    pad_data->window_handle = window_handle;

    GstElement* decodebin = gst_bin_get_by_name(GST_BIN(pipeline_), "decodebin");
    if (decodebin) {
        ALOGI("Android: prepare decodebin connection");
        g_signal_connect(decodebin, "pad-added",
                         G_CALLBACK(decodebin_pad_added_cb), pad_data);
        gst_object_unref(decodebin);
    }
#endif

    // 檢查 bus 上的錯誤
    GstBus* bus = gst_pipeline_get_bus(GST_PIPELINE(pipeline_));
    GstMessage* msg;

    while ((msg = gst_bus_pop(bus)) != NULL) {
        char* details = NULL;

        switch (GST_MESSAGE_TYPE(msg)) {
            case GST_MESSAGE_ERROR:
                details = parse_gst_message_details(msg, TRUE);
                ALOGE("GStreamer ERROR: %s", details);
                break;
            case GST_MESSAGE_WARNING:
                details = parse_gst_message_details(msg, FALSE);
                ALOGW("GStreamer WARNING: %s", details);
                break;
            default:
                break;
        }

        if (details)
            g_free(details);

        gst_message_unref(msg);
    }
    gst_object_unref(bus);

    // 等待 pipeline 完全初始化
    GstStateChangeReturn ret = gst_element_set_state(pipeline_, GST_STATE_READY);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        ALOGE("Failed to set pipeline to READY state");
        return false;
    }

    // 現在再獲取 appsrc
    appsrc_ = gst_bin_get_by_name(GST_BIN(pipeline_), "mysrc");
    if (!appsrc_) {
        ALOGI("Failed to get appsrc from pipeline");
        return false;
    }
    ALOGI("Successfully got appsrc: %p", appsrc_);

    // 設置 appsrc 屬性
    g_object_set(G_OBJECT(appsrc_),
                 "stream-type", 0, // GST_APP_STREAM_TYPE_STREAM
                 NULL);

    const char* elements_to_probe[] = {"mysrc", "h264parse", "avdec_h264", "videoconvert"};

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

    ret = gst_element_set_state(pipeline_, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        ALOGE("Failed to set pipeline to PLAYING state");
        return false;
    }

    ALOGI("Pipeline successfully initialized and playing");

    return true;
}

void GstVideoPipeline::push_au(const std::vector<uint8_t>& au) {
    ALOGI("[push_au] Attempting to push AU size: %zu", au.size());

    // 檢查 appsrc 狀態
    GstState state;
    gst_element_get_state(appsrc_, &state, NULL, 0);
    ALOGI("[push_au] appsrc state: %d", state);

    // 創建 buffer
    GstBuffer* buffer = gst_buffer_new_allocate(NULL, au.size(), NULL);
    if (!buffer) {
        ALOGI("[push_au] ERROR: Failed to allocate buffer!");
        return;
    }

    // 映射和複製數據
    GstMapInfo map;
    if (!gst_buffer_map(buffer, &map, GST_MAP_WRITE)) {
        ALOGI("[push_au] ERROR: Failed to map buffer!");
        gst_buffer_unref(buffer);
        return;
    }

    memcpy(map.data, au.data(), au.size());
    gst_buffer_unmap(buffer, &map);

    // 設置時間戳
    static GstClockTime timestamp = 0;
    static const GstClockTime frame_duration = GST_SECOND / 30; // 假設 30fps

    GST_BUFFER_PTS(buffer) = timestamp;
    GST_BUFFER_DTS(buffer) = timestamp;
    GST_BUFFER_DURATION(buffer) = frame_duration;

    timestamp += frame_duration;

    // 推送並檢查返回值
    GstFlowReturn ret = gst_app_src_push_buffer(GST_APP_SRC(appsrc_), buffer);
    ALOGI("[push_au] Push result: %d (%s)", ret, gst_flow_get_name(ret));

    if (ret != GST_FLOW_OK) {
        ALOGI("[push_au] ERROR: Push failed with: %s", gst_flow_get_name(ret));
    } else {
        ALOGI("[push_au] SUCCESS: Buffer pushed successfully");
    }
}

void GstVideoPipeline::stop() {
    if (pipeline_) {
        gst_element_set_state(pipeline_, GST_STATE_NULL);
        gst_object_unref(pipeline_);
        pipeline_ = nullptr;
    }
    appsrc_ = nullptr;
}