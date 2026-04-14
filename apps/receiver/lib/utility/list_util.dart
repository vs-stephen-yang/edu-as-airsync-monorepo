/// This function takes a list of elements and returns a new list containing
/// every second element from the original list, starting with the first element.
/// It iterates through the original list, incrementing the index by 2 in each iteration,
/// thus selecting every second element.
List<T> filterEverySecond<T>(List<T> originalList) {
  List<T> newList = [];

  for (int i = 0; i < originalList.length; i += 2) {
    newList.add(originalList[i]);
  }

  return newList;
}

/// This function takes a list of nullable double values and a precision value.
/// It formats each double value in the list to the specified number of decimal places.
/// If a value is null, it converts it to the string 'null'.
/// This is useful for ensuring consistent formatting of numerical data, including cases where data points may be missing.
List<String> formatDoubleList(List<double?> list, int precision) {
  return list.map((e) => e?.toStringAsFixed(precision) ?? 'null').toList();
}
