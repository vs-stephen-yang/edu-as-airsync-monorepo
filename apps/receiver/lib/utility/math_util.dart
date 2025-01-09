List<T> calculatePercentiles<T extends Comparable>(
  List<T> originalData,
  List<double> percentiles,
) {
  if (originalData.isEmpty) {
    throw ArgumentError('The list cannot be empty.');
  }
  for (var percentile in percentiles) {
    if (percentile < 0 || percentile > 100) {
      throw ArgumentError('Percentile must be between 0 and 100.');
    }
  }

  // Sort the list
  List<T> data = List<T>.from(originalData);
  data.sort();

  // Calculate and store the percentiles

  return percentiles.map((percentile) {
    double rank = (percentile / 100) * (data.length - 1);

    return data[rank.floor()];
  }).toList();
}

// Calculate the EWMA (Exponentially Weighted Moving Average)
double calculateEwma({
  required double currentValue,
  required double previousValue,
  required double alpha,
}) {
  return (currentValue * alpha) + (previousValue * (1 - alpha));
}
