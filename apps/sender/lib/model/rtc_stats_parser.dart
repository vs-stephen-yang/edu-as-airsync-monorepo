import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

double? _diff(double? a, double? b) {
  if (a == null || b == null) {
    return null;
  }
  return a - b;
}

abstract class RtcStatsSubscriber {
  void onVideoStatsReports(RtcVideoOutboundStats stats);
}

class RtcStatsParser {
  int? _outboundVideoWidth;
  int? _outboundVideoHeight;
  double _totalEncodeTime = 0;

  final List<RtcStatsSubscriber> _subscribers = [];

  Function(int? width, int? height)? onOutboundVideoFrameSizeChanged;

  RtcStatsParser(
      this.onOutboundVideoFrameSizeChanged);

  void onVideoStatsReports(List<StatsReport> reports) {
    try {
      _onStatsReports(reports);
    } catch (e, stacktrace) {
      log.warning('onStatsReports', e, stacktrace);
    }
  }

  void _onStatsReports(List<StatsReport> reports) {
    // find video outbound-rtp reports
    final outboundRtps = reports
        .where((StatsReport report) => report.type == 'outbound-rtp')
        .toList();
    final videoOutboundRtps = outboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();
    _onVideoStatsReports(videoOutboundRtps);
  }

  void _onVideoStatsReports(List<StatsReport> reports) {
    if (reports.isEmpty) {
      _outboundVideoWidth = null;
      _outboundVideoHeight = null;
      _totalEncodeTime = 0;
      return;
    }

    final videoOutboundRtp = reports.first;
    final stats = RtcVideoOutboundStats();

    stats.encoderImplementation = videoOutboundRtp.values['encoderImplementation'];
    stats.frameHeight = videoOutboundRtp.values['frameHeight'];
    stats.frameWidth = videoOutboundRtp.values['frameWidth'];

    stats.framesPerSecond = videoOutboundRtp.values['framesPerSecond'];

    stats.contentType = videoOutboundRtp.values['contentType'];
    stats.qualityLimitationReason = videoOutboundRtp.values['qualityLimitationReason'];

    double totalEncodeTime = videoOutboundRtp.values['totalEncodeTime'];

    stats.pliCount = videoOutboundRtp.values['pliCount'];
    stats.targetBitrate = videoOutboundRtp.values['targetBitrate'];
    stats.encodeTime = _diff(totalEncodeTime, _totalEncodeTime);
    stats.powerEfficientEncoder = videoOutboundRtp.values['powerEfficientEncoder'];

    publishRtcVideoOutboundStats(stats);

    if (_outboundVideoWidth != stats.frameWidth || _outboundVideoHeight != stats.frameHeight) {
      _outboundVideoWidth = stats.frameWidth;
      _outboundVideoHeight = stats.frameHeight;
      onOutboundVideoFrameSizeChanged?.call(_outboundVideoWidth, _outboundVideoHeight);
    }

    // update
    _totalEncodeTime = totalEncodeTime;
  }

  void addSubscriber(RtcStatsSubscriber s) {
    _subscribers.add(s);
  }

  void publishRtcVideoOutboundStats(RtcVideoOutboundStats stats) {
    for (final subscriber in _subscribers) {
      subscriber.onVideoStatsReports(stats);
    }
  }
}