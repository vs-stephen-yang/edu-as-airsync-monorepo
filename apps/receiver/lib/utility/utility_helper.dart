
import 'dart:math';

class UtilityHelper {

  static String getRandomString(int length) {
    const data = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => data.codeUnitAt(random.nextInt(data.length))));
  }

}