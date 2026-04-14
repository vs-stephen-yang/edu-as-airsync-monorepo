import 'package:display_flutter/utility/math_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Calculate percentiles for a large dataset', () {
    // arrange
    final data = List<int>.generate(100, (index) => index + 1);

    // action
    final actual = calculatePercentiles(data, [25.0, 50.0, 95.0, 99.0]);

    //assert
    expect(actual[0], 25);
    expect(actual[1], 50);
    expect(actual[2], 95);
    expect(actual[3], 99);
  });

  test('Calculate percentiles for a small dataset of 2 data points', () {
    // arrange
    final data = List<int>.generate(2, (index) => index + 1);

    // action
    final actual = calculatePercentiles(data, [25.0, 50.0, 95.0, 99.0]);

    //assert
    expect(actual[0], 1);
    expect(actual[1], 1);
    expect(actual[2], 1);
    expect(actual[3], 1);
  });

  test('Calculate percentiles for a small dataset of 1 data points', () {
    // arrange
    final data = List<int>.generate(1, (index) => index + 1);

    // action
    final actual = calculatePercentiles(data, [25.0, 50.0, 95.0, 99.0]);

    //assert
    expect(actual[0], 1);
    expect(actual[1], 1);
    expect(actual[2], 1);
    expect(actual[3], 1);
  });
}
