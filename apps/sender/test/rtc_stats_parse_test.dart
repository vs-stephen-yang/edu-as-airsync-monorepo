import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/model/rtc_stats_parser.dart';
import 'package:display_cast_flutter/model/rtc_stats_presenter.dart';
import 'package:display_cast_flutter/model/rtc_stats_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

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
      parser = RtcStatsParser((int? x, int? y) {});
      parser.addSubscriber(mockReporter);
      parser.addSubscriber(mockPresenter);
    });

    test('Should process video outbound-rtp report', () {
      // Arrange
      final videoReport = StatsReport('OR01', 'outbound-rtp', 0, {
        'kind': 'video',
        'encoderImplementation': 'vp8',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'contentType': 'realtime',
        'qualityLimitationReason': 'bandwidth',
        'qualityLimitationDurations': '{bandwidth:0,cpu:0,none:0.72,other:0}',
        'totalEncodeTime': 25.5,
        'pliCount': 3,
        'targetBitrate': 1200000.0,
        'powerEfficientEncoder': true,
        'scalabilityMode': 'L1T3',
        'framesSent': 1200,
        'framesEncoded': 1180,
        'bytesSent': 600000,
        'packetsSent': 950,
        'packetsSentWithEct1': 12,
        'qpSum': 1500,
        'nackCount': 18,
        'firCount': 1,
        'retransmittedBytesSent': 15000,
        'retransmittedPacketsSent': 25,
        'totalPacketSendDelay': 120.5,
        'qualityLimitationResolutionChanges': 2,
        'active': true,
        'mediaSourceId': 'SV2',
        'mid': '1',
        'headerBytesSent': 98000,
        'hugeFramesSent': 5,
        'keyFramesEncoded': 10,
        'totalEncodedBytesTarget': 650000,
      });

      final reports = [videoReport];

      // Act
      parser.onStatsReports(reports);

      // Assert
      verify(mockReporter.updateVideoStats(argThat(isA<RtcVideoOutboundStats>()
              .having((s) => s.encoderImplementation, 'encoderImplementation',
                  'vp8')
              .having((s) => s.frameWidth, 'frameWidth', 1280)
              .having((s) => s.frameHeight, 'frameHeight', 720)
              .having((s) => s.framesPerSecond, 'framesPerSecond', 30.0)
              .having((s) => s.contentType, 'contentType', 'realtime')
              .having((s) => s.qualityLimitationReason,
                  'qualityLimitationReason', 'bandwidth')
              .having((s) => s.qualityLimitationDurationsNone,
                  'qualityLimitationDurationsNone', 0.72)
              .having((s) => s.qualityLimitationDurationsCpu,
                  'qualityLimitationDurationsCpu', 0.0)
              .having((s) => s.qualityLimitationDurationsBandwith,
                  'qualityLimitationDurationsBandwith', 0.0)
              .having((s) => s.qualityLimitationDurationsOther,
                  'qualityLimitationDurationsOther', 0.0)
              .having((s) => s.qualityLimitationResolutionChanges,
                  'qualityLimitationResolutionChanges', 2)
              .having((s) => s.pliCount, 'pliCount', 3)
              .having((s) => s.targetBitrate, 'targetBitrate', 1200000.0)
              .having((s) => s.scalabilityMode, 'scalabilityMode', 'L1T3')
              .having(
                  (s) => s.powerEfficientEncoder, 'powerEfficientEncoder', true)
              .having((s) => s.bytesSent, 'bytesSent', 600000)
              .having((s) => s.packetsSent, 'packetsSent', 950)
              .having((s) => s.packetsSentWithEct1, 'packetsSentWithEct1', 12)
              .having((s) => s.active, 'active', true)
              .having((s) => s.firCount, 'firCount', 1)
              .having((s) => s.framesEncoded, 'framesEncoded', 1180)
              .having((s) => s.framesSent, 'framesSent', 1200)
              .having((s) => s.headerBytesSent, 'headerBytesSent', 98000)
              .having((s) => s.hugeFramesSent, 'hugeFramesSent', 5)
              .having((s) => s.keyFramesEncoded, 'keyFramesEncoded', 10)
              .having((s) => s.nackCount, 'nackCount', 18)
              .having((s) => s.retransmittedBytesSent, 'retransmittedBytesSent',
                  15000)
              .having((s) => s.retransmittedPacketsSent,
                  'retransmittedPacketsSent', 25)
              .having((s) => s.totalEncodeTime, 'totalEncodeTime', 25.5)
              .having((s) => s.totalEncodedBytesTarget,
                  'totalEncodedBytesTarget', 650000)
              .having(
                  (s) => s.totalPacketSendDelay, 'totalPacketSendDelay', 120.5)
              .having((s) => s.qpSum, 'qpSum', 1500))))
          .called(1);

      verify(mockPresenter.updateVideoStats(argThat(isA<RtcVideoOutboundStats>()
              .having((s) => s.encoderImplementation, 'encoderImplementation',
                  'vp8')
              .having((s) => s.frameWidth, 'frameWidth', 1280)
              .having((s) => s.frameHeight, 'frameHeight', 720)
              .having((s) => s.framesPerSecond, 'framesPerSecond', 30.0)
              .having((s) => s.contentType, 'contentType', 'realtime')
              .having((s) => s.qualityLimitationReason,
                  'qualityLimitationReason', 'bandwidth')
              .having((s) => s.qualityLimitationDurationsNone,
                  'qualityLimitationDurationsNone', 0.72)
              .having((s) => s.qualityLimitationDurationsCpu,
                  'qualityLimitationDurationsCpu', 0.0)
              .having((s) => s.qualityLimitationDurationsBandwith,
                  'qualityLimitationDurationsBandwith', 0.0)
              .having((s) => s.qualityLimitationDurationsOther,
                  'qualityLimitationDurationsOther', 0.0)
              .having((s) => s.qualityLimitationResolutionChanges,
                  'qualityLimitationResolutionChanges', 2)
              .having((s) => s.pliCount, 'pliCount', 3)
              .having((s) => s.targetBitrate, 'targetBitrate', 1200000.0)
              .having((s) => s.scalabilityMode, 'scalabilityMode', 'L1T3')
              .having(
                  (s) => s.powerEfficientEncoder, 'powerEfficientEncoder', true)
              .having((s) => s.bytesSent, 'bytesSent', 600000)
              .having((s) => s.packetsSent, 'packetsSent', 950)
              .having((s) => s.packetsSentWithEct1, 'packetsSentWithEct1', 12)
              .having((s) => s.active, 'active', true)
              .having((s) => s.firCount, 'firCount', 1)
              .having((s) => s.framesEncoded, 'framesEncoded', 1180)
              .having((s) => s.framesSent, 'framesSent', 1200)
              .having((s) => s.headerBytesSent, 'headerBytesSent', 98000)
              .having((s) => s.hugeFramesSent, 'hugeFramesSent', 5)
              .having((s) => s.keyFramesEncoded, 'keyFramesEncoded', 10)
              .having((s) => s.nackCount, 'nackCount', 18)
              .having((s) => s.retransmittedBytesSent, 'retransmittedBytesSent',
                  15000)
              .having((s) => s.retransmittedPacketsSent,
                  'retransmittedPacketsSent', 25)
              .having((s) => s.totalEncodeTime, 'totalEncodeTime', 25.5)
              .having((s) => s.totalEncodedBytesTarget,
                  'totalEncodedBytesTarget', 650000)
              .having(
                  (s) => s.totalPacketSendDelay, 'totalPacketSendDelay', 120.5)
              .having((s) => s.qpSum, 'qpSum', 1500))))
          .called(1);
    });

    test(
        'Should calculate correct averages when processing outbound-rtp reports twice',
        () {
      // Arrange
      final firstReport = StatsReport('OR01', 'outbound-rtp', 1742886162000.0, {
        'kind': 'video',
        'encoderImplementation': 'libvpx',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'contentType': 'realtime',
        'qualityLimitationReason': 'bandwidth',
        'totalEncodeTime': 20.0, // Nice round numbers for clean division
        'pliCount': 2,
        'targetBitrate': 1000000.0,
        'powerEfficientEncoder': true,
        'framesSent': 1000,
        'framesEncoded': 1000,
        'bytesSent': 500000,
        'packetsSent': 800,
        'qpSum': 2000, // 2.0 average with 1000 frames
        'nackCount': 10,
        'firCount': 1,
        'retransmittedBytesSent': 10000,
        'retransmittedPacketsSent': 20,
        'totalPacketSendDelay': 80.0, // 0.1ms average with 800 packets
        'headerBytesSent': 80000,
        'hugeFramesSent': 0,
        'keyFramesEncoded': 5,
        'totalEncodedBytesTarget': 600000,
      });

      final secondReport =
          StatsReport('OR01', 'outbound-rtp', 1742886163000.0, {
        'kind': 'video',
        'encoderImplementation': 'libvpx',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
        'contentType': 'realtime',
        'qualityLimitationReason': 'bandwidth',
        'totalEncodeTime': 43.0,
        // +23.0 from first report, chosen for clean division
        'pliCount': 3,
        'targetBitrate': 1000000.0,
        'powerEfficientEncoder': true,
        'framesSent': 1200,
        // +200 from first report
        'framesEncoded': 1200,
        // +200 from first report
        'bytesSent': 600000,
        // +100000 from first report
        'packetsSent': 1000,
        // +200 from first report
        'qpSum': 3000,
        // +1000 from first report, still 2.5 average (3000/1200)
        'nackCount': 15,
        'firCount': 2,
        'retransmittedBytesSent': 15000,
        // +5000 from first report
        'retransmittedPacketsSent': 30,
        // +10 from first report
        'totalPacketSendDelay': 120.0,
        // +40.0 from first report, 120.0ms average with 1000 packets
        'headerBytesSent': 100000,
        // +20000 from first report
        'hugeFramesSent': 1,
        'keyFramesEncoded': 6,
        'totalEncodedBytesTarget': 720000,
        // +120000 from first report
      });

      // Act
      parser.onStatsReports([firstReport]);
      parser.onStatsReports([secondReport]);

      // Assert
      verify(mockReporter.updateVideoStats(argThat(isA<RtcVideoOutboundStats>()
              // Basic fields
              .having((s) => s.frameWidth, 'frameWidth', 1280)
              .having((s) => s.frameHeight, 'frameHeight', 720)
              // Calculated differences
              .having((s) => s.bytesSentPerSecond, 'bytesSentPerSecond',
                  100000) // 600000-500000 = 100000 bits
              .having((s) => s.packetsSentPerSecond, 'packetsSentPerSecond',
                  200) // 1000-800 = 200
              .having((s) => s.framesEncodedPerSecond, 'framesEncodedPerSecond',
                  200) // 1200-1000 = 200
              .having((s) => s.framesSentPerSecond, 'framesSentPerSecond',
                  200) // 1200-1000 = 200
              .having((s) => s.totalEncodeTimePerSecond,
                  'totalEncodeTimePerSecond', 23.0)
              .having((s) => s.totalPacketSendDelayPerSecond,
                  'totalPacketSendDelayPerSecond', 40.0)
              .having((s) => s.qpSumPerSecond, 'qpSumPerSecond', 1000.0)
              .having((s) => s.nackCountPerSecond, 'nackCountPerSecond', 5)
              .having((s) => s.firCountPerSecond, 'firCountPerSecond', 1)
              .having((s) => s.pliCountPerSecond, 'pliCountPerSecond', 1)
              // Calculated averages (properly divisible for clean results)
              .having((s) => s.encodeTimeAvgMs, 'encodeTimeAvg', 115.0)
              .having((s) => s.qpSumAvg, 'qpSumAvg', 5.0)
              .having(
                  (s) => s.packetSendDelayAvgMs, 'packetSendDelayAvg', 200.0))))
          .called(1);
    });

    // New test case to add to the existing rtc_stats_parse_test.dart file
// This should be added inside the main() group('RtcStatsParser - _onStatsReports', () {...}) function

    test(
        'Should call all subscriber methods when processing different types of reports',
        () {
      // Arrange
      final videoReport = StatsReport('OR01', 'outbound-rtp', 0, {
        'kind': 'video',
        'encoderImplementation': 'vp8',
        'frameWidth': 1280,
        'frameHeight': 720,
        'framesPerSecond': 30.0,
      });

      final localCandidateReport1 = StatsReport('LC01', 'local-candidate', 0, {
        'candidateType': 'host',
        'ip': '192.168.1.1',
        'port': 12345,
        'protocol': 'udp',
        'networkType': 'wifi',
      });

      final localCandidateReport2 = StatsReport('LC02', 'local-candidate', 0, {
        'candidateType': 'srflx',
        'ip': '203.0.113.1',
        'port': 54321,
        'protocol': 'udp',
        'networkType': 'cellular',
      });

      final remoteCandidateReport = StatsReport('RC01', 'remote-candidate', 0, {
        'candidateType': 'prflx',
        'ip': '198.51.100.1',
        'port': 54321,
        'protocol': 'udp',
      });

      final candidatePairReport = StatsReport('CP01', 'candidate-pair', 0, {
        'state': 'succeeded',
        'nominated': true,
        'bytesSent': 12345,
        'bytesReceived': 54321,
        'localCandidateId': 'LC01',
        'remoteCandidateId': 'RC01',
        'currentRoundTripTime': 0.035,
        'availableOutgoingBitrate': 2500000,
      });

      final codecReport = StatsReport('CD01', 'codec', 0, {
        'mimeType': 'video/VP8',
        'clockRate': 90000,
        'channels': 1,
        'payloadType': 96,
      });

      // Create a list with all reports
      final reports = [
        videoReport,
        localCandidateReport1,
        localCandidateReport2,
        remoteCandidateReport,
        candidatePairReport,
        codecReport,
      ];

      // Act - process all reports at once
      parser.onStatsReports(reports);

      // Assert - verify that all subscriber methods were called with appropriate arguments
      // Verify video stats update
      verify(mockReporter.updateVideoStats(any)).called(1);
      verify(mockPresenter.updateVideoStats(any)).called(1);

      // Verify local candidate updates - should pass a list containing both local candidates
      verify(mockReporter.updateLocalCandidate(argThat(isA<List<StatsReport>>()
              .having((list) => list.length, 'length', 2)
              .having((list) => list.any((report) => report.id == 'LC01'),
                  'contains LC01', true)
              .having((list) => list.any((report) => report.id == 'LC02'),
                  'contains LC02', true))))
          .called(1);
      verify(mockPresenter.updateLocalCandidate(argThat(isA<List<StatsReport>>()
              .having((list) => list.length, 'length', 2)
              .having((list) => list.any((report) => report.id == 'LC01'),
                  'contains LC01', true)
              .having((list) => list.any((report) => report.id == 'LC02'),
                  'contains LC02', true))))
          .called(1);

      // Verify remote candidate updates
      verify(mockReporter.updateRemoteCandidate(argThat(isA<List<StatsReport>>()
              .having((list) => list.length, 'length', 1)
              .having((list) => list.first.id, 'first id', 'RC01'))))
          .called(1);
      verify(mockPresenter.updateRemoteCandidate(argThat(
              isA<List<StatsReport>>()
                  .having((list) => list.length, 'length', 1)
                  .having((list) => list.first.id, 'first id', 'RC01'))))
          .called(1);

      // Verify candidate pair updates
      verify(mockReporter.updateCandidatePairStats(argThat(isA<StatsReport>()
              .having((r) => r.id, 'id', 'CP01')
              .having((r) => r.type, 'type', 'candidate-pair'))))
          .called(1);
      verify(mockPresenter.updateCandidatePairStats(argThat(isA<StatsReport>()
              .having((r) => r.id, 'id', 'CP01')
              .having((r) => r.type, 'type', 'candidate-pair'))))
          .called(1);

      // Verify codec stats updates
      verify(mockReporter.updateCodecStats(argThat(isA<StatsReport>()
              .having((r) => r.id, 'id', 'CD01')
              .having((r) => r.type, 'type', 'codec'))))
          .called(1);
      verify(mockPresenter.updateCodecStats(argThat(isA<StatsReport>()
              .having((r) => r.id, 'id', 'CD01')
              .having((r) => r.type, 'type', 'codec'))))
          .called(1);
    });
  });
}
