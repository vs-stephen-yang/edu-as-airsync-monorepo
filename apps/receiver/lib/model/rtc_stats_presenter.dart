import 'package:display_flutter/model/rtc_stats.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcStatsPresenter {
  final int maxVideoStats;
  final int maxCandidates;
  final int maxCandidatePairs;
  final int maxCodecStats;

  final List<RtcVideoInboundStatsForPresenter> _videoStats = [];
  final Map<String, RtcIceCandidate> _localCandidates = {};
  final Map<String, RtcIceCandidate> _remoteCandidates = {};
  final Map<String, RtcIceCandidatePairStats> _candidatePairs = {};
  final Map<String, RtcCodecStats> _codecStats = {};
  late RTCSessionDescription? _localSDP;
  late RTCSessionDescription? _remoteSDP;

  Function(List<RtcVideoInboundStatsForPresenter> stats)? onVideoStatsPresent;
  Function(Map<String, RtcIceCandidate> candidates)? onLocalCandidatesPresent;
  Function(Map<String, RtcIceCandidate> candidates)? onRemoteCandidatesPresent;
  Function(Map<String, RtcIceCandidatePairStats> pairs)? onCandidatePairPresent;
  Function(Map<String, RtcCodecStats> stats)? onCodecStatsPresent;
  Function(RTCSessionDescription sdp)? onLocalSDPPresent;
  Function(RTCSessionDescription sdp)? onRemoteSDPPresent;

  RtcStatsPresenter(
      {this.maxVideoStats = 300,
      this.maxCandidates = 10,
      this.maxCandidatePairs = 100,
      this.maxCodecStats = 10});

  void addVideoStats(RtcVideoInboundStatsForPresenter stats) {
    if (_videoStats.length >= maxVideoStats) {
      _videoStats.removeAt(0);
    }
    _videoStats.add(stats);
    onVideoStatsPresent?.call(_videoStats);
  }

  void addLocalCandidate(List<StatsReport> reports) {
    _addCandidatesToMap(reports, _localCandidates);
    onLocalCandidatesPresent?.call(_localCandidates);
  }

  void addRemoteCandidate(List<StatsReport> reports) {
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

      if (candidateMap.length >= maxCandidates) {
        final firstKey = candidateMap.keys.first;
        candidateMap.remove(firstKey);
      }

      candidateMap[id] = RtcIceCandidate.fromMap(report.values);
    }
  }

  void addCandidatePairStats(StatsReport report) {
    if (_candidatePairs.containsKey(report.id)) {
      return;
    }

    if (_candidatePairs.length >= maxCandidates) {
      final firstKey = _candidatePairs.keys.first;
      _candidatePairs.remove(firstKey);
    }

    _candidatePairs[report.id] =
        RtcIceCandidatePairStats.fromMap(report.values);
    onCandidatePairPresent?.call(_candidatePairs);
  }

  void addCodecStats(StatsReport report) {
    if (_codecStats.containsKey(report.id)) {
      return;
    }

    if (_codecStats.length >= maxCodecStats) {
      final firstKey = _codecStats.keys.first;
      _codecStats.remove(firstKey);
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
}
