#include <gst/gst.h>
#ifdef __ANDROID__
#include <jni.h>
#endif

GstPadProbeReturn enhanced_probe_callback(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
GstPadProbeReturn on_decoder_caps_probe(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
GstBusSyncReply bus_sync_handler(GstBus*, GstMessage* msg, gpointer);
void notify_video_resolution(int width, int height);