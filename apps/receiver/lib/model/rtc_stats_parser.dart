import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

dynamic _diff(dynamic a, dynamic b) {
  if (a == null || b == null) {
    return null;
  }
  return a - b;
}

int? _diffInt(dynamic a, dynamic b) {
  final result = _diff(a, b);
  if (result is num) {
    return result.toInt();
  }
  return null;
}

double? _diffDouble(dynamic a, dynamic b) {
  final result = _diff(a, b);
  if (result is num) {
    return result.toDouble();
  }
  return null;
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

double? _varianceFromTotals(
  double? sum,
  double? squaredSum,
  int? count,
) {
  if (sum == null || squaredSum == null || count == null || count <= 0) {
    return null;
  }
  final countDouble = count.toDouble();
  final variance = (squaredSum - (sum * sum) / countDouble) / countDouble;
  if (variance.isNaN || variance.isInfinite) {
    return null;
  }
  return variance < 0 ? 0 : variance;
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
    final values = videoInboundRtp.values;

    final decoderName = values['decoderImplementation'];
    final frameWidth = values['frameWidth'];
    final frameHeight = values['frameHeight'];
    final framesPerSecond = (values['framesPerSecond'] as num?)?.toDouble();

    // Packet and byte counters
    final bytesReceived = values['bytesReceived'];
    final headerBytesReceived = values['headerBytesReceived'];
    final packetsReceived = values['packetsReceived'];
    final packetsLost = values['packetsLost'];
    final packetsDiscarded = values['packetsDiscarded'];
    final fecBytesReceived = values['fecBytesReceived'];
    final fecPacketsReceived = values['fecPacketsReceived'];
    final fecPacketsDiscarded = values['fecPacketsDiscarded'];
    final retransmittedPacketsReceived = values['retransmittedPacketsReceived'];
    final retransmittedBytesReceived = values['retransmittedBytesReceived'];

    // Frame counters
    final framesDecoded = values['framesDecoded'];
    final framesRendered = values['framesRendered'];
    final framesDropped = values['framesDropped'];
    final framesReceived = values['framesReceived'];
    final framesAssembledFromMultiplePackets =
        values['framesAssembledFromMultiplePackets'];
    final keyFramesDecoded = values['keyFramesDecoded'];

    // Quality/jitter
    final jitter = (values['jitter'] as num?)?.toDouble();
    final pauseCount = values['pauseCount'];
    final totalPausesDuration = values['totalPausesDuration'];
    final freezeCount = values['freezeCount'];
    final totalFreezesDuration = values['totalFreezesDuration'];

    // Timing/processing
    final jitterBufferDelay = values['jitterBufferDelay'];
    final jitterBufferTargetDelay = values['jitterBufferTargetDelay'];
    final jitterBufferMinimumDelay = values['jitterBufferMinimumDelay'];
    final jitterBufferEmittedCount = values['jitterBufferEmittedCount'];
    final totalProcessingDelay = values['totalProcessingDelay'];
    final totalDecodeTime = values['totalDecodeTime'];
    final totalInterFrameDelay = values['totalInterFrameDelay'];
    final totalSquaredInterFrameDelay = values['totalSquaredInterFrameDelay'];
    final totalAssemblyTime = values['totalAssemblyTime'];

    // Codec and control counters
    final qpSum = values['qpSum'];
    final nackCount = values['nackCount'];
    final firCount = values['firCount'];
    final pliCount = values['pliCount'];

    // Audio-related metrics
    final totalSamplesReceived = values['totalSamplesReceived'];
    final concealedSamples = values['concealedSamples'];
    final silentConcealedSamples = values['silentConcealedSamples'];
    final concealmentEvents = values['concealmentEvents'];
    final insertedSamplesForDeceleration =
        values['insertedSamplesForDeceleration'];
    final removedSamplesForAcceleration =
        values['removedSamplesForAcceleration'];
    final audioLevel = (values['audioLevel'] as num?)?.toDouble();
    final totalAudioEnergy = values['totalAudioEnergy'];
    final totalSamplesDuration = values['totalSamplesDuration'];

    // Corruption probabilities
    final totalCorruptionProbability = values['totalCorruptionProbability'];
    final totalSquaredCorruptionProbability =
        values['totalSquaredCorruptionProbability'];
    final corruptionMeasurements = values['corruptionMeasurements'];

    final powerEfficientDecoder = values['powerEfficientDecoder'];

    // Per-second metrics
    int? packetsReceivedPerSecond;
    int? packetsLostPerSecond;
    int? packetsDiscardedPerSecond;
    int? fecBytesReceivedPerSecond;
    int? fecPacketsReceivedPerSecond;
    int? fecPacketsDiscardedPerSecond;
    int? retransmittedPacketsReceivedPerSecond;
    int? retransmittedBytesReceivedPerSecond;
    int? framesReceivedPerSecond;
    int? framesDecodedPerSecond;
    int? framesDroppedPerSecond;
    int? framesRenderedPerSecond;
    int? framesAssembledFromMultiplePacketsPerSecond;
    int? keyFramesDecodedPerSecond;
    int? nackCountPerSecond;
    int? firCountPerSecond;
    int? pliCountPerSecond;
    int? bytesReceivedPerSecond;
    int? bytesPerSecond;
    int? headerBytesReceivedPerSecond;
    double? headerBytesPerSecond;
    double? qpSumPerSecond;
    double? totalDecodeTimePerSecond;
    double? totalInterFrameDelayPerSecond;
    double? totalSquaredInterFrameDelayPerSecond;
    double? totalInterFrameDelayVariancePerSecond;
    int? pauseCountPerSecond;
    double? totalPausesDurationPerSecond;
    int? freezeCountPerSecond;
    double? totalFreezesDurationPerSecond;
    double? totalProcessingDelayPerSecond;
    double? jitterBufferDelayPerSecond;
    double? jitterBufferTargetDelayPerSecond;
    double? jitterBufferMinimumDelayPerSecond;
    int? jitterBufferEmittedCountPerSecond;
    double? totalAssemblyTimePerSecond;
    double? totalAudioEnergyPerSecond;
    double? totalSamplesDurationPerSecond;
    int? totalSamplesReceivedPerSecond;
    int? concealedSamplesPerSecond;
    int? silentConcealedSamplesPerSecond;
    int? concealmentEventsPerSecond;
    int? insertedSamplesForDecelerationPerSecond;
    int? removedSamplesForAccelerationPerSecond;
    double? totalCorruptionProbabilityPerSecond;
    double? totalSquaredCorruptionProbabilityPerSecond;
    int? corruptionMeasurementsPerSecond;

    // Averages
    double? qpSumAvg;
    double? totalAssemblyTimeAvg;
    double? totalInterFrameDelayAvg;
    double? jitterBufferDelayAvg;
    double? decodeTimeAvg;

    if (_previousVideoInboundStats != null) {
      final previous = _previousVideoInboundStats!;

      packetsReceivedPerSecond =
          _diffInt(packetsReceived, previous.packetsReceived);
      packetsLostPerSecond = _diffInt(packetsLost, previous.packetsLost);
      packetsDiscardedPerSecond =
          _diffInt(packetsDiscarded, previous.packetsDiscarded);
      fecBytesReceivedPerSecond =
          _diffInt(fecBytesReceived, previous.fecBytesReceived);
      fecPacketsReceivedPerSecond =
          _diffInt(fecPacketsReceived, previous.fecPacketsReceived);
      fecPacketsDiscardedPerSecond =
          _diffInt(fecPacketsDiscarded, previous.fecPacketsDiscarded);
      retransmittedPacketsReceivedPerSecond = _diffInt(
          retransmittedPacketsReceived, previous.retransmittedPacketsReceived);
      retransmittedBytesReceivedPerSecond = _diffInt(
          retransmittedBytesReceived, previous.retransmittedBytesReceived);

      framesReceivedPerSecond =
          _diffInt(framesReceived, previous.framesReceived);
      framesDecodedPerSecond = _diffInt(framesDecoded, previous.framesDecoded);
      framesDroppedPerSecond = _diffInt(framesDropped, previous.framesDropped);
      framesRenderedPerSecond =
          _diffInt(framesRendered, previous.framesRendered);
      framesAssembledFromMultiplePacketsPerSecond = _diffInt(
          framesAssembledFromMultiplePackets,
          previous.framesAssembledFromMultiplePackets);
      keyFramesDecodedPerSecond =
          _diffInt(keyFramesDecoded, previous.keyFramesDecoded);

      nackCountPerSecond = _diffInt(nackCount, previous.nackCount);
      firCountPerSecond = _diffInt(firCount, previous.firCount);
      pliCountPerSecond = _diffInt(pliCount, previous.pliCount);
      bytesReceivedPerSecond = _diffInt(bytesReceived, previous.bytesReceived);
      bytesPerSecond = bytesReceivedPerSecond;
      headerBytesReceivedPerSecond =
          _diffInt(headerBytesReceived, previous.headerBytesReceived);
      headerBytesPerSecond =
          _diffDouble(headerBytesReceived, previous.headerBytesReceived);

      qpSumPerSecond = _diffDouble(qpSum, previous.qpSum);
      totalDecodeTimePerSecond =
          _diffDouble(totalDecodeTime, previous.totalDecodeTime);
      totalInterFrameDelayPerSecond =
          _diffDouble(totalInterFrameDelay, previous.totalInterFrameDelay);

      final totalSquaredInterFrameDelayPerSecond = _diffDouble(
          totalSquaredInterFrameDelay, previous.totalSquaredInterFrameDelay);

      totalInterFrameDelayVariancePerSecond = _varianceFromTotals(
        totalInterFrameDelayPerSecond,
        totalSquaredInterFrameDelayPerSecond,
        framesRenderedPerSecond,
      );

      pauseCountPerSecond = _diffInt(pauseCount, previous.pauseCount);
      totalPausesDurationPerSecond =
          _diffDouble(totalPausesDuration, previous.totalPausesDuration);
      freezeCountPerSecond = _diffInt(freezeCount, previous.freezeCount);
      totalFreezesDurationPerSecond =
          _diffDouble(totalFreezesDuration, previous.totalFreezesDuration);
      totalProcessingDelayPerSecond =
          _diffDouble(totalProcessingDelay, previous.totalProcessingDelay);
      jitterBufferDelayPerSecond =
          _diffDouble(jitterBufferDelay, previous.jitterBufferDelay);
      jitterBufferTargetDelayPerSecond = _diffDouble(
          jitterBufferTargetDelay, previous.jitterBufferTargetDelay);
      jitterBufferMinimumDelayPerSecond = _diffDouble(
          jitterBufferMinimumDelay, previous.jitterBufferMinimumDelay);
      jitterBufferEmittedCountPerSecond =
          _diffInt(jitterBufferEmittedCount, previous.jitterBufferEmittedCount);
      totalAssemblyTimePerSecond =
          _diffDouble(totalAssemblyTime, previous.totalAssemblyTime);

      totalSamplesReceivedPerSecond =
          _diffInt(totalSamplesReceived, previous.totalSamplesReceived);
      concealedSamplesPerSecond =
          _diffInt(concealedSamples, previous.concealedSamples);
      silentConcealedSamplesPerSecond =
          _diffInt(silentConcealedSamples, previous.silentConcealedSamples);
      concealmentEventsPerSecond =
          _diffInt(concealmentEvents, previous.concealmentEvents);
      insertedSamplesForDecelerationPerSecond = _diffInt(
          insertedSamplesForDeceleration,
          previous.insertedSamplesForDeceleration);
      removedSamplesForAccelerationPerSecond = _diffInt(
          removedSamplesForAcceleration,
          previous.removedSamplesForAcceleration);
      totalAudioEnergyPerSecond =
          _diffDouble(totalAudioEnergy, previous.totalAudioEnergy);
      totalSamplesDurationPerSecond =
          _diffDouble(totalSamplesDuration, previous.totalSamplesDuration);
      totalCorruptionProbabilityPerSecond = _diffDouble(
          totalCorruptionProbability, previous.totalCorruptionProbability);
      totalSquaredCorruptionProbabilityPerSecond = _diffDouble(
          totalSquaredCorruptionProbability,
          previous.totalSquaredCorruptionProbability);
      corruptionMeasurementsPerSecond =
          _diffInt(corruptionMeasurements, previous.corruptionMeasurements);

      qpSumAvg = _avg(
        qpSum,
        previous.qpSum,
        framesDecoded,
        previous.framesDecoded,
      );

      totalAssemblyTimeAvg = _avg(
        totalAssemblyTime,
        previous.totalAssemblyTime,
        framesAssembledFromMultiplePackets,
        previous.framesAssembledFromMultiplePackets,
      );

      totalInterFrameDelayAvg = _avg(
        totalInterFrameDelay,
        previous.totalInterFrameDelay,
        framesDecoded,
        previous.framesDecoded,
      );

      jitterBufferDelayAvg = _avg(
        jitterBufferDelay,
        previous.jitterBufferDelay,
        jitterBufferEmittedCount,
        previous.jitterBufferEmittedCount,
      );

      decodeTimeAvg = _avg(
        totalDecodeTime,
        previous.totalDecodeTime,
        framesDecoded,
        previous.framesDecoded,
      );
    }

    final stats = RtcVideoInboundStats(
      decoderName: decoderName,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      framesPerSecond: framesPerSecond,
      timestamp: videoInboundRtp.timestamp,
      bytesReceived: bytesReceived,
      headerBytesReceived: headerBytesReceived,
      packetsReceived: packetsReceived,
      packetsLost: packetsLost,
      packetsDiscarded: packetsDiscarded,
      fecBytesReceived: fecBytesReceived,
      fecPacketsReceived: fecPacketsReceived,
      fecPacketsDiscarded: fecPacketsDiscarded,
      retransmittedPacketsReceived: retransmittedPacketsReceived,
      retransmittedBytesReceived: retransmittedBytesReceived,
      framesDecoded: framesDecoded,
      framesRendered: framesRendered,
      framesDropped: framesDropped,
      framesReceived: framesReceived,
      framesAssembledFromMultiplePackets: framesAssembledFromMultiplePackets,
      keyFramesDecoded: keyFramesDecoded,
      jitter: jitter,
      pauseCount: pauseCount,
      totalPausesDuration: totalPausesDuration,
      freezeCount: freezeCount,
      totalFreezesDuration: totalFreezesDuration,
      jitterBufferDelay: jitterBufferDelay,
      jitterBufferTargetDelay: jitterBufferTargetDelay,
      jitterBufferMinimumDelay: jitterBufferMinimumDelay,
      jitterBufferEmittedCount: jitterBufferEmittedCount,
      totalProcessingDelay: totalProcessingDelay,
      totalDecodeTime: totalDecodeTime,
      totalInterFrameDelay: totalInterFrameDelay,
      totalSquaredInterFrameDelay: totalSquaredInterFrameDelay,
      totalAssemblyTime: totalAssemblyTime,
      qpSum: qpSum,
      nackCount: nackCount,
      firCount: firCount,
      pliCount: pliCount,
      totalSamplesReceived: totalSamplesReceived,
      concealedSamples: concealedSamples,
      silentConcealedSamples: silentConcealedSamples,
      concealmentEvents: concealmentEvents,
      insertedSamplesForDeceleration: insertedSamplesForDeceleration,
      removedSamplesForAcceleration: removedSamplesForAcceleration,
      audioLevel: audioLevel,
      totalAudioEnergy: totalAudioEnergy,
      totalSamplesDuration: totalSamplesDuration,
      totalCorruptionProbability: totalCorruptionProbability,
      totalSquaredCorruptionProbability: totalSquaredCorruptionProbability,
      corruptionMeasurements: corruptionMeasurements,
      powerEfficientDecoder: powerEfficientDecoder,
      packetsReceivedPerSecond: packetsReceivedPerSecond,
      packetsLostPerSecond: packetsLostPerSecond,
      packetsDiscardedPerSecond: packetsDiscardedPerSecond,
      fecBytesReceivedPerSecond: fecBytesReceivedPerSecond,
      fecPacketsReceivedPerSecond: fecPacketsReceivedPerSecond,
      fecPacketsDiscardedPerSecond: fecPacketsDiscardedPerSecond,
      retransmittedPacketsReceivedPerSecond:
          retransmittedPacketsReceivedPerSecond,
      retransmittedBytesReceivedPerSecond: retransmittedBytesReceivedPerSecond,
      framesDecodedPerSecond: framesDecodedPerSecond,
      framesRenderedPerSecond: framesRenderedPerSecond,
      framesDroppedPerSecond: framesDroppedPerSecond,
      framesReceivedPerSecond: framesReceivedPerSecond,
      framesAssembledFromMultiplePacketsPerSecond:
          framesAssembledFromMultiplePacketsPerSecond,
      keyFramesDecodedPerSecond: keyFramesDecodedPerSecond,
      nackCountPerSecond: nackCountPerSecond,
      firCountPerSecond: firCountPerSecond,
      pliCountPerSecond: pliCountPerSecond,
      bytesReceivedPerSecond: bytesReceivedPerSecond,
      bytesPerSecond: bytesPerSecond,
      headerBytesReceivedPerSecond: headerBytesReceivedPerSecond,
      headerBytesPerSecond: headerBytesPerSecond,
      qpSumPerSecond: qpSumPerSecond,
      totalDecodeTimePerSecond: totalDecodeTimePerSecond,
      totalInterFrameDelayPerSecond: totalInterFrameDelayPerSecond,
      totalSquaredInterFrameDelayPerSecond:
          totalSquaredInterFrameDelayPerSecond,
      totalInterFrameDelayVariancePerSecond:
          totalInterFrameDelayVariancePerSecond,
      pauseCountPerSecond: pauseCountPerSecond,
      totalPausesDurationPerSecond: totalPausesDurationPerSecond,
      freezeCountPerSecond: freezeCountPerSecond,
      totalFreezesDurationPerSecond: totalFreezesDurationPerSecond,
      totalProcessingDelayPerSecond: totalProcessingDelayPerSecond,
      jitterBufferDelayPerSecond: jitterBufferDelayPerSecond,
      jitterBufferTargetDelayPerSecond: jitterBufferTargetDelayPerSecond,
      jitterBufferMinimumDelayPerSecond: jitterBufferMinimumDelayPerSecond,
      jitterBufferEmittedCountPerSecond: jitterBufferEmittedCountPerSecond,
      totalAssemblyTimePerSecond: totalAssemblyTimePerSecond,
      totalAudioEnergyPerSecond: totalAudioEnergyPerSecond,
      totalSamplesDurationPerSecond: totalSamplesDurationPerSecond,
      totalSamplesReceivedPerSecond: totalSamplesReceivedPerSecond,
      concealedSamplesPerSecond: concealedSamplesPerSecond,
      silentConcealedSamplesPerSecond: silentConcealedSamplesPerSecond,
      concealmentEventsPerSecond: concealmentEventsPerSecond,
      insertedSamplesForDecelerationPerSecond:
          insertedSamplesForDecelerationPerSecond,
      removedSamplesForAccelerationPerSecond:
          removedSamplesForAccelerationPerSecond,
      totalCorruptionProbabilityPerSecond: totalCorruptionProbabilityPerSecond,
      totalSquaredCorruptionProbabilityPerSecond:
          totalSquaredCorruptionProbabilityPerSecond,
      corruptionMeasurementsPerSecond: corruptionMeasurementsPerSecond,
      decodeTime: decodeTimeAvg,
      totalInterFrameDelayAvg: totalInterFrameDelayAvg,
      totalAssemblyTimeAvg: totalAssemblyTimeAvg,
      jitterBufferDelayAvg: jitterBufferDelayAvg,
      qpSumAvg: qpSumAvg,
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
