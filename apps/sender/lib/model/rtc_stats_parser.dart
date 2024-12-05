import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

double? _diff(double? a, double? b) {
  if (a == null || b == null) {
    return null;
  }
  return a - b;
}

class RtcStatsParser {
  int? _outboundVideoWidth;
  int? _outboundVideoHeight;
  double _totalEncodeTime = 0;

  Function(RtcVideoOutboundStats stats)? onVideoOutboundStats;
  Function(int width, int height)? onOutboundVideoFrameSizeChanged;

  RtcStatsParser(
      this.onOutboundVideoFrameSizeChanged,
      this.onVideoOutboundStats);

  void onVideoStatsReports(List<StatsReport> reports) {
    try {
      _onStatsReports(reports);
    } catch (e, stacktrace) {
      log.severe('onStatsReports', e, stacktrace);
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

    onVideoOutboundStats?.call(stats);

    if (_outboundVideoWidth != stats.frameWidth || _outboundVideoHeight != stats.frameHeight) {
      _outboundVideoWidth = stats.frameWidth;
      _outboundVideoHeight = stats.frameHeight;
      onOutboundVideoFrameSizeChanged?.call(_outboundVideoWidth!, _outboundVideoHeight!);
    }

    // update
    _totalEncodeTime = totalEncodeTime;
  }
}