// Add these test cases to rtc_stats_parse_test.dart or create a new test file

import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/model/rtc_stats_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  // Existing test groups here...

  group('RtcStatsPresenter', () {
    late RtcStatsPresenter presenter;

    setUp(() {
      presenter = RtcStatsPresenter(
        maxVideoInboundStats: 3,
        maxCandidates: 2,
        maxCandidatePairs: 2,
        maxCodecStats: 2,
      );
    });

    test('Should add and maintain limited video stats with callback', () {
      // Arrange
      final List<List<RtcVideoInboundStats>> callbackResults = [];
      presenter.onVideoStatsPresent = (stats) {
        callbackResults.add(List.from(stats));
      };

      final stats1 = RtcVideoInboundStats(
        timestamp: 1000.0,
        frameWidth: 1280,
        frameHeight: 720,
      );
      final stats2 = RtcVideoInboundStats(
        timestamp: 2000.0,
        frameWidth: 1280,
        frameHeight: 720,
      );
      final stats3 = RtcVideoInboundStats(
        timestamp: 3000.0,
        frameWidth: 1280,
        frameHeight: 720,
      );
      final stats4 = RtcVideoInboundStats(
        timestamp: 4000.0,
        frameWidth: 1280,
        frameHeight: 720,
      );

      // Act
      presenter.updateVideoInboundStats(stats1);
      presenter.updateVideoInboundStats(stats2);
      presenter.updateVideoInboundStats(stats3);
      presenter.updateVideoInboundStats(stats4);

      // Assert
      expect(callbackResults.length, equals(4));
      expect(callbackResults[0].length, equals(1));
      expect(callbackResults[1].length, equals(2));
      expect(callbackResults[2].length, equals(3));
      expect(callbackResults[3].length,
          equals(3)); // Still 3 because of maxVideoStats

      // Verify oldest entry was removed in the latest result
      final latestResult = callbackResults.last;
      expect(latestResult.any((s) => s.timestamp == 1000.0), isFalse);
      expect(latestResult.any((s) => s.timestamp == 2000.0), isTrue);
      expect(latestResult.any((s) => s.timestamp == 3000.0), isTrue);
      expect(latestResult.any((s) => s.timestamp == 4000.0), isTrue);
    });

    test('Should update local candidates with limit and callback', () {
      // Arrange
      final Map<String, Map<String, RtcIceCandidate>> callbackResults = {};
      presenter.onLocalCandidatesPresent = (candidates) {
        callbackResults['latest'] = Map.from(candidates);
      };

      final localCandidate1 = StatsReport('LC01', 'local-candidate', 0, {
        'candidateType': 'host',
        'ip': '192.168.1.1',
        'port': 12345,
        'protocol': 'udp',
      });

      final localCandidate2 = StatsReport('LC02', 'local-candidate', 0, {
        'candidateType': 'srflx',
        'ip': '203.0.113.1',
        'port': 54321,
        'protocol': 'udp',
      });

      final localCandidate3 = StatsReport('LC03', 'local-candidate', 0, {
        'candidateType': 'relay',
        'ip': '198.51.100.1',
        'port': 12345,
        'protocol': 'tcp',
      });

      // Act
      presenter.updateLocalCandidate([localCandidate1]);
      presenter.updateLocalCandidate([localCandidate2]);
      presenter.updateLocalCandidate([localCandidate3]);

      // Assert
      expect(callbackResults['latest']?.length, equals(2)); // Maximum is 2
      expect(callbackResults['latest']?.containsKey('LC01'),
          isFalse); // First one should be removed
      expect(callbackResults['latest']?.containsKey('LC02'), isTrue);
      expect(callbackResults['latest']?.containsKey('LC03'), isTrue);

      // Verify candidate properties
      final candidate2 = callbackResults['latest']?['LC02'];
      expect(candidate2?.candidateType, equals('srflx'));
      expect(candidate2?.ip, equals('203.0.113.1'));
      expect(candidate2?.port, equals(54321));
      expect(candidate2?.protocol, equals('udp'));
    });

    test('Should update remote candidates with limit and callback', () {
      // Arrange
      final Map<String, Map<String, RtcIceCandidate>> callbackResults = {};
      presenter.onRemoteCandidatesPresent = (candidates) {
        callbackResults['latest'] = Map.from(candidates);
      };

      final remoteCandidate1 = StatsReport('RC01', 'remote-candidate', 0, {
        'candidateType': 'host',
        'ip': '192.168.1.2',
        'port': 23456,
        'protocol': 'udp',
      });

      final remoteCandidate2 = StatsReport('RC02', 'remote-candidate', 0, {
        'candidateType': 'srflx',
        'ip': '203.0.113.2',
        'port': 65432,
        'protocol': 'udp',
      });

      final remoteCandidate3 = StatsReport('RC03', 'remote-candidate', 0, {
        'candidateType': 'relay',
        'ip': '198.51.100.2',
        'port': 23456,
        'protocol': 'tcp',
      });

      // Act
      presenter.updateRemoteCandidate([remoteCandidate1]);
      presenter.updateRemoteCandidate([remoteCandidate2]);
      presenter.updateRemoteCandidate([remoteCandidate3]);

      // Assert
      expect(callbackResults['latest']?.length, equals(2)); // Maximum is 2
      expect(callbackResults['latest']?.containsKey('RC01'),
          isFalse); // First one should be removed
      expect(callbackResults['latest']?.containsKey('RC02'), isTrue);
      expect(callbackResults['latest']?.containsKey('RC03'), isTrue);
    });

    test('Should update candidate pair stats with callback', () {
      // Arrange
      final Map<String, Map<String, RtcIceCandidatePairStats>> callbackResults =
          {};
      presenter.onCandidatePairPresent = (pairs) {
        callbackResults['latest'] = Map.from(pairs);
      };

      final candidatePair1 = StatsReport('CP01', 'candidate-pair', 0, {
        'state': 'succeeded',
        'currentRoundTripTime': 0.035,
      });

      final candidatePair2 = StatsReport('CP02', 'candidate-pair', 0, {
        'state': 'waiting',
        'currentRoundTripTime': 0.055,
      });

      final candidatePair3 = StatsReport('CP02', 'candidate-pair', 0, {
        'state': 'failed',
        'currentRoundTripTime': 0.12,
      });

      // Act
      presenter.updateCandidatePairStats(candidatePair1);
      presenter.updateCandidatePairStats(candidatePair2);
      presenter.updateCandidatePairStats(candidatePair3);

      // Assert
      expect(callbackResults['latest']?.length, equals(2)); // Maximum is 2
      expect(callbackResults['latest']?.containsKey('CP01'), isTrue);
      expect(callbackResults['latest']?.containsKey('CP02'), isTrue);

      // Verify pair properties
      final pair2 = callbackResults['latest']?['CP02'];
      expect(pair2?.state, equals('failed'));
      expect(pair2?.currentRoundTripTime, equals(0.12));
    });

    test('Should update codec stats with limit and callback', () {
      // Arrange
      final Map<String, Map<String, RtcCodecStats>> callbackResults = {};
      presenter.onCodecStatsPresent = (stats) {
        callbackResults['latest'] = Map.from(stats);
      };

      final codecStats1 = StatsReport('CD01', 'codec', 0, {
        'mimeType': 'video/VP8',
        'clockRate': 90000,
        'payloadType': 96,
      });

      final codecStats2 = StatsReport('CD02', 'codec', 0, {
        'mimeType': 'video/H264',
        'clockRate': 90000,
        'payloadType': 97,
      });

      final codecStats3 = StatsReport('CD03', 'codec', 0, {
        'mimeType': 'audio/opus',
        'clockRate': 48000,
        'payloadType': 111,
      });

      // Act
      presenter.updateCodecStats(codecStats1);
      presenter.updateCodecStats(codecStats2);
      presenter.updateCodecStats(codecStats3);

      // Assert
      expect(callbackResults['latest']?.length, equals(2)); // Maximum is 2
      expect(callbackResults['latest']?.containsKey('CD01'),
          isFalse); // First one should be removed
      expect(callbackResults['latest']?.containsKey('CD02'), isTrue);
      expect(callbackResults['latest']?.containsKey('CD03'), isTrue);

      // Verify codec properties
      final codec2 = callbackResults['latest']?['CD02'];
      expect(codec2?.mimeType, equals('video/H264'));
      expect(codec2?.clockRate, equals(90000));
      expect(codec2?.payloadType, equals(97));

      final codec3 = callbackResults['latest']?['CD03'];
      expect(codec3?.mimeType, equals('audio/opus'));
      expect(codec3?.clockRate, equals(48000));
      expect(codec3?.payloadType, equals(111));
    });
  });
}
