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
	•	uvgRTP – RTP transport (with SRTP support)
	•	Crypto++ – Encryption library used for SRTP
	•	GStreamer Android SDK – H.264 decoding and rendering
    •	Android NDK – JNI bridge, MediaCodec access, logging, etc.

### Required Environment Variable
Before building, set the following environment variable to point to your GStreamer Android SDK path:
```
export GSTREAMER_SDK_ANDROID=export GSTREAMER_SDK_ANDROID=/path/to/gstreamer-1.0-android-universal-<version>
```