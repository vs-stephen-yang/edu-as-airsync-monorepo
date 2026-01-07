import 'package:display_flutter/utility/rtc_metrics_rolling_aggregator.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStats {
  final int? a;
  final int? b;
  _FakeStats(this.a, this.b);
}

void main() {
  test('flattenPercentiles flattens metric percentile keys', () {
    final aggregator = RtcMetricsRollingAggregator<_FakeStats>(
      extractors: {
        'a': (s) => s.a,
        'b': (s) => s.b,
      },
      maxSamples: 10,
    );

    aggregator.add(_FakeStats(1, 10));
    aggregator.add(_FakeStats(3, 30));
    aggregator.add(_FakeStats(2, 20));

    final summary = aggregator.buildSummary();
    final flattened = summary.flattenPercentiles();

    expect(flattened['a.p1'], isNotNull);
    expect(flattened['a.p50'], isNotNull);
    expect(flattened['a.p99'], isNotNull);
    expect(flattened['b.p1'], isNotNull);
    expect(flattened['b.p50'], isNotNull);
    expect(flattened['b.p99'], isNotNull);
  });
}
