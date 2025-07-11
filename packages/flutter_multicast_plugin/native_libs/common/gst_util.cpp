#include "gst_util.h"
#include "log.h"
#include <algorithm>
#include <glib.h>
#include <gst/gst.h>
#include <gst/gstbuffer.h>
#include <gst/gstcaps.h>
#include <gst/gstpad.h>
#include <string>

GstPadProbeReturn enhanced_probe_callback(GstPad* pad, GstPadProbeInfo* info, gpointer user_data) {
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

char* parse_gst_message_details(GstMessage* msg, GError** out_error, gboolean is_error) {
    gchar* debug_info = NULL;
    *out_error = NULL;

    if (is_error)
        gst_message_parse_error(msg, out_error, &debug_info);
    else
        gst_message_parse_warning(msg, out_error, &debug_info);

    gchar* result = g_strdup_printf("%s\n%s",
                                    (*out_error && (*out_error)->message) ? (*out_error)->message : "No message",
                                    debug_info ? debug_info : "No debug info");

    if (debug_info)
        g_free(debug_info);

    return result; // caller must g_free(result), and also g_error_free(*out_error)
}