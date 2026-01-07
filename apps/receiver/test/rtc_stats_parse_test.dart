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
      parser.addSubscriber(mockReporter);
      parser.addSubscriber(mockPresenter);
    });

    test('Should correctly parse and pair candidates', () {
      // Arrange
      final localCandidate1 = StatsReport('LC01', 'local-candidate', 0, {});
      final localCandidate2 = StatsReport('LC02', 'local-candidate', 0, {});
      final remoteCandidate1 = StatsReport('RC01', 'remote-candidate', 0, {});
      final remoteCandidate2 = StatsReport('RC02', 'remote-candidate', 0, {});
      final candidatePair1 = StatsReport('CP01', 'candidate-pair', 0,
          {'localCandidateId': 'LC01', 'remoteCandidateId': 'RC01'});
      final candidatePair2 = StatsReport('CP02', 'candidate-pair', 0,
          {'localCandidateId': 'LC02', 'remoteCandidateId': 'RC02'});
      final transport = StatsReport('T01', 'transport', 0,
          {'bytesSent': 1000, 'selectedCandidatePairId': 'CP01'});

      final reports = [
        transport,
        candidatePair1,
        localCandidate1,
        remoteCandidate1,
        candidatePair2,
        localCandidate2,
        remoteCandidate2,
        StatsReport('IR01', 'inbound-rtp', 0, {'kind': 'video'})
      ];

      // Act
      parser.onStatsReports(reports);

      // Assert
      verify(mockReporter.pairCandidates(localCandidate1, remoteCandidate1))
          .called(1);
      verify(mockReporter.selectedCandidatePair(candidatePair1)).called(1);

      verify(mockPresenter
          .updateLocalCandidate([localCandidate1, localCandidate2])).called(1);
      verify(mockPresenter
              .updateRemoteCandidate([remoteCandidate1, remoteCandidate2]))
          .called(1);
      verify(mockPresenter.updateCandidatePairStats(candidatePair1)).called(1);
      verify(mockPresenter.updateCandidatePairStats(candidatePair2)).called(1);
    });

    test('Should not pair candidates when bytesSent is zero', () {
      // Arrange
      final reports = [
        StatsReport('T01', 'transport', 0,
            {'bytesSent': 0, 'selectedCandidatePairId': 'CP01'})
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
        'packetsDiscarded': 2,
        'fecBytesReceived': 12345,
        'fecPacketsReceived': 7,
        'fecPacketsDiscarded': 1,
        'retransmittedPacketsReceived': 9,
        'retransmittedBytesReceived': 5678,
        'jitter': 5.2,
        'pauseCount': 0,
        'jitterBufferEmittedCount': 980,
        'jitterBufferDelay': 2.5,
        'jitterBufferTargetDelay': 3.5,
        'jitterBufferMinimumDelay': 0.6,
        'totalDecodeTime': 15.0,
        'powerEfficientDecoder': true,
        'qpSum': 1000,
        'nackCount': 26,
        'firCount': 2,
        'pliCount': 1,
        'freezeCount': 5,
        'totalFreezesDuration': 3.537,
        'keyFramesDecoded': 1,
        'framesRendered': 975,
        'totalInterFrameDelay': 110.464,
        'totalSquaredInterFrameDelay': 28.5005,
        'totalPausesDuration': 0.0,
        'totalAssemblyTime': 64.272,
        'framesAssembledFromMultiplePackets': 588,
        'headerBytesReceived': 140480,
        'totalProcessingDelay': 346.802,
        'totalSamplesReceived': 2000,
        'concealedSamples': 11,
        'silentConcealedSamples': 12,
        'concealmentEvents': 13,
        'insertedSamplesForDeceleration': 14,
        'removedSamplesForAcceleration': 15,
        'audioLevel': 0.05,
        'totalAudioEnergy': 1.2,
        'totalSamplesDuration': 3.4,
        'totalCorruptionProbability': 0.7,
        'totalSquaredCorruptionProbability': 0.49,
        'corruptionMeasurements': 8,
      });

      final reports = [videoReport];

      // Act
      parser.onStatsReports(reports);

      // Assert
      verify(mockReporter.updateVideoInboundStats(argThat(
              isA<RtcVideoInboundStats>()
                  .having((s) => s.decoderName, 'decoderName', 'vp8')
                  .having((s) => s.frameWidth, 'frameWidth', 1280)
                  .having((s) => s.frameHeight, 'frameHeight', 720)
                  .having((s) => s.framesPerSecond, 'framesPerSecond', 30.0)
                  .having((s) => s.bytesReceived, 'bytesReceived', 500000)
                  .having((s) => s.packetsLost, 'packetsLost', 5)
                  .having((s) => s.packetsReceived, 'packetsReceived', 1000)
                  .having((s) => s.packetsDiscarded, 'packetsDiscarded', 2)
                  .having((s) => s.fecBytesReceived, 'fecBytesReceived', 12345)
                  .having((s) => s.framesRendered, 'framesRendered', 975)
                  .having((s) => s.audioLevel, 'audioLevel', 0.05)
                  .having((s) => s.jitter, 'jitter', 5.2))))
          .called(1);

      verify(mockPresenter.updateVideoInboundStats(argThat(isA<
                  RtcVideoInboundStats>()
              .having((s) => s.frameWidth, 'frameWidth', 1280)
              .having((s) => s.frameHeight, 'frameHeight', 720)
              .having((s) => s.framesPerSecond, 'framesPerSecond', 30.0)
              .having((s) => s.bytesReceived, 'bytesReceived', 500000)
              .having((s) => s.packetsLost, 'packetsLost', 5)
              .having((s) => s.packetsReceived, 'packetsReceived', 1000)
              .having((s) => s.jitter, 'jitter', 5.2)
              .having(
                  (s) => s.powerEfficientDecoder, 'powerEfficientDecoder', true)
              .having((s) => s.qpSum, 'qpSum', 1000)
              .having((s) => s.nackCount, 'nackCount', 26)
              .having((s) => s.firCount, 'firCount', 2)
              .having((s) => s.pliCount, 'pliCount', 1)
              .having((s) => s.freezeCount, 'freezeCount', 5)
              .having(
                  (s) => s.totalFreezesDuration, 'totalFreezesDuration', 3.537)
              .having((s) => s.keyFramesDecoded, 'keyFramesDecoded', 1)
              .having((s) => s.framesRendered, 'framesRendered', 975)
              .having((s) => s.jitterBufferTargetDelay,
                  'jitterBufferTargetDelay', 3.5)
              .having((s) => s.jitterBufferMinimumDelay,
                  'jitterBufferMinimumDelay', 0.6)
              .having(
                  (s) => s.totalSamplesReceived, 'totalSamplesReceived', 2000)
              .having((s) => s.totalAudioEnergy, 'totalAudioEnergy', 1.2)
              .having((s) => s.totalCorruptionProbability,
                  'totalCorruptionProbability', 0.7)
              .having((s) => s.totalInterFrameDelay, 'totalInterFrameDelay',
                  110.464)
              .having((s) => s.totalSquaredInterFrameDelay,
                  'totalSquaredInterFrameDelay', 28.5005)
              .having((s) => s.pauseCount, 'pauseCount', 0)
              .having((s) => s.totalPausesDuration, 'totalPausesDuration', 0.0)
              .having((s) => s.totalAssemblyTime, 'totalAssemblyTime', 64.272)
              .having((s) => s.framesAssembledFromMultiplePackets,
                  'framesAssembledFromMultiplePackets', 588)
              .having((s) => s.framesDropped, 'framesDropped', 10)
              .having((s) => s.framesReceived, 'framesReceived', 1000)
              .having((s) => s.framesDecoded, 'framesDecoded', 990)
              .having((s) => s.jitterBufferDelay, 'jitterBufferDelay', 2.5)
              .having((s) => s.jitterBufferEmittedCount,
                  'jitterBufferEmittedCount', 980)
              .having(
                  (s) => s.headerBytesReceived, 'headerBytesReceived', 140480)
              .having((s) => s.totalProcessingDelay, 'totalProcessingDelay',
                  346.802)
              .having((s) => s.totalDecodeTime, 'totalDecodeTime', 15.0))))
          .called(1);
    });

    test('Given two inbound-rtp reports, processing stats twice', () {
      // Arrange
      final videoReport1 = StatsReport('IR01', 'inbound-rtp', 1000, {
        'kind': 'video',
        'decoderImplementation': 'vp8',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'framesReceived': 1000,
        'framesDecoded': 1000,
        'framesDropped': 10,
        'bytesReceived': 500000,
        'packetsLost': 5,
        'packetsReceived': 1000,
        'packetsDiscarded': 3,
        'fecBytesReceived': 1000,
        'fecPacketsReceived': 4,
        'fecPacketsDiscarded': 5,
        'retransmittedPacketsReceived': 6,
        'retransmittedBytesReceived': 6000,
        'jitter': 5.2,
        'pauseCount': 0,
        'jitterBufferEmittedCount': 1000,
        'jitterBufferDelay': 2000.0, // Makes avg calculation clean (2.0)
        'jitterBufferTargetDelay': 1500.0,
        'jitterBufferMinimumDelay': 100.0,
        'totalDecodeTime': 5000.0, // Makes avg calculation clean (5.0)
        'powerEfficientDecoder': true,
        'qpSum': 10000, // Makes avg calculation clean (10.0)
        'nackCount': 20,
        'firCount': 0,
        'pliCount': 0,
        'freezeCount': 5,
        'totalFreezesDuration': 3.0,
        'keyFramesDecoded': 10,
        'framesRendered': 1000,
        'totalInterFrameDelay': 5000.0, // Makes avg calculation clean (5.0)
        'totalSquaredInterFrameDelay': 20000.0,
        'totalPausesDuration': 0.0,
        'totalAssemblyTime': 2000.0, // Makes avg calculation clean (2.0)
        'framesAssembledFromMultiplePackets': 1000,
        'headerBytesReceived': 100000,
        'totalProcessingDelay': 300.0,
        'totalSamplesReceived': 10000,
        'concealedSamples': 200,
        'silentConcealedSamples': 100,
        'concealmentEvents': 20,
        'insertedSamplesForDeceleration': 30,
        'removedSamplesForAcceleration': 40,
        'audioLevel': 0.1,
        'totalAudioEnergy': 5.0,
        'totalSamplesDuration': 9.0,
        'totalCorruptionProbability': 0.2,
        'totalSquaredCorruptionProbability': 0.05,
        'corruptionMeasurements': 10,
      });

      // Second report - 1 second later with increments that produce clean per-second rates
      final videoReport2 = StatsReport('IR01', 'inbound-rtp', 2000, {
        'kind': 'video',
        'decoderImplementation': 'vp8',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'framesReceived': 1030, // +30 per second
        'framesDecoded': 1025, // +25 per second
        'framesDropped': 15, // +5 per second
        'bytesReceived': 550000, // +50000 per second
        'packetsLost': 6,
        'packetsReceived': 1050, // +50 per second
        'packetsDiscarded': 6, // +3
        'fecBytesReceived': 1200, // +200
        'fecPacketsReceived': 7, // +3
        'fecPacketsDiscarded': 8, // +3
        'retransmittedPacketsReceived': 9, // +3
        'retransmittedBytesReceived': 6600, // +600
        'jitter': 5.3,
        'pauseCount': 0,
        'jitterBufferEmittedCount': 1025,
        'jitterBufferDelay': 2050.0, // Makes avg calculation clean
        'jitterBufferTargetDelay': 1550.0, // Makes avg calculation clean
        'jitterBufferMinimumDelay': 120.0,
        'totalDecodeTime': 5125.0, // Makes avg calculation clean
        'powerEfficientDecoder': true,
        'qpSum': 10250, // Makes avg calculation clean
        'nackCount': 22,
        'firCount': 1,
        'pliCount': 1,
        'freezeCount': 6,
        'totalFreezesDuration': 3.5,
        'keyFramesDecoded': 12, // +2 per second
        'framesRendered': 1030, // +30 per second
        'totalInterFrameDelay': 5125.0, // Makes avg calculation clean
        'totalSquaredInterFrameDelay': 21000.0, // +1000 per second
        'totalPausesDuration': 0.0,
        'totalAssemblyTime': 2050.0, // Makes avg calculation clean
        'framesAssembledFromMultiplePackets': 1025,
        'headerBytesReceived': 105000, // +5000 per second
        'totalProcessingDelay': 350.0,
        'totalSamplesReceived': 10100, // +100 per second
        'concealedSamples': 205, // +5
        'silentConcealedSamples': 102, // +2
        'concealmentEvents': 25, // +5
        'insertedSamplesForDeceleration': 34, // +4
        'removedSamplesForAcceleration': 44, // +4
        'audioLevel': 0.2,
        'totalAudioEnergy': 7.0, // +2
        'totalSamplesDuration': 10.5, // +1.5
        'totalCorruptionProbability': 0.5, // +0.3
        'totalSquaredCorruptionProbability': 0.11, // +0.06
        'corruptionMeasurements': 12, // +2
      });

      // Act
      parser.onStatsReports([videoReport1]);
      parser.onStatsReports([videoReport2]);

      // Assert
      final reporterVerify =
          verify(mockReporter.updateVideoInboundStats(captureAny));
      reporterVerify.called(2);
      final reporterSecondCall =
          reporterVerify.captured[1] as RtcVideoInboundStats;
      expect(
          reporterSecondCall,
          isA<RtcVideoInboundStats>()
              .having((s) => s.framesReceivedPerSecond,
                  'framesReceivedPerSecond', 30)
              .having(
                  (s) => s.framesDecodedPerSecond, 'framesDecodedPerSecond', 25)
              .having(
                  (s) => s.framesDroppedPerSecond, 'framesDroppedPerSecond', 5)
              .having((s) => s.framesRenderedPerSecond,
                  'framesRenderedPerSecond', 30)
              .having((s) => s.bytesPerSecond, 'bytesPerSecond', 50000)
              .having(
                  (s) => s.totalInterFrameDelayVariancePerSecond,
                  'totalInterFrameDelayVariancePerSecond',
                  closeTo(15.9722, 0.0001))
              .having((s) => s.decodeTime, 'decodeTimeAvg', 5.0));

      final presenterVerify =
          verify(mockPresenter.updateVideoInboundStats(captureAny));
      presenterVerify.called(2);
      final presenterSecondCall =
          presenterVerify.captured[1] as RtcVideoInboundStats;
      expect(
          presenterSecondCall,
          isA<RtcVideoInboundStats>()
              .having((s) => s.packetsReceivedPerSecond,
                  'packetsReceivedPerSecond', 50)
              .having((s) => s.packetsLostPerSecond, 'packetsLostPerSecond', 1)
              .having((s) => s.keyFramesDecodedPerSecond,
                  'keyFramesDecodedPerSecond', 2)
              .having((s) => s.headerBytesReceivedPerSecond,
                  'headerBytesReceivedPerSecond', 5000)
              .having(
                  (s) => s.totalInterFrameDelayVariancePerSecond,
                  'totalInterFrameDelayVariancePerSecond',
                  closeTo(15.9722, 0.0001))
              .having((s) => s.totalDecodeTimePerSecond,
                  'totalDecodeTimePerSecond', 125.0)
              .having((s) => s.totalAssemblyTimePerSecond,
                  'totalAssemblyTimePerSecond', 50.0)
              .having((s) => s.fecBytesReceivedPerSecond,
                  'fecBytesReceivedPerSecond', 200)
              .having((s) => s.retransmittedBytesReceivedPerSecond,
                  'retransmittedBytesReceivedPerSecond', 600)
              .having((s) => s.jitterBufferTargetDelayPerSecond,
                  'jitterBufferTargetDelayPerSecond', 50.0)
              .having((s) => s.jitterBufferMinimumDelayPerSecond,
                  'jitterBufferMinimumDelayPerSecond', 20.0)
              .having((s) => s.totalSamplesDurationPerSecond,
                  'totalSamplesDurationPerSecond', 1.5)
              .having((s) => s.totalCorruptionProbabilityPerSecond,
                  'totalCorruptionProbabilityPerSecond', 0.3)
              // Averages
              .having(
                  (s) => s.jitterBufferDelayAvg, 'jitterBufferDelayAvg', 2.0)
              .having((s) => s.decodeTime, 'decodeTimeAvg', 5.0)
              .having(
                  (s) => s.totalAssemblyTimeAvg, 'totalAssemblyTimeAvg', 2.0)
              .having((s) => s.totalInterFrameDelayAvg,
                  'totalInterFrameDelayAvg', 5.0)
              .having((s) => s.qpSumAvg, 'qpSumAvg', 10.0));
    });

    test('should return the first video inbound-rtp report', () {
      final reports = [
        StatsReport('1', 'inbound-rtp', 123.0, {'kind': 'audio'}),
        StatsReport('2', 'inbound-rtp', 124.0, {'kind': 'video'}),
        StatsReport('3', 'inbound-rtp', 125.0, {'kind': 'video'}),
        StatsReport('4', 'outbound-rtp', 126.0, {'kind': 'video'}),
      ];

      final result = parser.getOneTimeVideoInboundStats(reports);

      expect(result!.id, '2');
      expect(result.type, 'inbound-rtp');
      expect(result.values['kind'], 'video');
    });

    test('should return null if no video inbound-rtp report exists', () {
      final reports = [
        StatsReport('1', 'inbound-rtp', 123.0, {'kind': 'audio'}),
        StatsReport('2', 'outbound-rtp', 124.0, {'kind': 'video'}),
      ];

      final result = parser.getOneTimeVideoInboundStats(reports);

      expect(result, isNull);
    });
  });
}
