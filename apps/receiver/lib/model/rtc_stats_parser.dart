import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/utility/log.dart';
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
  void updateVideoInboundStats(RtcVideoInboundStats stats);

  void updateVideoOutboundStats(RtcVideoOutboundStats stats);

  void updateLocalCandidate(List<StatsReport> reports);

  void updateRemoteCandidate(List<StatsReport> reports);

  void updateCandidatePairStats(StatsReport report);

  void updateCodecStats(StatsReport report);

  void pairCandidates(
      StatsReport localCandidateReport, StatsReport remoteCandidateReport);

  void selectedCandidatePair(StatsReport selectedCandidatePair);
}

class RtcStatsParser {
  final List<RtcStatsSubscriber> _subscribers = [];
  RtcVideoInboundStats? _previousVideoInboundStats;
  RtcVideoOutboundStats? _previousVideoOutboundStats;

  RtcStatsParser();

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

    // Create candidate pair map
    final candidatePairMap = <String, StatsReport>{};

    for (var report in reportsByType['candidate-pair'] ?? []) {
      candidatePairMap[report.id] = report;
      publishCandidatePairStats(report);
    }

    final localCandidates = reportsByType['local-candidate'] ?? [];
    final remoteCandidates = reportsByType['remote-candidate'] ?? [];

    publishLocalCandidate(localCandidates);
    publishRemoteCandidate(remoteCandidates);

    // Process transports
    final transports = reportsByType['transport'] ?? [];
    final bytesSent = _findFirstValueForKey(transports, 'bytesSent');

    StatsReport? selectedCandidatePair;
    if (bytesSent != null && bytesSent != 0) {
      final selectedCandidatePairId =
          _findFirstValueForKey(transports, 'selectedCandidatePairId');

      selectedCandidatePair = candidatePairMap[selectedCandidatePairId];

      if (selectedCandidatePair != null) {
        final localCandidateId =
            selectedCandidatePair.values['localCandidateId'];
        final remoteCandidateId =
            selectedCandidatePair.values['remoteCandidateId'];

        publishPairCandidates(
            localCandidates.firstWhere(
                (StatsReport report) => report.id == localCandidateId),
            remoteCandidates.firstWhere(
                (StatsReport report) => report.id == remoteCandidateId));

        publishSelectedCandidatePair(selectedCandidatePair);
      }
    }

    // Process video inbound-rtp
    final inboundRtps = reportsByType['inbound-rtp'] ?? [];
    final videoInboundRtps = inboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    _onVideoInboundStatsReports(videoInboundRtps);

    final mediaSources = reportsByType['media-source'] ?? [];
    final videoMediaSources = mediaSources
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    // Process video outbound-rtp
    final outboundRtps = reportsByType['outbound-rtp'] ?? [];
    final videoOutboundRtps = outboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    _onVideoOutboundStatsReports(
        videoOutboundRtps, selectedCandidatePair, videoMediaSources);
  }

  // Helper method to get the first non-null value from a list of reports
  dynamic _findFirstValueForKey(List<StatsReport> reports, String key) {
    for (final report in reports) {
      final value = report.values[key];
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  void _onVideoInboundStatsReports(List<StatsReport> reports) {
    if (reports.isEmpty) {
      return;
    }

    final videoInboundRtp = reports.first;

    final jitterBufferEmittedCount =
        videoInboundRtp.values['jitterBufferEmittedCount'];
    final jitterBufferDelay = videoInboundRtp.values['jitterBufferDelay'];
    final framesReceived = videoInboundRtp.values['framesReceived'];
    final framesDecoded = videoInboundRtp.values['framesDecoded'];
    final framesDropped = videoInboundRtp.values['framesDropped'];
    final totalDecodeTime = videoInboundRtp.values['totalDecodeTime'];
    final bytesReceived = videoInboundRtp.values['bytesReceived'];
    final headerBytesReceived = videoInboundRtp.values['headerBytesReceived'];
    final keyFramesDecoded = videoInboundRtp.values['keyFramesDecoded'];
    final packetsReceived = videoInboundRtp.values['packetsReceived'];
    final decoderName = videoInboundRtp.values['decoderImplementation'];
    final frameWidth = videoInboundRtp.values['frameWidth'];
    final frameHeight = videoInboundRtp.values['frameHeight'];
    final framesPerSecond = videoInboundRtp.values['framesPerSecond'];
    final packetsLost = videoInboundRtp.values['packetsLost'];
    final jitter = videoInboundRtp.values['jitter'];
    final pauseCount = videoInboundRtp.values['pauseCount'];
    final powerEfficientDecoder =
        videoInboundRtp.values['powerEfficientDecoder'];
    final nackCount = videoInboundRtp.values['nackCount'];
    final firCount = videoInboundRtp.values['firCount'];
    final pliCount = videoInboundRtp.values['pliCount'];
    final freezeCount = videoInboundRtp.values['freezeCount'];
    final totalFreezesDuration = videoInboundRtp.values['totalFreezesDuration'];
    final totalPausesDuration = videoInboundRtp.values['totalPausesDuration'];
    final totalProcessingDelay = videoInboundRtp.values['totalProcessingDelay'];
    final totalAssemblyTime = videoInboundRtp.values['totalAssemblyTime'];
    final framesAssembledFromMultiplePackets =
        videoInboundRtp.values['framesAssembledFromMultiplePackets'];
    final totalInterFrameDelay = videoInboundRtp.values['totalInterFrameDelay'];
    final totalSquaredInterFrameDelay =
        videoInboundRtp.values['totalSquaredInterFrameDelay'];
    final qpSum = videoInboundRtp.values['qpSum'];

    int? framesReceivedPerSecond;
    int? framesDecodedPerSecond;
    int? framesDroppedPerSecond;
    int? bytesPerSecond;
    double? interFrameDelayPerSecond;
    double? keyFramesDecodedPerSecond;
    double? headerBytesPerSecond;
    double? packetsReceivedPerSecond;
    double? qpSumAvg;
    double? totalAssemblyTimeAvg;
    double? totalInterFrameDelayAvg;
    double? jitterBufferDelayAvg;
    double? decodeTimeAvg;

    if (_previousVideoInboundStats != null) {
      framesReceivedPerSecond =
          _diff(framesReceived, _previousVideoInboundStats!.framesReceived);
      framesDecodedPerSecond =
          _diff(framesDecoded, _previousVideoInboundStats!.framesDecoded);
      framesDroppedPerSecond =
          _diff(framesDropped, _previousVideoInboundStats!.framesDropped);
      bytesPerSecond =
          _diff(bytesReceived, _previousVideoInboundStats!.bytesReceived);
      interFrameDelayPerSecond = _diff(totalSquaredInterFrameDelay?.toDouble(),
          _previousVideoInboundStats!.totalSquaredInterFrameDelay?.toDouble());
      keyFramesDecodedPerSecond = _diff(keyFramesDecoded?.toDouble(),
          _previousVideoInboundStats!.keyFramesDecoded?.toDouble());
      headerBytesPerSecond = _diff(headerBytesReceived?.toDouble(),
          _previousVideoInboundStats!.headerBytesReceived?.toDouble());
      packetsReceivedPerSecond = _diff(packetsReceived?.toDouble(),
          _previousVideoInboundStats!.packetsReceived?.toDouble());

      qpSumAvg = _avg(
        qpSum,
        _previousVideoInboundStats!.qpSum,
        framesDecoded,
        _previousVideoInboundStats!.framesDecoded,
      );

      totalAssemblyTimeAvg = _avg(
        totalAssemblyTime,
        _previousVideoInboundStats!.totalAssemblyTime,
        framesAssembledFromMultiplePackets,
        _previousVideoInboundStats!.framesAssembledFromMultiplePackets,
      );

      totalInterFrameDelayAvg = _avg(
        totalInterFrameDelay,
        _previousVideoInboundStats!.totalInterFrameDelay,
        framesDecoded,
        _previousVideoInboundStats!.framesDecoded,
      );

      jitterBufferDelayAvg = _avg(
        jitterBufferDelay,
        _previousVideoInboundStats!.jitterBufferDelay,
        jitterBufferEmittedCount,
        _previousVideoInboundStats!.jitterBufferEmittedCount,
      );

      decodeTimeAvg = _avg(
        totalDecodeTime,
        _previousVideoInboundStats!.totalDecodeTime,
        framesDecoded,
        _previousVideoInboundStats!.framesDecoded,
      );
    }

    final stats = RtcVideoInboundStats(
      decoderName: decoderName,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      framesPerSecond: framesPerSecond,
      bytesReceived: bytesReceived,
      packetsReceived: packetsReceived,
      qpSum: qpSum,
      qpSumAvg: qpSumAvg,
      keyFramesDecoded: keyFramesDecoded,
      packetsLost: packetsLost,
      jitter: jitter,
      pauseCount: pauseCount,
      powerEfficientDecoder: powerEfficientDecoder,
      nackCount: nackCount,
      firCount: firCount,
      pliCount: pliCount,
      freezeCount: freezeCount,
      totalFreezesDuration: totalFreezesDuration,
      totalPausesDuration: totalPausesDuration,
      headerBytesReceived: headerBytesReceived,
      totalProcessingDelay: totalProcessingDelay,
      totalInterFrameDelay: totalInterFrameDelay,
      totalInterFrameDelayAvg: totalInterFrameDelayAvg,
      totalSquaredInterFrameDelay: totalSquaredInterFrameDelay,
      totalAssemblyTime: totalAssemblyTime,
      framesAssembledFromMultiplePackets: framesAssembledFromMultiplePackets,
      totalAssemblyTimeAvg: totalAssemblyTimeAvg,
      framesDropped: framesDropped,
      framesReceived: framesReceived,
      framesDecoded: framesDecoded,
      jitterBufferEmittedCount: jitterBufferEmittedCount,
      jitterBufferDelay: jitterBufferDelay,
      jitterBufferDelayAvg: jitterBufferDelayAvg,
      decodeTime: decodeTimeAvg,
      totalDecodeTime: totalDecodeTime,
      framesReceivedPerSecond: framesReceivedPerSecond,
      framesDecodedPerSecond: framesDecodedPerSecond,
      framesDroppedPerSecond: framesDroppedPerSecond,
      bytesPerSecond: bytesPerSecond,
      interFrameDelayPerSecond: interFrameDelayPerSecond,
      keyFramesDecodedPerSecond: keyFramesDecodedPerSecond,
      headerBytesPerSecond: headerBytesPerSecond,
      packetsReceivedPerSecond: packetsReceivedPerSecond,
      timestamp: videoInboundRtp.timestamp,
    );

    publishRtcVideoInboundStats(stats);

    // update
    _previousVideoInboundStats = stats;
  }

  StatsReport? getOneTimeVideoInboundStats(List<StatsReport> reports) {
    final inboundRtps =
        reports.where((StatsReport report) => report.type == 'inbound-rtp');
    if (inboundRtps.isEmpty) return null;

    for (final report in inboundRtps) {
      if (report.values['kind'] == 'video') return report;
    }

    return null;
  }

  void _onVideoOutboundStatsReports(
    List<StatsReport> reports,
    StatsReport? selectCandidatePair,
    List<StatsReport> videoMediaSources,
  ) {
    if (reports.isEmpty) {
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
    int? keyFramesEncodedPerSecond;
    double? retransmittedPacketsSentPerSecond;
    double? headerBytesSentPerSecond;
    double? retransmittedBytesSentPerSecond;
    double? encodeTimeAvgMs;
    double? totalEncodedBytesTargetPerSecond;
    double? packetSendDelayAvgMs;
    double? qpSumAvg;

    // Calculate differences if we have previous stats
    if (_previousVideoOutboundStats != null) {
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

      keyFramesEncodedPerSecond = _diff(
          keyFramesEncoded, _previousVideoOutboundStats!.keyFramesEncoded);

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
        keyFramesEncodedPerSecond: keyFramesEncodedPerSecond,
        encodeTimeAvgMs: encodeTimeAvgMs,
        totalEncodedBytesTargetPerSecond: totalEncodedBytesTargetPerSecond,
        framesSentPerSecond: framesSentPerSecond,
        packetSendDelayAvgMs: packetSendDelayAvgMs,
        qpSumAvg: qpSumAvg);

    // get extend field
    stats.availableOutgoingBitrate =
        _getAvailableOutgoingBitrate(selectCandidatePair);
    stats.mediaSourceFramesPerSecond =
        _getMediaSourceFramesPerSecond(stats, videoMediaSources);

    // Publish the stats to subscribers
    publishRtcVideoOutboundStats(stats);

    // Update state for next calculation
    _previousVideoOutboundStats = stats;
  }

  double? _getAvailableOutgoingBitrate(
    StatsReport? selectCandidatePair,
  ) {
    if (selectCandidatePair == null) {
      return null;
    }
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

  void publishRtcVideoInboundStats(RtcVideoInboundStats stats) {
    for (final subscriber in _subscribers) {
      subscriber.updateVideoInboundStats(stats);
    }
  }

  void publishRtcVideoOutboundStats(RtcVideoOutboundStats stats) {
    for (final subscriber in _subscribers) {
      subscriber.updateVideoOutboundStats(stats);
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

  void publishPairCandidates(
      StatsReport localCandidateReport, StatsReport remoteCandidateReport) {
    for (final subscriber in _subscribers) {
      subscriber.pairCandidates(localCandidateReport, remoteCandidateReport);
    }
  }

  void publishSelectedCandidatePair(StatsReport selectedCandidatePair) {
    for (final subscriber in _subscribers) {
      subscriber.selectedCandidatePair(selectedCandidatePair);
    }
  }
}
