import 'dart:io';

import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/app_analytics_util.dart';
import 'package:display_flutter/utility/client_device_info.dart';
import 'package:display_flutter/utility/list_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:http/http.dart';

class AppAnalytics {
  static final AppAnalytics _instance = AppAnalytics._internal();

  //private "Named constructors"
  AppAnalytics._internal();

  // passes the instantiation to the _instance object
  factory AppAnalytics() => _instance;

  TelemetryClient? _client;

  ensureInitialized(
    ConfigSettings configSettings, {
    String? applicationVersion,
    String? sessionId,
    String? userId,
    ClientDeviceInfo? deviceInfo,
  }) async {
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

    _initializeAppInsightsClient(
      configSettings.instrumentationKey,
      configSettings.ingestionEndpoint,
      applicationVersion,
      sessionId,
      userId,
      deviceInfo,
    );
  }

  // initialize client for Azure Application Insights
  _initializeAppInsightsClient(
    String instrumentationKey,
    String ingestionEndpoint,
    String? applicationVersion,
    String? sessionId,
    String? userId,
    ClientDeviceInfo? deviceInfo,
  ) {
    final processor = BufferedProcessor(
      next: TransmissionProcessor(
        instrumentationKey: instrumentationKey,
        ingestionEndpoint: ingestionEndpoint,
        httpClient: Client(),
        timeout: const Duration(seconds: 10),
      ),
    );

    final context = TelemetryContext();
    context
      ..applicationVersion = applicationVersion
      ..session.sessionId = sessionId
      ..user.id = userId;

    if (deviceInfo != null) {
      context.device
        ..locale = deviceInfo.locale
        ..type = deviceInfo.clientType
        ..osVersion = deviceInfo.clientOs
        ..model = deviceInfo.clientModel;
    }

    _client = TelemetryClient(
      processor: processor,
      context: context,
    );
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

  Map<String, String> _getPresentProperties(
      String presentId, String presenterId) {
    Map<String, String> properties = {};
    properties.addAll(_eventProperties);
    properties.addAll({
      'present_id': presentId,
      'presenter_id': presenterId,
    });
    return properties;
  }

  _trackEventWithProperties(String event, Map<String, String> properties) {
    if (_isInitialized) {
      log.info('event: $event, properties: $properties');

      _client?.trackEvent(
        name: event,
        additionalProperties: properties,
      );
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
  trackEventPresentStartReceived(String presentId, String presenterId) {
    _trackEventWithProperties('present_start_received',
        _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentReadySent(String presentId, String presenterId) {
    _trackEventWithProperties('present_start_ready_sent',
        _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentRejectTimeOutSent(String presentId, String presenterId) {
    _trackEventWithProperties('present_reject_timeout_sent',
        _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentRejectBlockedSent(String presentId, String presenterId) {
    _trackEventWithProperties('present_reject_blocked_sent',
        _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentStarting(String presentId, String presenterId) {
    _trackEventWithProperties(
        'present_starting', _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentStarted(String presentId, String presenterId) {
    _trackEventWithProperties(
        'present_started', _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentStopReceived(String presentId, String presenterId) {
    _trackEventWithProperties(
        'present_stop_received', _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentStopped(String presentId, String presenterId) {
    _trackEventWithProperties(
        'present_stopped', _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentPauseReceived(String presentId, String presenterId) {
    _trackEventWithProperties('present_pause_received',
        _getPresentProperties(presentId, presenterId));
  }

  trackEventPresentResumeReceived(String presentId, String presenterId) {
    _trackEventWithProperties('present_resume_received',
        _getPresentProperties(presentId, presenterId));
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

  trackEventTunnelConnected() {
    _trackEventWithProperties('tunnel_connected', _eventProperties);
  }

  trackEventTunnelConnecting() {
    _trackEventWithProperties('tunnel_connecting', _eventProperties);
  }

  trackEventNetworkConnectivity(String connectivityType) {
    _trackEventWithProperties('network_connectivity', {
      'target': connectivityType,
      ..._eventProperties,
    });
  }

  trackEventPcConnectionState(String? clientId, String state) {
    _trackEventWithProperties('pc_state', {
      'target': state,
      'client_id': clientId ?? '',
      ..._eventProperties,
    });
  }

  trackEventChannelState(String? clientId, String state) {
    _trackEventWithProperties('channel_state', {
      'target': state,
      'client_id': clientId ?? '',
      ..._eventProperties,
    });
  }

  trackEventCloseChannel(String? clientId, String? reason) {
    _trackEventWithProperties('close_channel', {
      'target': reason ?? '',
      'client_id': clientId ?? '',
      ..._eventProperties,
    });
  }

  trackEventRtcCandidateTypes(
      String? clientId, String localCandidateType, String remoteCandidateType) {
    _trackEventWithProperties('pc_candidates', {
      'target': '$localCandidateType-$remoteCandidateType',
      'client_id': clientId ?? '',
      ..._eventProperties,
    });
  }

// endregion

  trackEventRtcMetric(
    String metricName,
    Map<String, String> values,
  ) {
    _trackEventWithProperties(metricName, {
      ..._eventProperties,
      ...values,
    });
  }

  trackEventRtcVideoInboundStats(
    String? clientId,
    List<RtcVideoInboundStats> stats,
  ) {
    final statsLists = RtcVideoInboundStatsLists.fromStatsList(stats);

    //  formats each double value to 2 precision
    const precision = 2;

    final jitterBufferDelay =
        formatDoubleList(statsLists.jitterBufferDelay, precision);
    final decodeTime = formatDoubleList(statsLists.decodeTime, precision);

    _trackEventWithProperties('video_inbound_stats', {
      'client_id': clientId ?? '',
      'framesPerSecond': statsLists.framesPerSecond.join(','),
      'framesReceivedPerSecond': statsLists.framesReceivedPerSecond.join(','),
      'framesDecodedPerSecond': statsLists.framesDecodedPerSecond.join(','),
      'framesDroppedPerSecond': statsLists.framesDroppedPerSecond.join(','),
      'bytesPerSecond': statsLists.bytesPerSecond.join(','),
      'packetsLost': statsLists.packetsLost.join(','),
      'packetsReceived': statsLists.packetsReceived.join(','),
      'jitter': statsLists.jitter.join(','),
      'pauseCount': statsLists.pauseCount.join(','),
      'jitterBufferDelay': jitterBufferDelay.join(','),
      'decodeTime': decodeTime.join(','),
      ..._eventProperties,
    });
  }

  trackEventException(String error, String stack) {
    _trackEventWithProperties('exception', {
      'target': error,
      'stack': stack,
      ..._eventProperties,
    });
  }
}
