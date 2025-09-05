import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

dynamic _diff(dynamic a, dynamic b) {
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
    final List<StatsReport> candidatePairs = [];
    final List<StatsReport> transports = [];

    // Categorize reports by type
    for (final report in reports) {
      reportsByType.putIfAbsent(report.type, () => []).add(report);
    }

    for (var report in reportsByType['codec'] ?? []) {
      publishCodecStats(report);
    }

    for (var report in reportsByType['candidate-pair'] ?? []) {
      candidatePairs.add(report);
      publishCandidatePairStats(report);
    }

    if (reportsByType['local-candidate'] != null) {
      publishLocalCandidate(reportsByType['local-candidate']!);
    }

    if (reportsByType['remote-candidate'] != null) {
      publishRemoteCandidate(reportsByType['remote-candidate']!);
    }

    for (var report in reportsByType['transport'] ?? []) {
      transports.add(report);
    }

    final mediaSources = reportsByType['media-source'] ?? [];
    final videoMediaSources = mediaSources
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    // find video outbound-rtp reports
    final outboundRtps = reportsByType['outbound-rtp'] ?? [];
    final videoOutboundRtps = outboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();
    _onVideoStatsReports(
        videoOutboundRtps, transports, candidatePairs, videoMediaSources);
  }

  void _onVideoStatsReports(
    List<StatsReport> reports,
    List<StatsReport> transports,
    List<StatsReport> candidatePairs,
    List<StatsReport> videoMediaSources,
  ) {
    if (reports.isEmpty) {
      _outboundVideoWidth = null;
      _outboundVideoHeight = null;
      _previousVideoOutboundStats = null;
      return;
    }

    final videoOutboundRtp = reports.first;
    final values = videoOutboundRtp.values;

    // Extract basic fields from report
    final transportId = values['transportId'];
    final mediaSourceId = values['mediaSourceId'];
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
    int? bytesSentPerSecond;
    int? framesEncodedPerSecond;
    int? framesSentPerSecond;
    int? packetsSentPerSecond;
    int? hugeFramesSentPerSecond;
    double? encodeTime;
    double? retransmittedPacketsSentPerSecond;
    double? headerBytesSentPerSecond;
    double? retransmittedBytesSentPerSecond;
    double? encodeTimeAvgMs;
    double? totalEncodedBytesTargetPerSecond;
    double? packetSendDelayAvgMs;
    double? qpSumAvg;

    // Calculate differences if we have previous stats
    if (_previousVideoOutboundStats != null) {
      encodeTime =
          _diff(totalEncodeTime, _previousVideoOutboundStats!.totalEncodeTime);

      // Per-second calculations
      packetsSentPerSecond =
          _diff(packetsSent, _previousVideoOutboundStats!.packetsSent);

      bytesSentPerSecond =
          _diff(bytesSent, _previousVideoOutboundStats!.bytesSent);

      framesEncodedPerSecond =
          _diff(framesEncoded, _previousVideoOutboundStats!.framesEncoded);

      framesSentPerSecond =
          _diff(framesSent, _previousVideoOutboundStats!.framesSent);

      hugeFramesSentPerSecond =
          _diff(hugeFramesSent, _previousVideoOutboundStats!.hugeFramesSent);

      retransmittedPacketsSentPerSecond = _diff(
          retransmittedPacketsSent?.toDouble(),
          _previousVideoOutboundStats!.retransmittedPacketsSent?.toDouble());

      headerBytesSentPerSecond = _diff(headerBytesSent?.toDouble(),
          _previousVideoOutboundStats!.headerBytesSent?.toDouble());

      retransmittedBytesSentPerSecond = _diff(
          retransmittedBytesSent?.toDouble(),
          _previousVideoOutboundStats!.retransmittedBytesSent?.toDouble());

      totalEncodedBytesTargetPerSecond = _diff(
          totalEncodedBytesTarget?.toDouble(),
          _previousVideoOutboundStats!.totalEncodedBytesTarget?.toDouble());

      // Calculate averages
      var encodeTimeAvg = _avg(
        totalEncodeTime,
        _previousVideoOutboundStats!.totalEncodeTime,
        framesEncoded,
        _previousVideoOutboundStats!.framesEncoded,
      );
      if (encodeTimeAvg != null) {
        encodeTimeAvgMs = encodeTimeAvg * 1000; // Convert to ms;
      }

      var packetSendDelayAvg = _avg(
        totalPacketSendDelay,
        _previousVideoOutboundStats!.totalPacketSendDelay,
        packetsSent,
        _previousVideoOutboundStats!.packetsSent,
      );
      if (packetSendDelayAvg != null) {
        packetSendDelayAvgMs = packetSendDelayAvg * 1000; // Convert to ms;
      }

      qpSumAvg = _avg(
        qpSum,
        _previousVideoOutboundStats!.qpSum,
        framesEncoded,
        _previousVideoOutboundStats!.framesEncoded,
      );
    }

    // Create the stats object with all fields
    final stats = RtcVideoOutboundStats(
        transportId: transportId,
        mediaSourceId: mediaSourceId,
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
        hugeFramesSentPerSecond: hugeFramesSentPerSecond,
        encodeTimeAvgMs: encodeTimeAvgMs,
        totalEncodedBytesTargetPerSecond: totalEncodedBytesTargetPerSecond,
        framesSentPerSecond: framesSentPerSecond,
        packetSendDelayAvgMs: packetSendDelayAvgMs,
        qpSumAvg: qpSumAvg);

    // get extend field
    stats.availableOutgoingBitrate =
        _getAvailableOutgoingBitrate(stats, transports, candidatePairs);
    stats.mediaSourceFramesPerSecond =
        _getMediaSourceFramesPerSecond(stats, videoMediaSources);

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

  double? _getAvailableOutgoingBitrate(
    RtcVideoOutboundStats videoOutboundStat,
    List<StatsReport> transports,
    List<StatsReport> candidatePairs,
  ) {
    final targetTransports = transports
        .where(
            (StatsReport report) => report.id == videoOutboundStat.transportId)
        .toList();
    if (targetTransports.isEmpty) {
      return null;
    }
    final targetTransport = targetTransports.first;
    final transportValue = targetTransport.values;

    final selectedCandidatePairId = transportValue['selectedCandidatePairId'];
    if (selectedCandidatePairId == null ||
        selectedCandidatePairId.toString().isEmpty) {
      return null;
    }

    final selectCandidatePairs = candidatePairs
        .where((StatsReport report) => report.id == selectedCandidatePairId)
        .toList();
    if (selectCandidatePairs.isEmpty) {
      return null;
    }
    final selectCandidatePair = selectCandidatePairs.first;
    final selectCandidatePairValue = selectCandidatePair.values;

    return selectCandidatePairValue['availableOutgoingBitrate'];
  }

  double? _getMediaSourceFramesPerSecond(
      RtcVideoOutboundStats videoOutboundStat, List<StatsReport> mediaSources) {
    final targetMediaSources = mediaSources
        .where((StatsReport report) =>
            report.id == videoOutboundStat.mediaSourceId)
        .toList();
    if (targetMediaSources.isEmpty) {
      return null;
    }
    final targetMediaSource = targetMediaSources.first;
    return targetMediaSource.values['framesPerSecond'];
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
