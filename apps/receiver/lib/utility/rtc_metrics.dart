import 'package:display_flutter/utility/math_util.dart';

class RtcMetricEvent {
  // the 25th percentile value.
  int p25th;
  int median;
  int p90th;
  int p99th;

  // the count of zero or missing values.
  int zeros;

  RtcMetricEvent(
    this.p25th,
    this.median,
    this.p90th,
    this.p99th,
    this.zeros,
  );

  Map<String, String> toJson() {
    return {
      'p25th': p25th.toString(),
      'median': median.toString(),
      'p90th': p90th.toString(),
      'p99th': p99th.toString(),
      'zeros': zeros.toString(),
    };
  }
}

RtcMetricEvent aggregateRtcMetricHistory(List<int?> data) {
  // Filter out null or zero values
  List<int> filteredData =
      data.where((e) => e != null && e > 0).cast<int>().toList();

  // Count null or zero values
  final zeroOrMissingCount = data.length - filteredData.length;

  if (filteredData.isEmpty) {
    return RtcMetricEvent(
      0,
      0,
      0,
      0,
      zeroOrMissingCount,
    );
  }

  final percentiles = calculatePercentiles(
    filteredData,
    [25, 50, 90, 99],
  );

  return RtcMetricEvent(
    percentiles[0],
    percentiles[1],
    percentiles[2],
    percentiles[3],
    zeroOrMissingCount,
  );
}
