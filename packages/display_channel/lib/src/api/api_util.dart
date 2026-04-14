// Create a Map  with keys in alphabetical order from another map
Map<String, Object> orderMapWithKeys(Map<String, dynamic> map) {
  // Get all keys and sort them alphabetically
  var sortedKeys = map.keys.toList()..sort();

  // Create a LinkedHashMap and insert key-value pairs in order
  final orderedMap = <String, Object>{};
  for (var key in sortedKeys) {
    orderedMap[key] = map[key];
  }

  return orderedMap;
}
