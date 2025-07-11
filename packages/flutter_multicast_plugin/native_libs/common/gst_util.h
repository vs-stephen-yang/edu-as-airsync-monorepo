#include <gst/gst.h>

GstPadProbeReturn enhanced_probe_callback(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
GstBusSyncReply bus_sync_handler(GstBus*, GstMessage* msg, gpointer);