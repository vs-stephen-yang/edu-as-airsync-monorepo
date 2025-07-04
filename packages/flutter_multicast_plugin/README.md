# flutter_multicast_plugin

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android Native Build Instructions
This Flutter plugin uses Android native C++ code that integrates the following components:
- uvgRTP – RTP transport (with SRTP support)
- Crypto++ – Encryption library used for SRTP
- GStreamer Android SDK – H.264 decoding and rendering
- Android NDK – JNI bridge, MediaCodec access, logging, etc.

### Required Environment Variable
Before building, set the following environment variable to point to your GStreamer Android SDK path:
```
export GSTREAMER_SDK_ANDROID=export GSTREAMER_SDK_ANDROID=/path/to/gstreamer-1.0-android-universal-<version>
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