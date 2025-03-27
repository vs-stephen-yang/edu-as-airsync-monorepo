import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/model/rtc_stats_parser.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcStatsPresenter implements RtcStatsSubscriber {
  final int _maxVideoStats;
  final int _maxCandidates;
  final int _maxCandidatePairs;
  final int _maxCodecStats;

  final List<RtcVideoOutboundStats> _videoStats = [];
  final Map<String, RtcIceCandidate> _localCandidates = {};
  final Map<String, RtcIceCandidate> _remoteCandidates = {};
  final Map<String, RtcIceCandidatePairStats> _candidatePairs = {};
  final Map<String, RtcCodecStats> _codecStats = {};
  late RTCSessionDescription? _localSDP;
  late RTCSessionDescription? _remoteSDP;

  Function(List<RtcVideoOutboundStats> stats)? onVideoStatsPresent;
  Function(Map<String, RtcIceCandidate> candidates)? onLocalCandidatesPresent;
  Function(Map<String, RtcIceCandidate> candidates)? onRemoteCandidatesPresent;
  Function(Map<String, RtcIceCandidatePairStats> pairs)? onCandidatePairPresent;
  Function(Map<String, RtcCodecStats> stats)? onCodecStatsPresent;
  Function(RTCSessionDescription sdp)? onLocalSDPPresent;
  Function(RTCSessionDescription sdp)? onRemoteSDPPresent;

  RtcStatsPresenter(
      {int maxVideoStats = 300,
        int maxCandidates = 10,
        int maxCandidatePairs = 100,
        int maxCodecStats = 10})
      : _maxCodecStats = maxCodecStats,
        _maxCandidatePairs = maxCandidatePairs,
        _maxCandidates = maxCandidates,
        _maxVideoStats = maxVideoStats;

  @override
  void updateVideoStats(RtcVideoOutboundStats stats) {
    if (_videoStats.length >= _maxVideoStats) {
      _videoStats.removeAt(0);
    }
    _videoStats.add(stats);
    onVideoStatsPresent?.call(_videoStats);
  }

  @override
  void updateLocalCandidate(List<StatsReport> reports) {
    _addCandidatesToMap(reports, _localCandidates);
    onLocalCandidatesPresent?.call(_localCandidates);
  }

  @override
  void updateRemoteCandidate(List<StatsReport> reports) {
    _addCandidatesToMap(reports, _remoteCandidates);
    onRemoteCandidatesPresent?.call(_remoteCandidates);
  }

  void _addCandidatesToMap(
      List<StatsReport> reports,
      Map<String, RtcIceCandidate> candidateMap,
      ) {
    for (final report in reports) {
      final id = report.id as String?;
      if (id == null) {
        continue;
      }

      if (candidateMap.containsKey(id)) {
        continue;
      }

      if (candidateMap.length >= _maxCandidates) {
        final firstKey = candidateMap.keys.first;
        candidateMap.remove(firstKey);
      }

      candidateMap[id] = RtcIceCandidate.fromMap(report.values);
    }
  }

  @override
  void updateCandidatePairStats(StatsReport report) {
    if (!_candidatePairs.containsKey(report.id)) {
      if (_candidatePairs.length >= _maxCandidatePairs) {
        final firstKey = _candidatePairs.keys.first;
        _candidatePairs.remove(firstKey);
      }
    }

    _candidatePairs[report.id] =
        RtcIceCandidatePairStats.fromMap(report.values);
    onCandidatePairPresent?.call(_candidatePairs);
  }

  @override
  void updateCodecStats(StatsReport report) {
    if (!_codecStats.containsKey(report.id)) {
      if (_codecStats.length >= _maxCodecStats) {
        final firstKey = _codecStats.keys.first;
        _codecStats.remove(firstKey);
      }
    }

    _codecStats[report.id] = RtcCodecStats.fromMap(report.values);
    onCodecStatsPresent?.call(_codecStats);
  }

  void setLocalSDP(RTCSessionDescription sdp) {
    _localSDP = sdp;
    onLocalSDPPresent?.call(_localSDP!);
  }

  void setRemoteSDP(RTCSessionDescription sdp) {
    _remoteSDP = sdp;
    onRemoteSDPPresent?.call(_remoteSDP!);
  }

  Map<String, List<RtcIceCandidate>> getCandidates() {
    final result = <String, List<RtcIceCandidate>>{};

    result['local'] = _localCandidates.values.toList();
    result['remote'] = _remoteCandidates.values.toList();

    return result;
  }
}
