import 'dart:async';

import 'package:display_flutter/widgets/click_switch.dart';
import 'package:flutter/widgets.dart';

class Displays {
  static final Displays _instance = Displays._internal();

  //private "Named constructors"
  Displays._internal();

  // passes the instantiation to the _instance object
  factory Displays() => _instance;

  int _selectedIndex = -1;
  List<DisplayInfo> _displays = <DisplayInfo>[];

  List<DisplayInfo> getDisplays() {
    return _displays;
  }

  DisplayInfo getSelectedDisplay() {
    return _selectedIndex > -1 ? _displays[_selectedIndex] : DisplayInfo();
  }

  addDisplayInfo(DisplayInfo displayInfo) {
    if (!_displays.contains(displayInfo)) {
      _displays.add(displayInfo);
      if (_displays.length > 0 && _selectedIndex == -1) {
        _selectedIndex = 0;
      }
    }
  }

  removeSelectedDisplayInfo() {
    _displays.remove(_displays[_selectedIndex]);
    if (_displays.length > 0) {
      // if list not empty, select first one.
      _selectedIndex = 0;
    } else {
      // list is empty, clear index
      _selectedIndex = -1;
    }
  }

  removeAllDisplayInfo() {
    _displays.clear();
    _selectedIndex = -1;
  }

  removeDisplayInfo(DisplayInfo displayInfo) {
    _displays.remove(displayInfo);
    if (_displays.length > 0) {
      // if list not empty, select first one.
      _selectedIndex = 0;
    } else {
      // list is empty, clear index
      _selectedIndex = -1;
    }
  }

  getSelectedIndex() {
    return _selectedIndex;
  }

  setSelectedIndex(int selectedIndex) {
    _selectedIndex = selectedIndex;
  }

  isSelectedIndex(int index) {
    return _selectedIndex == index;
  }
}

class DisplayInfo {
  dynamic displayResponse;
  String displayId = '';
  String displayName = '';
  String meetingId = '';
  String moderatedSessionId = '';
  bool uiStateCode = false;
  bool uiStateDelegate = false;

  int remainingTime = 0;
  int remainingTimeStart = 0;
  int remainingTimeEnd = 0;

  List<DisplayPeer> peerList = <DisplayPeer>[];
  Map<int, String> splitIndexMap = <int, String>{1: '', 2: '', 3: '', 4: ''};
  int presenterIndex = -1;
  String presenterName = '';
  String presenterStatus = '';
  double presenterSignalStrength = 0;
  int presenterTime = 0;
  late Timer _presenterTimeTimer;
  bool _presenterTimeTimerInit = false;
  bool splitsScreen = false;
  String presenterId = '';

  DisplayInfo(
      {String? displayId,
      dynamic displayResponse,
      bool? uiStateCode,
      bool? uiStateDelegate,
      List<DisplayPeer>? peerList}) {
    if (displayId != null) {
      this.displayId = displayId;
      this.displayName = _getDashedId(displayId);
    }
    if (displayResponse != null) {
      this.displayResponse = displayResponse;

      if (displayResponse['property'] != null) {
        this.meetingId = displayResponse['property']['meetingId'] ?? '';
        this.moderatedSessionId =
            displayResponse['property']['moderatedSessionId'] ?? '';

        if (displayResponse['property']['duration'] != null) {
          this.remainingTime =
              displayResponse['property']['duration']['duration_remain'] ?? 0;
          this.remainingTimeStart =
              displayResponse['property']['duration']['startTime'] ?? 0;
          this.remainingTimeEnd =
              displayResponse['property']['duration']['endTime'] ?? 0;
        }
      }
    }
    this.uiStateCode = uiStateCode ?? false;
    this.uiStateDelegate = uiStateDelegate ?? false;
    this.peerList = peerList ?? <DisplayPeer>[];
  }

  String _getDashedId(String code) {
    var i = 0;
    String replaced;
    Set<int> dashes = Set();
    int loop = (code.length ~/ 3);
    for (int a = 0; a < loop; a++) {
      dashes.add(a + 1);
    }
    replaced = code.splitMapJoin(RegExp('...'),
        onNonMatch: (s) => dashes.contains(i++) ? '-' : '');
    if (code.length % 3 != 0) // add last digit
      replaced = replaced + code.substring(loop * 3);
    else //remove last "-"
      replaced = replaced.substring(0, replaced.length - 1);
    return replaced;
  }

  @override
  bool operator ==(Object other) =>
      other is DisplayInfo && this.displayId == other.displayId;

  @override
  int get hashCode => this.displayId.hashCode;

  clearStatus() {
    peerList.clear();
    presenterIndex = -1;
    presenterName = '';
    presenterStatus = '';
    presenterSignalStrength = 0;
    presenterTime = 0;
  }

  setPresenterTimeTimer(bool counting) {
    // Just create timer to count, Remaining timer will update UI
    if (_presenterTimeTimerInit) _presenterTimeTimer.cancel();

    if (counting) {
      _presenterTimeTimer = Timer.periodic(
        Duration(seconds: 1),
        (timer) {
          if (presenterTime >= (remainingTimeEnd - remainingTimeStart)) {
            _presenterTimeTimer.cancel();
          } else {
            presenterTime += 1000;
          }
        },
      );
      _presenterTimeTimerInit = true;
    }
  }

  disposePresenterTimer() {
    if (_presenterTimeTimerInit) _presenterTimeTimer.cancel();

    _presenterTimeTimerInit = false;
  }
}

class DisplayPeer {
  String id = '';
  String presenter = '';
  String status = '';
  dynamic peer;
  late GlobalKey<CheckBoxSwitchState> key;
}
