List<List<int>> parseHexListToIntList(List<String> inputs) {
  return inputs
      .map((input) {
    try {
      // Remove spaces and split by commas
      final hexValues = input.replaceAll(' ', '').split(',');

      // Parse each value, ensuring explicit int type
      return hexValues.map<int>((hex) {
        if (hex.startsWith('0x')) {
          return int.parse(hex.substring(2), radix: 16);
        }
        return int.parse(hex, radix: 16);
      }).toList();
    } catch (e) {
      return null; // Mark this entry as invalid
    }
  })
      .where((list) => list != null)
      .cast<List<int>>()
      .toList(); // Filter out invalid entries
}