import 'dart:developer';
import 'dart:io';

import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

class AppAnalytics {
  static final AppAnalytics _instance = AppAnalytics._internal();

  //private "Named constructors"
  AppAnalytics._internal();

  // passes the instantiation to the _instance object
  factory AppAnalytics() => _instance;

  ensureInitialized(ConfigSettings configSettings) async {
    if (kIsWeb) {
      // todo: support other platform analytics.
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        await AppCenter.startAsync(
          appSecretAndroid: configSettings.appSecretAndroid,
          appSecretIOS: configSettings.appSecretIOS,
          enableAnalytics: true,
          enableCrashes: true,
          enableDistribute: false,
        );
        _instance._isInitialized = true;
      } else {
        // todo: support other platform analytics.
      }
    }
  }

  bool _isInitialized = false;
  final Map<String, String> _eventProperties = {};

  String _entityId = '';
  String _instanceId = '';
  String _meetingId = '';
  String _presentId = '';
  String _presenterId = '';
  String _displayCode = '';

  setEventProperties(
      {String? entityId,
      String? instanceId,
      String? meetingId,
      String? presentId,
      String? presenterId,
      String? displayCode}) {
    if (entityId != null) {
      _entityId = entityId;
    }
    if (instanceId != null) {
      _instanceId = instanceId;
    }
    if (meetingId != null) {
      _meetingId = meetingId;
    }
    if (presentId != null) {
      _presentId = presentId;
    }
    if (presenterId != null) {
      _presenterId = presenterId;
    }
    if (displayCode != null) {
      _displayCode = displayCode;
    }
    _updateEventProperties();
  }

  _updateEventProperties() {
    Map<String, String> properties = {
      'entity_id': _entityId,
      'instance_id': _instanceId,
      'meeting_id': _meetingId,
      'present_id': _presentId,
      'presenter_id': _presenterId,
      'display_code': _displayCode,
    };
    _eventProperties.addAll(properties);
  }

  _trackEventWithProperties(String event, Map<String, String> properties) {
    if (_isInitialized) {
      log('event: $event, properties: $properties');
      AppCenter.trackEventAsync(event, properties);
    }
  }

  // region Session
  trackEventSessionTimeout() {
    _trackEventWithProperties('session_timeout', _eventProperties);
  }

  trackEventSessionTimeoutNotification() {
    _trackEventWithProperties('session_timeout_notification', _eventProperties);
  }

  // endregion

  // region Present-specific
  trackEventPresentStartReceived() {
    _trackEventWithProperties('present_start_received', _eventProperties);
  }

  trackEventPresentReadySent() {
    _trackEventWithProperties('present_start_ready_sent', _eventProperties);
  }

  trackEventPresentRejectTimeOutSent() {
    _trackEventWithProperties('present_reject_timeout_sent', _eventProperties);
  }

  trackEventPresentRejectBlockedSent() {
    _trackEventWithProperties('present_reject_blocked_sent', _eventProperties);
  }

  trackEventPresentStarting() {
    _trackEventWithProperties('present_starting', _eventProperties);
  }

  trackEventPresentStarted() {
    _trackEventWithProperties('present_started', _eventProperties);
  }

  trackEventPresentStopReceived() {
    _trackEventWithProperties('present_stop_received', _eventProperties);
  }

  trackEventPresentStopped() {
    _trackEventWithProperties('present_stopped', _eventProperties);
  }

  trackEventPresentPauseReceived() {
    _trackEventWithProperties('present_pause_received', _eventProperties);
  }

  trackEventPresentResumeReceived() {
    _trackEventWithProperties('present_resume_received', _eventProperties);
  }

  // Todo: insert optional event
  trackEventPresentSignalConnected() {
    _trackEventWithProperties('present_signal_connected', _eventProperties);
  }

  trackEventPresentSignalDisconnected() {
    _trackEventWithProperties('present_signal_disconnected', _eventProperties);
  }

  trackEventPresentConnectConnecting() {
    _trackEventWithProperties('present_connect_connecting', _eventProperties);
  }

  trackEventPresentConnectDisconnected() {
    _trackEventWithProperties('present_connect_disconnected', _eventProperties);
  }

  trackEventPresentConnectClosed() {
    _trackEventWithProperties('present_connect_closed', _eventProperties);
  }

  trackEventPresentConnectFailed() {
    _trackEventWithProperties('present_connect_failed', _eventProperties);
  }

  // endregion

  // region Enrollment
  trackEventEnrolled() {
    _trackEventWithProperties('enrolled', _eventProperties);
  }

  trackEventUnenrolled() {
    _trackEventWithProperties('unenrolled', _eventProperties);
  }

  // endregion

  // region License-specific
  trackEventLicenseGranted() {
    _trackEventWithProperties('license_granted', _eventProperties);
  }

  trackEventLicenseRevoked() {
    _trackEventWithProperties('license_revoked', _eventProperties);
  }

  trackEventLicenseInsufficientPrivilege() {
    _trackEventWithProperties(
        'license_insufficient_privilege', _eventProperties);
  }

  // endregion

  // region SplitScreen-specific
  trackEventSplitScreenOn() {
    _trackEventWithProperties('splitscreen_on', _eventProperties);
  }

  trackEventSplitScreenOff() {
    _trackEventWithProperties('splitscreen_off', _eventProperties);
  }

  trackEventSplitScreenPanelClose() {
    _trackEventWithProperties('splitscreen_panel_close', _eventProperties);
  }

  trackEventSplitScreenFullScreenClick() {
    _trackEventWithProperties('splitscreen_fullscreen_click', _eventProperties);
  }

  trackEventSplitScreenDisconnectClick() {
    _trackEventWithProperties('splitscreen_disconnect_click', _eventProperties);
  }

  // endregion

  // region Moderator-specific
  trackEventModeratorOn() {
    _trackEventWithProperties('moderator_on', _eventProperties);
  }

  trackEventModeratorOff() {
    _trackEventWithProperties('moderator_off', _eventProperties);
  }

  trackEventModeratorPanelClose() {
    _trackEventWithProperties('moderator_panel_close', _eventProperties);
  }

  trackEventModeratorEdit() {
    _trackEventWithProperties('moderator_edit', _eventProperties);
  }

  trackEventModeratorSplitScreenOn() {
    _trackEventWithProperties('moderator_splitscreen_on', _eventProperties);
  }

  trackEventModeratorSplitScreenOff() {
    _trackEventWithProperties('moderator_splitscreen_off', _eventProperties);
  }

  trackEventModeratorPresentersListUpdated(String presenters) {
    Map<String, String> properties = {
      'presenters': presenters,
    };
    properties.addAll(_eventProperties);
    _trackEventWithProperties('moderator_presenters_list_updated', properties);
  }

  trackEventModeratorPresentersRemove() {
    _trackEventWithProperties('moderator_presenters_remove', _eventProperties);
  }

  trackEventModeratorPresenterPresent() {
    _trackEventWithProperties('moderator_presenter_present', _eventProperties);
  }

  trackEventModeratorPresenterStop() {
    _trackEventWithProperties('moderator_presenter_stop', _eventProperties);
  }

  // endregion

  // region Top-level UI
  trackEventAppSplitScreenClick() {
    _trackEventWithProperties('app_splitscreen_click', _eventProperties);
  }

  trackEventAppModeratorClick() {
    _trackEventWithProperties('app_moderator_click', _eventProperties);
  }

  trackEventAppLanguageClick() {
    _trackEventWithProperties('app_language_click', _eventProperties);
  }

  trackEventAppWhatsNewsClick() {
    _trackEventWithProperties('app_whatsnews_click', _eventProperties);
  }

  trackEventAppOTPMaskClick() {
    _trackEventWithProperties('app_otp_mask_click', _eventProperties);
  }

  // endregion

  // region Misc Events
  trackEventAppStarted() {
    _trackEventWithProperties('app_start', _eventProperties);
  }

  trackEventAppTerminated() {
    _trackEventWithProperties('app_stop', _eventProperties);
  }

  trackEventControlConnected() {
    _trackEventWithProperties('control_connected', _eventProperties);
  }

  trackEventControlDisconnected() {
    _trackEventWithProperties('control_disconnected', _eventProperties);
  }
// endregion
}
