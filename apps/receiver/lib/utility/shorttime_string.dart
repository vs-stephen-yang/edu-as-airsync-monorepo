import 'package:intl/intl.dart';

getShortTimeString(String keyStr, String data) {
  DateFormat inputFormat = DateFormat("MM-dd-HH-mm-ss", "en_US");
  return inputFormat.format(DateTime.now());
}
