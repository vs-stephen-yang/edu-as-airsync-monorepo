import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

double? _diff(double? a, double? b) {
  if (a == null || b == null) {
    return null;
  }
  return a - b;
}

dynamic _avg(dynamic a, dynamic b, int? c, int? d) {
  if (a == null || b == null || c == null || d == null) {
    return null;
  }
  if (c == d) {
    return null;
  }
  return (a - b) / (c - d);
}

abstract class RtcStatsSubscriber {
  void updateVideoStats(RtcVideoOutboundStats stats);
  void updateLocalCandidate(List<StatsReport> reports);
  void updateRemoteCandidate(List<StatsReport> reports);
  void updateCandidatePairStats(StatsReport report);
  void updateCodecStats(StatsReport report);
}

class RtcStatsParser {
  int? _outboundVideoWidth;
  int? _outboundVideoHeight;
  RtcVideoOutboundStats? _previousVideoOutboundStats;

  final List<RtcStatsSubscriber> _subscribers = [];

  Function(int? width, int? height)? onOutboundVideoFrameSizeChanged;

  RtcStatsParser(this.onOutboundVideoFrameSizeChanged);

  void onStatsReports(List<StatsReport> reports) {
    try {
      _onStatsReports(reports);
    } catch (e, stacktrace) {
      log.warning('onStatsReports', e, stacktrace);
    }
  }

  void _onStatsReports(List<StatsReport> reports) {
    // Create maps for different report types
    final reportsByType = <String, List<StatsReport>>{};

    // Categorize reports by type
    for (final report in reports) {
      reportsByType.putIfAbsent(report.type, () => []).add(report);
    }

    for (var report in reportsByType['codec'] ?? []) {
      publishCodecStats(report);
    }

    for (var report in reportsByType['candidate-pair'] ?? []) {
      publishCandidatePairStats(report);
    }

    if (reportsByType['local-candidate'] != null) {
      publishLocalCandidate(reportsByType['local-candidate']!);
    }

    if (reportsByType['remote-candidate'] != null) {
      publishRemoteCandidate(reportsByType['remote-candidate']!);
    }

    // find video outbound-rtp reports
    final outboundRtps = reportsByType['outbound-rtp'] ?? [];
    final videoOutboundRtps = outboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();
    _onVideoStatsReports(videoOutboundRtps);
  }

  void _onVideoStatsReports(List<StatsReport> reports) {
    if (reports.isEmpty) {
      _outboundVideoWidth = null;
      _outboundVideoHeight = null;
      _previousVideoOutboundStats = null;
      return;
    }

    final videoOutboundRtp = reports.first;
    final values = videoOutboundRtp.values;

    // Extract basic fields from report
    final encoderImplementation = values['encoderImplementation'];
    final frameWidth = values['frameWidth'];
    final frameHeight = values['frameHeight'];
    final framesPerSecond = values['framesPerSecond'];
    final contentType = values['contentType'];
    final qualityLimitationReason = values['qualityLimitationReason'];
    final pliCount = values['pliCount'];
    final targetBitrate = values['targetBitrate'];
    final powerEfficientEncoder = values['powerEfficientEncoder'];
    final timestamp = videoOutboundRtp.timestamp;

    // Extract additional fields
    final bytesSent = values['bytesSent'];
    final packetsSent = values['packetsSent'];
    final active = values['active'];
    final firCount = values['firCount'];
    final framesEncoded = values['framesEncoded'];
    final framesSent = values['framesSent'];
    final headerBytesSent = values['headerBytesSent'];
    final hugeFramesSent = values['hugeFramesSent'];
    final keyFramesEncoded = values['keyFramesEncoded'];
    final nackCount = values['nackCount'];
    final retransmittedBytesSent = values['retransmittedBytesSent'];
    final retransmittedPacketsSent = values['retransmittedPacketsSent'];
    final totalEncodeTime = values['totalEncodeTime'];
    final totalEncodedBytesTarget = values['totalEncodedBytesTarget'];
    final totalPacketSendDelay = values['totalPacketSendDelay'];
    final qpSum = values['qpSum'];

    // Initialize calculated metrics
    double? encodeTime;
    double? packetsSentPerSecond;
    double? bytesSentPerSecond;
    double? retransmittedPacketsSentPerSecond;
    double? headerBytesSentPerSecond;
    double? retransmittedBytesSentPerSecond;
    double? framesEncodedPerSecond;
    double? encodeTimeAvgMs;
    double? totalEncodedBytesTargetPerSecond;
    double? framesSentPerSecond;
    double? packetSendDelayAvgMs;
    double? qpSumAvg;

    // Calculate differences if we have previous stats
    if (_previousVideoOutboundStats != null) {
      encodeTime =
          _diff(totalEncodeTime, _previousVideoOutboundStats!.totalEncodeTime);

      // Per-second calculations
      packetsSentPerSecond = _diff(packetsSent?.toDouble(),
          _previousVideoOutboundStats!.packetsSent?.toDouble());

      bytesSentPerSecond = _diff(bytesSent?.toDouble(),
          _previousVideoOutboundStats!.bytesSent?.toDouble());

      retransmittedPacketsSentPerSecond = _diff(
          retransmittedPacketsSent?.toDouble(),
          _previousVideoOutboundStats!.retransmittedPacketsSent?.toDouble());

      headerBytesSentPerSecond = _diff(headerBytesSent?.toDouble(),
          _previousVideoOutboundStats!.headerBytesSent?.toDouble());

      retransmittedBytesSentPerSecond = _diff(
          retransmittedBytesSent?.toDouble(),
          _previousVideoOutboundStats!.retransmittedBytesSent?.toDouble());

      framesEncodedPerSecond = _diff(framesEncoded?.toDouble(),
          _previousVideoOutboundStats!.framesEncoded?.toDouble());

      totalEncodedBytesTargetPerSecond = _diff(
          totalEncodedBytesTarget?.toDouble(),
          _previousVideoOutboundStats!.totalEncodedBytesTarget?.toDouble());

      framesSentPerSecond = _diff(framesSent?.toDouble(),
          _previousVideoOutboundStats!.framesSent?.toDouble());

      // Calculate averages
      encodeTimeAvgMs = _avg(
        totalEncodeTime,
        _previousVideoOutboundStats!.totalEncodeTime,
        framesEncoded,
        _previousVideoOutboundStats!.framesEncoded,
      ) * 1000; // Convert to ms;

      packetSendDelayAvgMs = _avg(
        totalPacketSendDelay,
        _previousVideoOutboundStats!.totalPacketSendDelay,
        packetsSent,
        _previousVideoOutboundStats!.packetsSent,
      ) * 1000; // Convert to ms;

      qpSumAvg = _avg(
        qpSum,
        _previousVideoOutboundStats!.qpSum,
        framesEncoded,
        _previousVideoOutboundStats!.framesEncoded,
      );
    }

    // Create the stats object with all fields
    final stats = RtcVideoOutboundStats(
        encoderImplementation: encoderImplementation,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        framesPerSecond: framesPerSecond,
        contentType: contentType,
        qualityLimitationReason: qualityLimitationReason,
        pliCount: pliCount,
        targetBitrate: targetBitrate,
        encodeTime: encodeTime,
        powerEfficientEncoder: powerEfficientEncoder,
        timestamp: timestamp,
        bytesSent: bytesSent,
        packetsSent: packetsSent,
        active: active,
        firCount: firCount,
        framesEncoded: framesEncoded,
        framesSent: framesSent,
        headerBytesSent: headerBytesSent,
        hugeFramesSent: hugeFramesSent,
        keyFramesEncoded: keyFramesEncoded,
        nackCount: nackCount,
        retransmittedBytesSent: retransmittedBytesSent,
        retransmittedPacketsSent: retransmittedPacketsSent,
        totalEncodeTime: totalEncodeTime,
        totalEncodedBytesTarget: totalEncodedBytesTarget,
        totalPacketSendDelay: totalPacketSendDelay,
        qpSum: qpSum,
        packetsSentPerSecond: packetsSentPerSecond,
        bytesSentPerSecond: bytesSentPerSecond,
        retransmittedPacketsSentPerSecond: retransmittedPacketsSentPerSecond,
        headerBytesSentPerSecond: headerBytesSentPerSecond,
        retransmittedBytesSentPerSecond: retransmittedBytesSentPerSecond,
        framesEncodedPerSecond: framesEncodedPerSecond,
        encodeTimeAvgMs: encodeTimeAvgMs,
        totalEncodedBytesTargetPerSecond: totalEncodedBytesTargetPerSecond,
        framesSentPerSecond: framesSentPerSecond,
        packetSendDelayAvgMs: packetSendDelayAvgMs,
        qpSumAvg: qpSumAvg
    );

    // Publish the stats to subscribers
    publishRtcVideoOutboundStats(stats);

    // Check if frame size has changed
    if (_outboundVideoWidth != frameWidth ||
        _outboundVideoHeight != frameHeight) {
      _outboundVideoWidth = frameWidth;
      _outboundVideoHeight = frameHeight;
      onOutboundVideoFrameSizeChanged?.call(
          _outboundVideoWidth, _outboundVideoHeight);
    }

    // Update state for next calculation
    _previousVideoOutboundStats = stats;
  }

  void addSubscriber(RtcStatsSubscriber s) {
    _subscribers.add(s);
  }

  void publishRtcVideoOutboundStats(RtcVideoOutboundStats stats) {
    for (final subscriber in _subscribers) {
      subscriber.updateVideoStats(stats);
    }
  }

  void publishLocalCandidate(List<StatsReport> reports) {
    if (reports.isEmpty) {
      return;
    }
    for (final subscriber in _subscribers) {
      subscriber.updateLocalCandidate(reports);
    }
  }

  void publishRemoteCandidate(List<StatsReport> reports) {
    if (reports.isEmpty) {
      return;
    }
    for (final subscriber in _subscribers) {
      subscriber.updateRemoteCandidate(reports);
    }
  }

  void publishCandidatePairStats(StatsReport report) {
    for (final subscriber in _subscribers) {
      subscriber.updateCandidatePairStats(report);
    }
  }

  void publishCodecStats(StatsReport report) {
    for (final subscriber in _subscribers) {
      subscriber.updateCodecStats(report);
    }
  }
}