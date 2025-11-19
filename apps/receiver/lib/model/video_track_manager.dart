import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/model/rtc_stats_parser.dart';
import 'package:display_flutter/model/rtc_stats_reporter.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_sdk_flutter/flutter_ion.dart';

/// Track information for multi-track management
class TrackInfo {
  final MediaStreamTrack track;
  final String trackId;
  final RemoteStream remoteStream;
  RtcVideoInboundStats? latestStats;
  int nullFpsCount = 0; // Consecutive FPS null count
  int zeroFpsCount = 0; // Consecutive FPS zero count

  TrackInfo(this.track, this.trackId, this.remoteStream);

  bool get hasValidFps =>
      latestStats?.framesDecodedPerSecond != null &&
      latestStats!.framesDecodedPerSecond! > 0;

  int? get fps => latestStats?.framesDecodedPerSecond;
}

/// Callback when active track changes
typedef OnActiveTrackChanged = void Function(
  String? oldTrackId,
  String newTrackId,
  RemoteStream stream,
);

/// Callback when a track is removed
typedef OnTrackRemoved = void Function(
  String trackId,
  String reason,
);

/// Callback when stats are collected for the active track
typedef OnActiveTrackStatsCollected = void Function(RtcVideoInboundStats stats);

/// Manages multiple video tracks with FPS-based validation and selection
class VideoTrackManager {
  VideoTrackManager({
    this.onActiveTrackChanged,
    this.onTrackRemoved,
    this.onActiveTrackStatsCollected,
    this.maxZeroFpsCount = 3,
  });

  final OnActiveTrackChanged? onActiveTrackChanged;
  final OnTrackRemoved? onTrackRemoved;
  final OnActiveTrackStatsCollected? onActiveTrackStatsCollected;
  final int maxZeroFpsCount;

  // Track storage
  final Map<String, TrackInfo> _tracks = {};
  final Map<String, RtcStatsParser> _parsers = {};
  final Map<String, RtcStatsReporter> _reporters = {};

  String? _activeTrackId;

  /// Add a new video track
  void addTrack(MediaStreamTrack track, RemoteStream stream) {
    // Use track.id if available, fallback to hashCode
    final trackId = track.id ?? track.hashCode.toString();

    _tracks[trackId] = TrackInfo(track, trackId, stream);
    log.info(
        'VideoTrackManager: Track added $trackId, total tracks: ${_tracks.length}');

    // If this is the first track, set it as active
    if (_tracks.length == 1) {
      _activeTrackId = trackId;
    }
  }

  /// Remove a specific track
  void removeTrack(String trackId) {
    _tracks.remove(trackId);
    _parsers.remove(trackId);
    _reporters.remove(trackId);

    log.info(
        'VideoTrackManager: Track $trackId removed, remaining: ${_tracks.length}');

    // If we removed the active track, select a new one
    if (_activeTrackId == trackId) {
      _updateActiveTrack();
    }
  }

  /// Collect stats for all tracks and update active track
  Future<void> collectStats(Client client) async {
    for (var entry in _tracks.entries) {
      final trackId = entry.key;
      final trackInfo = entry.value;

      try {
        // Get stats for this specific track
        final reports = await client.getSubStats(trackInfo.track);
        // Create or reuse parser for this track (must reuse to maintain state for delta calculations)
        // Parser and reporter are created together and reused across all stats collections
        final parser = _parsers.putIfAbsent(trackId, () {
          log.info(
              'VideoTrackManager: Creating stats parser and reporter for track $trackId');

          final newParser = RtcStatsParser();

          // Create reporter that updates trackInfo
          final reporter = RtcStatsReporter(
            (RtcVideoInboundStats stats) {
              trackInfo.latestStats = stats;
              log.info(
                  'VideoTrackManager: Track stats - $trackId: FPS=${stats.framesDecodedPerSecond}, '
                  'resolution=${stats.frameWidth}x${stats.frameHeight}, '
                  'bitrate=${stats.bytesPerSecond}');

              // Notify only if this is the active track
              if (trackId == _activeTrackId) {
                onActiveTrackStatsCollected?.call(stats);
              }
            },
            (RtcVideoOutboundStats stats) {},
            (String localCandidateType, String remoteCandidateType) {},
            (RtcIceCandidatePairStats stats) {},
          );

          // Store reporter for cleanup later
          _reporters[trackId] = reporter;

          // Add subscriber once during creation
          newParser.addSubscriber(reporter);

          return newParser;
        });

        // Parse stats (reporter is already subscribed)
        parser.onStatsReports(reports);
      } catch (e) {
        log.warning(
            'VideoTrackManager: Failed to get stats for track $trackId: $e');
      }
    }

    // Clean up invalid tracks
    _cleanupInvalidTracks();

    // Update active track
    _updateActiveTrack();
  }

  /// Remove tracks with invalid FPS
  void _cleanupInvalidTracks() {
    final tracksToRemove = <String>[];

    for (var entry in _tracks.entries) {
      final trackId = entry.key;
      final trackInfo = entry.value;

      if (trackInfo.latestStats == null ||
          trackInfo.latestStats!.framesDecodedPerSecond == null) {
        // FPS is null - increment counter
        trackInfo.nullFpsCount++;
        trackInfo.zeroFpsCount = 0; // Reset zero counter

        log.info(
            'VideoTrackManager: Track $trackId has null FPS (count: ${trackInfo.nullFpsCount})');

        // Only remove after consecutive null FPS (same threshold as zero FPS)
        if (trackInfo.nullFpsCount >= maxZeroFpsCount) {
          final reason = 'Consecutive null FPS count=${trackInfo.nullFpsCount}';
          log.info(
              'VideoTrackManager: Removing track $trackId, reason: $reason');
          tracksToRemove.add(trackId);
          onTrackRemoved?.call(trackId, reason);
        }
      } else if (trackInfo.latestStats!.framesDecodedPerSecond == 0) {
        // FPS is zero - reset null counter, increment zero counter
        trackInfo.nullFpsCount = 0; // Reset null counter
        trackInfo.zeroFpsCount++;

        log.info(
            'VideoTrackManager: Track $trackId has zero FPS (count: ${trackInfo.zeroFpsCount})');

        if (trackInfo.zeroFpsCount >= maxZeroFpsCount) {
          final reason = 'Consecutive zero FPS count=${trackInfo.zeroFpsCount}';
          log.info(
              'VideoTrackManager: Removing track $trackId, reason: $reason');
          tracksToRemove.add(trackId);
          onTrackRemoved?.call(trackId, reason);
        }
      } else {
        // FPS > 0 - reset all counters
        trackInfo.nullFpsCount = 0;
        trackInfo.zeroFpsCount = 0;
      }
    }

    // Remove invalid tracks
    for (var trackId in tracksToRemove) {
      _tracks.remove(trackId);
      _parsers.remove(trackId);
      _reporters.remove(trackId);
    }
  }

  /// Select and render the active track
  void _updateActiveTrack() {
    // Get all tracks with valid FPS (in insertion order)
    final validTracks =
        _tracks.entries.where((entry) => entry.value.hasValidFps).toList();

    if (validTracks.isEmpty) {
      log.info('VideoTrackManager: No valid tracks available');
      _activeTrackId = null;
      return;
    }

    // Find the first valid track
    final firstValidTrackId = validTracks.first.key;

    // Check if we need to switch
    if (_activeTrackId != firstValidTrackId) {
      final oldTrackId = _activeTrackId;
      _activeTrackId = firstValidTrackId;

      // Get track info and notify
      final trackInfo = _tracks[firstValidTrackId]!;
      log.info(
          'VideoTrackManager: Switching active track from $oldTrackId to $firstValidTrackId, '
          'FPS: ${trackInfo.fps}');

      onActiveTrackChanged?.call(
        oldTrackId,
        firstValidTrackId,
        trackInfo.remoteStream,
      );
    }
  }

  /// Get the number of tracks
  int getTrackCount() => _tracks.length;

  /// Check if in multi-track mode (more than one track)
  bool isMultiTrackMode() => _tracks.length > 1;

  /// Get the active track ID
  String? getActiveTrackId() => _activeTrackId;

  /// Get the active track info
  TrackInfo? getActiveTrack() {
    if (_activeTrackId == null) return null;
    return _tracks[_activeTrackId];
  }

  /// Get all tracks
  List<TrackInfo> getAllTracks() => _tracks.values.toList();

  /// Dispose and clean up all resources
  void dispose() {
    _tracks.clear();
    _parsers.clear();
    _reporters.clear();
    _activeTrackId = null;
    log.info('VideoTrackManager: Disposed');
  }
}
