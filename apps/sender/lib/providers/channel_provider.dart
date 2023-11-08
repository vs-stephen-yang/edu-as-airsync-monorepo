
import 'package:flutter/cupertino.dart';

enum Mode {
  internet,
  lan
}

class ChannelProvider extends ChangeNotifier {
  ChannelProvider(BuildContext context);

  Mode _currentMode = Mode.internet;

  Mode get currentMode => _currentMode;

  set currentMode(Mode value) {
    _currentMode = value;
    notifyListeners();
  }
}