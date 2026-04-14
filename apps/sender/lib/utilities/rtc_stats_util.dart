Map<String, double> parseQualityLimitationDurations(dynamic raw) {
  final result = <String, double>{};
  if (raw == null) {
    return result;
  }

  void insertValue(String key, dynamic value) {
    double? parsed;
    if (value is num) {
      parsed = value.toDouble();
    } else if (value is String) {
      parsed = double.tryParse(value);
    }
    if (parsed != null) {
      result[key] = parsed;
    }
  }

  if (raw is Map) {
    raw.forEach((key, value) => insertValue(key.toString(), value));
    return result;
  }

  if (raw is String) {
    var text = raw.trim();
    if (text.startsWith('{') && text.endsWith('}')) {
      text = text.substring(1, text.length - 1);
    }
    for (final part in text.split(',')) {
      if (part.trim().isEmpty) {
        continue;
      }
      final kv = part.split(':');
      if (kv.length < 2) {
        continue;
      }
      final key = kv[0].trim();
      final value = kv.sublist(1).join(':').trim();
      insertValue(key, value);
    }
  }

  return result;
}
