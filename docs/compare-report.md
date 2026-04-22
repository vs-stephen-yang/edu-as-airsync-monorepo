# Build Comparison Report

Generated: Thu Apr 23 00:17:06 TST 2026

- Original sender:   47e3e99165ee867a4b058d6d7c003fbdce06e57a
- Original receiver: 5ec5156586b146335e0b940fa565f05ff3eec9a4
- Monorepo:          241c22a61af8d33b988b4fbffda05ac2cfec0508

## Build Status

| App | Platform | Original | Monorepo |
|-----|----------|----------|----------|
| sender | web | OK | OK |
| sender | windows | OK | OK |
| sender | apk | OK | OK |
| receiver | apk | OK | OK |

## Comparison Results

### sender / web

- Build: original=`OK`, monorepo=`OK`
- Result: **EQUIVALENT** (all artifacts match)

  ```
  Match: 406, expected-diff: 3, unexpected-diff: 0
  - [EXPECTED:metadata] flutter_bootstrap.js: orig=8113B vs mono=8112B (sha 2527f4e6..78244aad)
  - [EXPECTED:metadata] flutter_service_worker.js: orig=43614B vs mono=43614B (sha baac0da5..bd07a76c)
  ```

### sender / windows

- Build: original=`OK`, monorepo=`OK`
- Result: **DIVERGE**

  ```
Files match: 388, expected-diff: 28, unexpected-diff: 2
  - [EXPECTED:timestamp] AirSync_Sender.exe: orig=404992B vs mono=404992B
  - [EXPECTED:metadata] AirSync_Sender.pdb: orig=5099520B vs mono=5107712B
  - [EXPECTED:timestamp] amplify_db_common_plugin.dll: orig=34304B vs mono=34304B
  - [EXPECTED:timestamp] app_links_plugin.dll: orig=445952B vs mono=445952B
  - [EXPECTED:timestamp] auto_updater_windows_plugin.dll: orig=371712B vs mono=371712B
  - [EXPECTED:timestamp] bonsoir_windows_plugin.dll: orig=550912B vs mono=550912B
  - [EXPECTED:timestamp] connectivity_plus_plugin.dll: orig=376832B vs mono=376832B
  - [UNEXPECTED:size] crashpad_handler.exe: orig=1298944B vs mono=1299456B
  - [EXPECTED:timestamp] crashpad_wer.dll: orig=39424B vs mono=39424B
  - [EXPECTED:timestamp] custom_actions.dll: orig=1383936B vs mono=1383936B
  - [EXPECTED:timestamp] dartjni.dll: orig=117248B vs mono=117248B
  - [EXPECTED:timestamp] data/app.so: orig=12682144B vs mono=12682144B
  - [EXPECTED:timestamp] desktop_multi_window_plugin.dll: orig=399872B vs mono=399872B
  - [EXPECTED:timestamp] desktop_screenstate_plugin.dll: orig=356864B vs mono=356864B
  - [EXPECTED:timestamp] desktop_window_plugin.dll: orig=358400B vs mono=358400B
  - [EXPECTED:timestamp] flutter_input_injection_plugin.dll: orig=385536B vs mono=385536B
  - [EXPECTED:timestamp] flutter_virtual_display_plugin.dll: orig=393216B vs mono=393216B
  - [EXPECTED:timestamp] flutter_webrtc_plugin.dll: orig=927744B vs mono=927744B
  - [EXPECTED:timestamp] flutter_window_close_plugin.dll: orig=357376B vs mono=357376B
  - [EXPECTED:timestamp] launcher.exe: orig=261632B vs mono=261632B
  - [EXPECTED:timestamp] permission_handler_windows_plugin.dll: orig=424448B vs mono=424448B
  - [EXPECTED:timestamp] screen_retriever_windows_plugin.dll: orig=409600B vs mono=409600B
  - [UNEXPECTED:size] sentry.dll: orig=907264B vs mono=907776B
  - [EXPECTED:timestamp] share_plus_plugin.dll: orig=1270272B vs mono=1270272B
  - [EXPECTED:timestamp] sqlite3.dll: orig=1609728B vs mono=1609728B
  - [EXPECTED:timestamp] system_tray_plugin.dll: orig=420352B vs mono=420352B
  - [EXPECTED:timestamp] url_launcher_windows_plugin.dll: orig=378880B vs mono=378880B
  - [EXPECTED:timestamp] win32audio_plugin.dll: orig=428544B vs mono=428544B
  - [EXPECTED:timestamp] window_manager_plugin.dll: orig=452608B vs mono=452608B
  - [EXPECTED:timestamp] window_size_plugin.dll: orig=377856B vs mono=377856B

  ```

### sender / apk

- Build: original=`OK`, monorepo=`OK`
- Result: **EQUIVALENT** (all artifacts match)

  ```
  APK entries match: 841, expected-diff: 23, unexpected-diff: 0
  - [EXPECTED:metadata] assets/sentry-debug-meta.properties: orig=104B vs mono=104B
  - [EXPECTED:timestamp] lib/arm64-v8a/libapp.so: orig=11338656B vs mono=11338656B
  ```

### receiver / apk

- Build: original=`OK`, monorepo=`OK`
- Result: **DIVERGE**

  ```
APK entries match: 735, expected-diff: 26, unexpected-diff: 3
  - [EXPECTED:metadata] assets/dexopt/baseline.prof: orig=1504B vs mono=1371B
  - [EXPECTED:metadata] assets/dexopt/baseline.profm: orig=190B vs mono=188B
  - [EXPECTED:metadata] assets/sentry-debug-meta.properties: orig=104B vs mono=104B
  - [EXPECTED:metadata] classes.dex: orig=6541784B vs mono=6545220B
  - [EXPECTED:timestamp] lib/arm64-v8a/libapp.so: orig=13304736B vs mono=13304736B
  - [EXPECTED:timestamp] lib/arm64-v8a/libdartjni.so: orig=122368B vs mono=122368B
  - [UNEXPECTED:size] lib/arm64-v8a/libflutter_mirror.so: orig=326744B vs mono=327096B
  - [EXPECTED:timestamp] lib/arm64-v8a/libgstreamer_android.so: orig=25258472B vs mono=25258472B
  - [EXPECTED:timestamp] lib/arm64-v8a/liblibuinput.so: orig=8760B vs mono=8760B
  - [EXPECTED:timestamp] lib/arm64-v8a/libmedia_codec_tracker.so: orig=381632B vs mono=381632B
  - [EXPECTED:timestamp] lib/arm64-v8a/libmulticast_android.so: orig=2865720B vs mono=2865720B
  - [EXPECTED:timestamp] lib/armeabi-v7a/libapp.so: orig=14762580B vs mono=14762580B
  - [EXPECTED:timestamp] lib/armeabi-v7a/libdartjni.so: orig=75916B vs mono=75916B
  - [UNEXPECTED:size] lib/armeabi-v7a/libflutter_mirror.so: orig=216264B vs mono=216632B
  - [EXPECTED:timestamp] lib/armeabi-v7a/libgstreamer_android.so: orig=19745664B vs mono=19745664B
  - [EXPECTED:timestamp] lib/armeabi-v7a/liblibuinput.so: orig=6664B vs mono=6664B
  - [EXPECTED:timestamp] lib/armeabi-v7a/libmedia_codec_tracker.so: orig=233948B vs mono=233948B
  - [EXPECTED:timestamp] lib/armeabi-v7a/libmulticast_android.so: orig=1923024B vs mono=1923024B
  - [EXPECTED:timestamp] lib/x86/libdartjni.so: orig=102776B vs mono=102776B
  - [EXPECTED:timestamp] lib/x86/libgstreamer_android.so: orig=22712044B vs mono=22712044B
  - [EXPECTED:timestamp] lib/x86/liblibuinput.so: orig=7412B vs mono=7412B
  - [EXPECTED:timestamp] lib/x86/libmulticast_android.so: orig=2710392B vs mono=2710392B
  - [EXPECTED:timestamp] lib/x86_64/libapp.so: orig=13304736B vs mono=13304736B
  - [EXPECTED:timestamp] lib/x86_64/libdartjni.so: orig=110896B vs mono=110896B
  - [UNEXPECTED:size] lib/x86_64/libflutter_mirror.so: orig=316944B vs mono=317296B
  - [EXPECTED:timestamp] lib/x86_64/libgstreamer_android.so: orig=28891192B vs mono=28891192B
  - [EXPECTED:timestamp] lib/x86_64/liblibuinput.so: orig=8776B vs mono=8776B
  - [EXPECTED:timestamp] lib/x86_64/libmedia_codec_tracker.so: orig=372120B vs mono=372120B
  - [EXPECTED:timestamp] lib/x86_64/libmulticast_android.so: orig=3105384B vs mono=3105384B

  ```

## Summary

- Total targets: 4
- Equivalent: 2
- Divergent: 2
- Skipped: 0

## Logs

Build logs: `/d/tmp/verify-20260422-215813/compare/logs/`
