import 'package:flutter_test/flutter_test.dart';

class ContainsMapMatcher extends Matcher {
  final Map expected;

  ContainsMapMatcher(this.expected);

  @override
  bool matches(item, Map matchState) {
    if (item is! Map) return false;
    return _containsMap(item, expected);
  }

  bool _containsMap(Map actual, Map expected) {
    for (var key in expected.keys) {
      if (!actual.containsKey(key) || actual[key] != expected[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('a map containing the key-value pairs from $expected');

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return mismatchDescription.add('was $item');
  }
}
