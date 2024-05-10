import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcStatsParser {
  Function(String localCandidateType, String remoteCandidateType)?
      onPairCandidateType;

  Function(double fps)? onFpsReport;

  RtcStatsParser(
    this.onFpsReport,
    this.onPairCandidateType,
  );

  void onStatsReports(List<StatsReport> reports) {
    // create Map from candidate-pair reports
    final candidatePairs = reports
        .where((StatsReport report) => report.type == 'candidate-pair')
        .toList();
    final candidatePairMap = Map<String, StatsReport>.fromIterable(
        candidatePairs,
        key: (report) => report.id,
        value: (report) => report);

    // get active transport
    final transports = reports
        .where((StatsReport report) => report.type == 'transport')
        .toList();
    final bytesSend = transports
        .map((StatsReport report) => report.values['bytesSent'])
        .firstWhere((value) => value != null, orElse: () => null);

    if (bytesSend != null && bytesSend != 0) {
      // get selectedCandidatePairId
      final selectedCandidatePairId = transports
          .map((StatsReport report) => report.values['selectedCandidatePairId'])
          .firstWhere((value) => value != null, orElse: () => null);

      // get selected candidate pair
      final selectedCandidatePair = candidatePairMap[selectedCandidatePairId];

      // get local and remote candidate id
      final localCandidateId =
          selectedCandidatePair?.values['localCandidateId'];
      final remoteCandidateId =
          selectedCandidatePair?.values['remoteCandidateId'];

      // find selected local and remote candidate reports
      final localCandidates = reports
          .where((StatsReport report) => report.type == 'local-candidate')
          .toList();
      final remoteCandidates = reports
          .where((StatsReport report) => report.type == 'remote-candidate')
          .toList();

      _onPairCandidatesReports(
          localCandidates.firstWhere(
              (StatsReport report) => report.id == localCandidateId),
          remoteCandidates.firstWhere(
              (StatsReport report) => report.id == remoteCandidateId));
    }

    // find video inbound-rtp reports
    final inboundRtps = reports
        .where((StatsReport report) => report.type == 'inbound-rtp')
        .toList();
    final videoInboundRtps = inboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    _onVideoStatsReports(videoInboundRtps);
  }

  void _onPairCandidatesReports(
      StatsReport localCandidateReport, StatsReport remoteCandidateReport) {
    final localCandidateType = localCandidateReport.values['candidateType'];
    final remoteCandidateType = remoteCandidateReport.values['candidateType'];
    if (localCandidateType != null && remoteCandidateType != null) {
      onPairCandidateType?.call(
          localCandidateType as String, remoteCandidateType as String);
    }
  }

  void _onVideoStatsReports(List<StatsReport> reports) {
    if (reports.isEmpty) {
      return;
    }

    final videoInboundRtp = reports.first;
    final framesPerSecond = videoInboundRtp.values['framesPerSecond'];

    if (framesPerSecond != null) {
      onFpsReport?.call(framesPerSecond as double);
    }
  }
}
