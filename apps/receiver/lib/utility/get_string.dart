import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';

class GetString {
  static getRandomString(int length) {
    const data =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => data.codeUnitAt(random.nextInt(data.length))));
  }

  static getShortTimeString(String keyStr, String data) {
    DateFormat inputFormat = DateFormat('MM-dd-HH-mm-ss', 'en_US');
    return inputFormat.format(DateTime.now());
  }

  static Map<String, String> splitQueryString(String query,
      {Encoding encoding = utf8}) {
    return query.split('&').fold({}, (map, element) {
      int index = element.indexOf('=');
      if (index == -1) {
        if (element != '') {
          map[Uri.decodeQueryComponent(element, encoding: encoding)] = '';
        }
      } else if (index != 0) {
        var key = element.substring(0, index);
        var value = element.substring(index + 1);
        map[Uri.decodeQueryComponent(key, encoding: encoding)] =
            Uri.decodeQueryComponent(value, encoding: encoding);
      }
      return map;
    });
  }
}
