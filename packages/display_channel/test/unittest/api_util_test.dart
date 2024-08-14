import 'package:display_channel/src/api/api_util.dart';
import 'package:flutter_test/flutter_test.dart';

bool _compareMaps(Map map1, Map map2) {
  if (map1.length != map2.length) {
    return false;
  }

  final keys1 = map1.keys.toList();
  final keys2 = map2.keys.toList();

  for (int i = 0; i < keys1.length; i++) {
    if (keys1[i] != keys2[i] || map1[keys1[i]] != map2[keys2[i]]) {
      return false;
    }
  }

  return true;
}

void main() {
  test('orderMapWithKeys', () {
    // arrange

    //action
    final actual = orderMapWithKeys(
      {
        'b': 2,
        'a': 1,
        'c': 3,
      },
    );

    //assert
    const expected = {
      'a': 1,
      'b': 2,
      'c': 3,
    };
    expect(_compareMaps(actual, expected), true);
  });
}
