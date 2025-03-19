// ignore_for_file: invalid_use_of_internal_member

import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/model/rtc_stats_parser.dart';
import 'package:display_flutter/model/rtc_stats_presenter.dart';
import 'package:display_flutter/model/rtc_stats_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';


import 'rtc_stats_parse_test.mocks.dart';
@GenerateMocks([RtcStatsReporter, RtcStatsPresenter])

void main() {
  group('RtcStatsParser - _onStatsReports', () {
    late RtcStatsParser parser;
    late MockRtcStatsReporter mockReporter;
    late MockRtcStatsPresenter mockPresenter;

    setUp(() {
      mockReporter = MockRtcStatsReporter();
      mockPresenter = MockRtcStatsPresenter();
      parser = RtcStatsParser();
      parser.setReporter(mockReporter);
      parser.setPresenter(mockPresenter);
    });

    test('Should correctly parse and pair candidates', () {
      // Arrange
      final localCandidate1 = StatsReport('LC01', 'local-candidate', 0,{});
      final localCandidate2 = StatsReport('LC02', 'local-candidate', 0,{});
      final remoteCandidate1 = StatsReport('RC01', 'remote-candidate',0,{});
      final remoteCandidate2 = StatsReport('RC02', 'remote-candidate',0,{});
      final candidatePair1 = StatsReport('CP01', 'candidate-pair', 0, {
        'localCandidateId': 'LC01',
        'remoteCandidateId': 'RC01'
      });
      final candidatePair2 = StatsReport('CP02', 'candidate-pair', 0, {
        'localCandidateId': 'LC02',
        'remoteCandidateId': 'RC02'
      });
      final transport = StatsReport('T01','transport',0,{
        'bytesSent': 1000,
        'selectedCandidatePairId': 'CP01'
      });

      final reports = [
        transport,
        candidatePair1,
        localCandidate1,
        remoteCandidate1,
        candidatePair2,
        localCandidate2,
        remoteCandidate2,
        StatsReport('IR01','inbound-rtp',0,{'kind': 'video'})
      ];

      // Act
      parser.onStatsReports(reports);

      // Assert
      verify(mockReporter.pairCandidates(localCandidate1, remoteCandidate1)).called(1);
      verify(mockReporter.selectedCandidatePair(candidatePair1)).called(1);

      verify(mockPresenter.addLocalCandidate([localCandidate1, localCandidate2])).called(1);
      verify(mockPresenter.addRemoteCandidate([remoteCandidate1, remoteCandidate2])).called(1);
      verify(mockPresenter.addCandidatePairStats(candidatePair1)).called(1);
      verify(mockPresenter.addCandidatePairStats(candidatePair2)).called(1);
    });

    test('Should not pair candidates when bytesSent is zero', () {
      // Arrange
      final reports = [
        StatsReport('T01','transport',0,{
          'bytesSent': 0,
          'selectedCandidatePairId': 'CP01'
        })
      ];

      // Act
      parser.onStatsReports(reports);

      // Assert
      verifyNever(mockReporter.pairCandidates(any, any));
      verifyNever(mockReporter.selectedCandidatePair(any));
    });

    test('Should process video inbound-rtp report', () {
      // Arrange
      final videoReport = StatsReport('IR01', 'inbound-rtp', 0, {
        'kind': 'video',
        'decoderImplementation': 'vp8',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'framesReceived': 1000,
        'framesDecoded': 990,
        'framesDropped': 10,
        'bytesReceived': 500000,
        'packetsLost': 5,
        'packetsReceived': 1000,
        'jitter': 5.2,
        'pauseCount': 0,
        'jitterBufferEmittedCount': 980,
        'jitterBufferDelay': 2.5,
        'totalDecodeTime': 15.0,
        'powerEfficientDecoder': true,
        'qpSum': 1000,
      });

      final reports = [videoReport];

      // Act
      parser.onStatsReports(reports);

      // Assert
      verify(mockReporter.videoInboundStats(argThat(
          isA<RtcVideoInboundStats>()
              .having((s) => s.decoderName, 'decoderName', 'vp8')
              .having((s) => s.frameWidth, 'frameWidth', 1280)
              .having((s) => s.frameHeight, 'frameHeight', 720)
              .having((s) => s.framesPerSecond, 'framesPerSecond', 30.0)
              .having((s) => s.bytesReceived, 'bytesReceived', 500000)
              .having((s) => s.packetsLost, 'packetsLost', 5)
              .having((s) => s.packetsReceived, 'packetsReceived', 1000)
              .having((s) => s.jitter, 'jitter', 5.2)
      ))).called(1);

      verify(mockPresenter.addVideoStats(argThat(
          isA<RtcVideoInboundStatsForPresenter>()
              .having((s) => s.frameWidth, 'frameWidth', 1280)
              .having((s) => s.frameHeight, 'frameHeight', 720)
              .having((s) => s.framesPerSecond, 'framesPerSecond', 30.0)
              .having((s) => s.bytesReceived, 'bytesReceived', 500000)
              .having((s) => s.packetsLost, 'packetsLost', 5)
              .having((s) => s.packetsReceived, 'packetsReceived', 1000)
              .having((s) => s.jitter, 'jitter', 5.2)
              .having((s) => s.powerEfficientDecoder, 'powerEfficientDecoder', true)
              .having((s) => s.qpSum, 'qpSum', 1000)
      ))).called(1);
    });

    test('Given two inbound-rtp reports, processing stats twice', () {
      // Arrange
      final videoReport1 = StatsReport('IR01', 'inbound-rtp', 0, {
        'kind': 'video',
        'decoderImplementation': 'vp8',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'framesReceived': 1000,
        'framesDecoded': 990,
        'framesDropped': 10,
        'bytesReceived': 500000,
        'packetsLost': 5,
        'packetsReceived': 1000,
        'jitter': 5.2,
        'pauseCount': 0,
        'jitterBufferEmittedCount': 980,
        'jitterBufferDelay': 2.5,
        'totalDecodeTime': 15.0,
      });

      final videoReport2 = StatsReport('IR01', 'inbound-rtp', 0, {
        'kind': 'video',
        'decoderImplementation': 'vp8',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'framesReceived': 1100,
        'framesDecoded': 1080,
        'framesDropped': 20,
        'bytesReceived': 600000,
        'packetsLost': 6,
        'packetsReceived': 1100,
        'jitter': 5.3,
        'pauseCount': 0,
        'jitterBufferEmittedCount': 1080,
        'jitterBufferDelay': 3.0,
        'totalDecodeTime': 18.0,
      });

      // Act
      parser.onStatsReports([videoReport1]);
      parser.onStatsReports([videoReport2]);


      // Assert
      final capturedStats = verify(mockReporter.videoInboundStats(captureAny)).captured.last as RtcVideoInboundStats;

      // Print all fields to see actual values
      print('📊 Captured Stats:');
      print('decoderName: ${capturedStats.decoderName}');
      print('frameWidth: ${capturedStats.frameWidth}');
      print('frameHeight: ${capturedStats.frameHeight}');
      print('framesPerSecond: ${capturedStats.framesPerSecond}');
      print('bytesReceived: ${capturedStats.bytesReceived}');
      print('packetsLost: ${capturedStats.packetsLost}');
      print('packetsReceived: ${capturedStats.packetsReceived}');
      print('jitter: ${capturedStats.jitter}');
      print('jitterBufferDelay: ${capturedStats.jitterBufferDelay}');
      print('decodeTime: ${capturedStats.decodeTime}');
      print('bytesPerSecond: ${capturedStats.bytesPerSecond}');
      print('framesReceivedPerSecond: ${capturedStats.framesReceivedPerSecond}');
      print('framesDecodedPerSecond: ${capturedStats.framesDecodedPerSecond}');
      print('framesDroppedPerSecond: ${capturedStats.framesDroppedPerSecond}');
    });
  });
}
