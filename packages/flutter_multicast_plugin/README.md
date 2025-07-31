# flutter_multicast_plugin

## Download and install GStreamer binaries
### Android
1.	Visit the [GStreamer Android Releases page](https://gstreamer.freedesktop.org/download/#android)
2.	Download the “Universal” tarball, for example: `gstreamer-1.0-android-universal-1.26.4.tar.xz`
3.	Extract it to a desired location, for example: 
    ```
    tar -xf gstreamer-1.0-android-universal-1.26.4.tar.xz -C ~/SDKs/
    ```

### iOS
1.	Visit the [GStreamer iOS Releases page](https://gstreamer.freedesktop.org/download/#ios)
2.	Download the “Universal” tarball, for example: `gstreamer-1.0-devel-1.26.3-ios-universal.pkg`
3.	Install it to a desired location

### macOS
1.	Visit the [GStreamer macOS Releases page](https://gstreamer.freedesktop.org/download/#macos)
2.	Install both `runtime` and `development` installer


## Android Native Build Instructions
This Flutter plugin uses Android native C++ code that integrates the following components:
- uvgRTP – RTP transport (with SRTP support)
- Crypto++ – Encryption library used for SRTP
- GStreamer Android SDK – H.264 decoding and rendering
- Android NDK – JNI bridge, MediaCodec access, logging, etc.

### Required Environment Variable
Before building, set the following environment variable to point to your GStreamer Android SDK path:
```
export GSTREAMER_SDK_ANDROID=/path/to/gstreamer-1.0-android-universal-<version>
```

## iOS Native Build Instructions
This Flutter plugin uses iOS native C++ code that integrates the following components:
- uvgRTP – RTP transport (with SRTP support)
- Crypto++ – Encryption library used for SRTP
- GStreamer iOS SDK – H.264 decoding and rendering
- iOS Frameworks – VideoToolbox, CoreVideo, CoreMedia for hardware acceleration

### Required Environment Variable
Before building, set the following environment variable to point to your GStreamer iOS SDK path:
```
export GSTREAMER_SDK_IOS=/path/to/GStreamer.framework
```

### Building Native Libraries
Navigate to the `ios/` directory and use the provided build script:
```
cd ios/
```

#### Full Build (Clean & Configure)
Performs a complete build with CMake configuration:
```bash
./build.sh
# or explicitly
./build.sh --clean
```

#### Fast Build (Incremental)
Skips CMake configuration and performs incremental build:
```bash
./build.sh --fast
# or short form
./build.sh -f
```

**Build Options**

`--clean` / `-c`: Complete build (default) - removes previous build files and reconfigures CMake  
`--fast` / `-f`: Fast build - reuses existing CMake configuration for quicker builds

**Note:** Fast build requires a previous successful full build. If no CMake configuration exists, the script will prompt you to run a full build first.

**Build Output**
The build process generates static libraries in the `ios/libs/` directory:  
`libcryptopp.a` - Crypto++ encryption library  
`libuvgrtp.a` - uvgRTP transport library  
`libcommon.a` - Common utilities and GStreamer pipeline  
`libgst_ios_init.a` - GStreamer iOS initialization

## macOS Native Build Instructions
This Flutter plugin uses macOS native C++ code that integrates the following components:
- uvgRTP – RTP transport (with SRTP support)
- Crypto++ – Encryption library used for SRTP
- GStreamer macOS SDK – H.264 decoding and rendering
- macOS Frameworks – VideoToolbox, CoreVideo, CoreMedia for hardware acceleration

### Required Environment Variable
Before building, set the following environment variable to point to your GStreamer macOS SDK path:
```
export GSTREAMER_SDK_MACOS=/path/to/GStreamer.framework
```

### Building Native Libraries
Navigate to the `macos/` directory and use the provided build script:
```
cd macos/
```

#### Full Build (Clean & Configure)
Performs a complete build with CMake configuration:
```bash
./build.sh
# or explicitly
./build.sh --clean
```

#### Fast Build (Incremental)
Skips CMake configuration and performs incremental build:
```bash
./build.sh --fast
# or short form
./build.sh -f
```

**Build Options**

`--clean` / `-c`: Complete build (default) - removes previous build files and reconfigures CMake  
`--fast` / `-f`: Fast build - reuses existing CMake configuration for quicker builds

**Note:** Fast build requires a previous successful full build. If no CMake configuration exists, the script will prompt you to run a full build first.

**Build Output**
The build process generates static libraries in the `macos/libs/` directory:  
`libcryptopp.a` - Crypto++ encryption library  
`libuvgrtp.a` - uvgRTP transport library  
`libcommon.a` - Common utilities and GStreamer pipeline  

#### 🔹 Optional: Set Log Level (for iOS/macOS logging)

To control the verbosity of native log output (e.g., `ALOGD`, `ALOGW`), set the `LOG_LEVEL` environment variable **before building**:

```bash
export LOG_LEVEL=LOG_LEVEL_WARN
```

Available levels:
- LOG_LEVEL_VERBOSE (0)
- LOG_LEVEL_DEBUG   (1)
- LOG_LEVEL_INFO    (2)
- LOG_LEVEL_WARN    (3)
- LOG_LEVEL_ERROR   (4)
- LOG_LEVEL_NONE    (5)

This value is passed:
- To CMake via -DLOG_LEVEL=... (used by common/log.h)
- To CocoaPods via OTHER_CFLAGS (used by .mm sources in iOS/macOS)

⚠️ After changing LOG_LEVEL, you must re-run pod install for iOS/macOS:

```bash
cd example/macos  # or example/ios
rm -rf Pods Podfile.lock
LOG_LEVEL=LOG_LEVEL_WARN pod install
```