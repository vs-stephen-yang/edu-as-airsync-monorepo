#include <gst/gst.h>

GstPadProbeReturn enhanced_probe_callback(GstPad* pad, GstPadProbeInfo* info, gpointer user_data);
char* parse_gst_message_details(GstMessage* msg, gboolean is_error);