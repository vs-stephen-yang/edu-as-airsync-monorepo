import 'package:display_flutter/utility/rtc_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Aggregate metric for a large dataset', () {
    // arrange
    final data = List<int?>.generate(100, (index) => index + 1);

    // action
    final actual = aggregateRtcMetricHistory(data);

    //assert
    expect(actual.p25th, 25);
    expect(actual.median, 50);
    expect(actual.p90th, 90);
    expect(actual.p99th, 99);
    expect(actual.zeros, 0);
  });

  test('Aggregate metric for the dataset with null and zeros', () {
    // arrange
    final data = List<int?>.generate(100, (index) => index + 1);
    data.addAll([null, 0, null, 0]);

    // action
    final actual = aggregateRtcMetricHistory(data);

    //assert
    expect(actual.p25th, 25);
    expect(actual.median, 50);
    expect(actual.p90th, 90);
    expect(actual.p99th, 99);
    expect(actual.zeros, 4);
  });

  test('Aggregate metric for the empty dataset', () {
    // arrange
    final data = <int?>[];

    // action
    final actual = aggregateRtcMetricHistory(data);

    //assert
    expect(actual.p25th, 0);
    expect(actual.median, 0);
    expect(actual.p90th, 0);
    expect(actual.p99th, 0);
    expect(actual.zeros, 0);
  });
}
