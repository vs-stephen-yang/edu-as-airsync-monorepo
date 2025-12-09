import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/default_tracking.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:display_cast_flutter/utilities/app_amplitude.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/client_device_info.dart';

class AppAmplitudeSdk implements AppAmplitudeImplement {
  Amplitude? _amplitude;
  EventMode? _mode;

  @override
  Future<void> ensureInitialized({
    required String apiKey,
    ServerZone? serverZone,
    required String instanceName,
    String? deviceId,
    String? userId,
    String? appVersion,
    ClientDeviceInfo? clientDeviceInfo,
  }) async {
    // Create and initialize the instance
    // https://amplitude.com/docs/sdks/analytics/flutter/flutter-sdk-4#configure-the-sdk
    _amplitude = Amplitude(
      Configuration(
        apiKey: apiKey,
        instanceName: instanceName,
        serverZone: serverZone ?? ServerZone.us,
        // https://amplitude.com/docs/sdks/analytics/flutter/flutter-sdk-4#track-default-events
        defaultTracking: DefaultTrackingOptions.all(),
        // defaultTracking: Android, ios
        deviceId: deviceId,
        // deviceId: Web, Android, iOS; macOS is Mac Address
        appVersion: appVersion,
        userId: userId,
        // https://amplitude.com/docs/sdks/analytics/flutter/flutter-sdk-4#autocapture
        autocapture: AutocaptureEnabled(),
        // autocapture: Web
      ),
    );

    // Wait until the SDK is initialized
    await _amplitude?.isBuilt;
  }

  @override
  void setMode(EventMode? mode) {
    _mode = mode;
  }

  @override
  Future<void> trackEvent(
    String name,
    EventCategory category, {
    String? target,
    Map<String, dynamic> properties = const <String, dynamic>{},
  }) async {
    // Track an event
    await _amplitude?.track(
      BaseEvent(
        name,
        eventProperties: {
          ...properties,
          'category': category.name,
          if (target != null) 'target': target,
          if (_mode != null &&
              (category == EventCategory.session ||
                  category == EventCategory.annotation))
            'mode': _mode!.value,
        },
      ),
    );

    // Send events to the server
    await _amplitude?.flush();
  }
}
