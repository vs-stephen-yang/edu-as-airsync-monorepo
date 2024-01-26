import 'package:logging/logging.dart';

Logger getDefaultLogger() {
  return Logger('airsync');
}

void initLogger(){
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name} ${record.message}');
});
}