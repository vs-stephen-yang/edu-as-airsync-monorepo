#include "gst_macos_init.h"
#import <Foundation/Foundation.h>
#include <dirent.h>
#include <gst/gst.h>
#include <gst/gstplugin.h>

void load_plugin_manually(const char *path) {
  GError *err = NULL;
  GstPlugin *plugin = gst_plugin_load_file(path, &err);

  if (!plugin) {
    g_printerr("❌ Failed to load plugin %s: %s\n", path,
               err ? err->message : "Unknown error");
    if (err)
      g_error_free(err);
  } else {
    g_print("✅ Successfully loaded plugin from: %s\n", path);
    gst_object_unref(plugin);
  }
}

void load_all_plugins_from_dir(const char *dir_path) {
  DIR *dir = opendir(dir_path);
  if (!dir) {
    g_printerr("❌ Cannot open plugin dir: %s\n", dir_path);
    return;
  }

  struct dirent *entry;
  while ((entry = readdir(dir)) != NULL) {
    if (g_str_has_suffix(entry->d_name, ".dylib")) {
      gchar *full_path = g_build_filename(dir_path, entry->d_name, NULL);
      load_plugin_manually(full_path);
      g_free(full_path);
    }
  }

  closedir(dir);
}

void gst_macos_init(void) {
  static gboolean initialized = FALSE;

  if (initialized) {
    return;
  }

  // 設定基本環境變數
  NSString *resources = [[NSBundle mainBundle] resourcePath];
  const gchar *resources_dir = [resources UTF8String];
  g_setenv("XDG_RUNTIME_DIR", resources_dir, TRUE);
  g_setenv("HOME", resources_dir, TRUE);
  g_setenv("GST_DEBUG", "GST_PLUGIN_LOADING:7", TRUE);

  // 初始化 GStreamer
  gst_init(NULL, NULL);

  NSString *pluginDir = [resources
      stringByAppendingPathComponent:@"gstreamer-frameworks/gstreamer-1.0"];
  load_all_plugins_from_dir(pluginDir.UTF8String);

  GstRegistry *registry = gst_registry_get();

  const gchar *factories[] = {"appsrc",       "h264parse",   "avdec_h264",
                              "videoconvert", "queue",       "opusdec",
                              "audioconvert", "osxaudiosink"};

  for (guint i = 0; i < G_N_ELEMENTS(factories); i++) {
    const gchar *name = factories[i];
    GstElementFactory *factory = gst_element_factory_find(name);

    if (factory) {
      g_print("Element factory '%s' found\n", name);
      gst_object_unref(factory);
    } else {
      g_printerr("Element factory '%s' NOT found in registry!\n", name);
    }
  }

  initialized = TRUE;

  GstRegistry *reg = gst_registry_get();
  GList *plugins = gst_registry_get_plugin_list(reg);

  g_print("🔍 Found %d plugins\n", g_list_length(plugins));

  for (GList *l = plugins; l != NULL; l = l->next) {
    GstPlugin *plugin = GST_PLUGIN(l->data);
    g_print("  - %s\n", gst_plugin_get_name(plugin));
  }

  gst_plugin_list_free(plugins);
}