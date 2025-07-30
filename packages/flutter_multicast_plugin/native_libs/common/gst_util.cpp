#include "gst_util.h"
#include "gst_pipeline_observer.h"
#include "log.h"
#include <algorithm>
#include <glib.h>
#include <gst/gst.h>
#include <gst/gstbuffer.h>
#include <gst/gstcaps.h>
#include <gst/gstevent.h>
#include <gst/gstpad.h>
#include <string>

#ifdef __ANDROID__
#include "jni_context.h"
#include <jni.h>
#endif

GstPadProbeReturn enhanced_probe_callback(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
    const char* element_name = (const char*)user_data;

    if (info->type & GST_PAD_PROBE_TYPE_BUFFER) {
        GstBuffer* buffer = GST_PAD_PROBE_INFO_BUFFER(info);
        GstMapInfo map;

        if (gst_buffer_map(buffer, &map, GST_MAP_READ)) {
            // 計算時間戳（秒）
            gdouble pts_seconds = (gdouble)GST_BUFFER_PTS(buffer) / GST_SECOND;

            ALOGD("🔍 [PROBE] %s:", element_name);
            ALOGD("  📏 Size: %zu bytes", map.size);
            ALOGD("  ⏰ PTS: %.3f sec (raw: %" G_GUINT64_FORMAT ")", pts_seconds, GST_BUFFER_PTS(buffer));

            // 準備 Head 數據字符串 (前8個bytes)
            std::string head_str = "";
            for (gsize i = 0; i < 8 && i < map.size; i++) {
                char temp[8];
                snprintf(temp, sizeof(temp), "%02x ", map.data[i]);
                head_str += temp;
            }
            ALOGD("  🔢 Head: %s", head_str.c_str());

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
                ALOGD("  🔢 Mid:  %s", mid_str.c_str());

                // 結尾8個bytes
                std::string tail_str = "";
                for (gsize i = 0; i < 8; i++) {
                    char temp[8];
                    snprintf(temp, sizeof(temp), "%02x ", map.data[map.size - 8 + i]);
                    tail_str += temp;
                }
                ALOGD("  🔢 Tail: %s", tail_str.c_str());
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

            gst_buffer_unmap(buffer, &map);
        }

        // 取得當前 caps 資訊
        GstCaps* caps = gst_pad_get_current_caps(pad);
        if (caps) {
            gchar* caps_str = gst_caps_to_string(caps);
            ALOGD("  📝 Caps: %s", caps_str);
            g_free(caps_str);
            gst_caps_unref(caps);
        }
    }

    return GST_PAD_PROBE_OK;
}

char* parse_gst_message_details(GstMessage* msg, gboolean is_error) {
    gchar* debug_info = NULL;
    GError* error = NULL;

    if (is_error)
        gst_message_parse_error(msg, &error, &debug_info);
    else
        gst_message_parse_warning(msg, &error, &debug_info);

    gchar* result = g_strdup_printf("%s\n%s",
                                    (error && error->message) ? error->message : "No message",
                                    debug_info ? debug_info : "No debug info");

    if (debug_info)
        g_free(debug_info);

    if (error)
        g_error_free(error);

    return result; // caller must g_free(result), and also g_error_free(*out_error)
}

GstBusSyncReply bus_sync_handler(GstBus*, GstMessage* msg, gpointer user_data) {
    char* details = NULL;
    GstPipelineObserver* observer = static_cast<GstPipelineObserver*>(user_data);

    switch (GST_MESSAGE_TYPE(msg)) {
        case GST_MESSAGE_ERROR:
            details = parse_gst_message_details(msg, TRUE);
            ALOGE("GStreamer ERROR: %s", details);

            if (observer)
                observer->on_pipeline_error();
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

    // Important: return to let the message continue flowing
    return GST_BUS_PASS;
}

GstPadProbeReturn on_decoder_caps_probe(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
    if (GST_PAD_PROBE_INFO_TYPE(info) & GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM) {
        GstEvent* event = GST_PAD_PROBE_INFO_EVENT(info);
        if (GST_EVENT_TYPE(event) == GST_EVENT_CAPS) {
            GstCaps* caps = NULL;
            gst_event_parse_caps(event, &caps);

            if (caps) {
                GstStructure* s = gst_caps_get_structure(caps, 0);
                int width = 0, height = 0;
                gst_structure_get_int(s, "width", &width);
                gst_structure_get_int(s, "height", &height);

                notify_video_resolution(width, height);
            }
        }
    }
    return GST_PAD_PROBE_OK;
}

void notify_video_resolution(int width, int height) {
#ifdef __ANDROID__
    if (!java_vm || !g_plugin_instance) {
        return;
    }

    JNIEnv* env;
    if (java_vm->GetEnv((void**)&env, JNI_VERSION_1_4) != JNI_OK) {
        if (java_vm->AttachCurrentThread(&env, nullptr) != 0) {
            return;
        }
    }

    jclass clazz = env->GetObjectClass(g_plugin_instance);
    jmethodID method = env->GetMethodID(clazz, "onNativeResolution", "(II)V");
    if (method) {
        env->CallVoidMethod(g_plugin_instance, method, width, height);
    }
#endif
}
