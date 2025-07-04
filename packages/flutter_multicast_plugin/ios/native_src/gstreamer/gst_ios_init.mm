#import <Foundation/Foundation.h>
#include <gst/gst.h>
#include "gst_ios_init.h"

G_BEGIN_DECLS

/* 你的 pipeline 需要的插件 */
GST_PLUGIN_STATIC_DECLARE(coreelements);
GST_PLUGIN_STATIC_DECLARE(app);
GST_PLUGIN_STATIC_DECLARE(videoparsersbad);    // h264parse
GST_PLUGIN_STATIC_DECLARE(libav);              // avdec_h264
GST_PLUGIN_STATIC_DECLARE(videoconvertscale);  // videoconvert (新版本)
GST_PLUGIN_STATIC_DECLARE(applemedia);         // iosglimagesink
GST_PLUGIN_STATIC_DECLARE(opengl);
GST_PLUGIN_STATIC_DECLARE(playback);
GST_PLUGIN_STATIC_DECLARE(videotestsrc);
GST_PLUGIN_STATIC_DECLARE(x264);


G_END_DECLS

void gst_ios_init(void)
{
    static gboolean initialized = FALSE;
    
    if (initialized) {
        return;
    }
    
    // 設定基本環境變數
    NSString *resources = [[NSBundle mainBundle] resourcePath];
    const gchar *resources_dir = [resources UTF8String];
    g_setenv("XDG_RUNTIME_DIR", resources_dir, TRUE);
    g_setenv("HOME", resources_dir, TRUE);

    // 初始化 GStreamer
    gst_init(NULL, NULL);

    // 註冊 pipeline 需要的插件
    GST_PLUGIN_STATIC_REGISTER(coreelements);
    GST_PLUGIN_STATIC_REGISTER(app);
    GST_PLUGIN_STATIC_REGISTER(videoparsersbad);
    GST_PLUGIN_STATIC_REGISTER(libav);
    GST_PLUGIN_STATIC_REGISTER(videoconvertscale);
    GST_PLUGIN_STATIC_REGISTER(applemedia);
    GST_PLUGIN_STATIC_REGISTER(opengl);
    GST_PLUGIN_STATIC_REGISTER(playback);
    GST_PLUGIN_STATIC_REGISTER(videotestsrc);
    GST_PLUGIN_STATIC_REGISTER(x264);
    
    initialized = TRUE;
}