import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/model/rtc_stats_parser.dart';
import 'package:display_cast_flutter/model/rtc_stats_presenter.dart';
import 'package:display_cast_flutter/model/rtc_stats_reporter.dart';
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

    setUp(() {
      mockReporter = MockRtcStatsReporter();
      parser = RtcStatsParser((int? x, int? y){});
      parser.addSubscriber(mockReporter);
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
        'totalEncodeTime': 25.5,
        'pliCount': 3,
        'targetBitrate': 1200000.0,
        'powerEfficientEncoder': true,
      });

      final reports = [videoReport];

      // Act
      parser.onStatsReports(reports);

      // Assert
      verify(mockReporter.updateVideoStats(argThat(isA<RtcVideoOutboundStats>()
          .having((s) => s.encoderImplementation, 'encoderImplementation', 'vp8')
          .having((s) => s.frameWidth, 'frameWidth', 1280)
          .having((s) => s.frameHeight, 'frameHeight', 720)
          .having((s) => s.framesPerSecond, 'framesPerSecond', 30.0)
          .having((s) => s.contentType, 'contentType', 'realtime')
          .having((s) => s.qualityLimitationReason, 'qualityLimitationReason', 'bandwidth')
          .having((s) => s.pliCount, 'pliCount', 3)
          .having((s) => s.targetBitrate, 'targetBitrate', 1200000.0)
          .having((s) => s.powerEfficientEncoder, 'powerEfficientEncoder', true))))
          .called(1);
    });
  });
}