import 'package:display_flutter/oss_licenses.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingPageState {
  deviceSetting,
  deviceName,
  deviceLanguage,
  accessibility,
  broadcast,
  broadcastBoards,
  mirroring,
  connectivity,
  whatsNew,
  legalPolicy,
  licenses,
  knowledgeBase;

  static List<SettingPageState> get mainPages => [
        SettingPageState.deviceSetting,
        SettingPageState.accessibility,
        SettingPageState.broadcast,
        SettingPageState.mirroring,
        SettingPageState.connectivity,
        SettingPageState.whatsNew,
        SettingPageState.legalPolicy,
        SettingPageState.knowledgeBase,
      ];
}

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  SettingPageState _currentPage = SettingPageState.deviceSetting;

  SettingPageState get currentPage => _currentPage;

  static SettingPageState _currentTittlePage = SettingPageState.deviceSetting;

  static SettingPageState get currentTittlePage => _currentTittlePage;

  Package? _license;

  Package? get license => _license;

  static const defaultSettingsLock = false;
  static const defaultSettingsPassword = '0000';
  static const defaultDeviceSettingLock = false;
  static const defaultBroadcastLock = false;
  static const defaultMirroringLock = false;
  static const defaultConnectivityLock = false;
  bool _isSettingsLock = defaultSettingsLock;
  String _settingsPassword = defaultSettingsPassword;
  bool _isDeviceSettingLock = defaultDeviceSettingLock;
  bool _isBroadcastLock = defaultBroadcastLock;
  bool _isMirroringLock = defaultMirroringLock;
  bool _isConnectivityLock = defaultConnectivityLock;

  bool get isSettingsLock => _isSettingsLock;

  set isSettingsLock(bool value) {
    _isSettingsLock = value;
    _save();
  }

  String get settingsPassword => _settingsPassword;

  set settingsPassword(String value) {
    _settingsPassword = value;
    _save();
  }

  bool get isDeviceSettingLock => _isDeviceSettingLock;

  set isDeviceSettingLock(bool value) {
    _isDeviceSettingLock = value;
    _save();
  }

  bool get isBroadcastLock => _isBroadcastLock;

  set isBroadcastLock(bool value) {
    _isBroadcastLock = value;
    _save();
  }

  bool get isMirroringLock => _isMirroringLock;

  set isMirroringLock(bool value) {
    _isMirroringLock = value;
    _save();
  }

  bool get isConnectivityLock => _isConnectivityLock;

  set isConnectivityLock(bool value) {
    _isConnectivityLock = value;
    _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_isSettingsLock', _isSettingsLock);
    await prefs.setString('app_SettingsPassword', _settingsPassword);
    await prefs.setBool('app_isDeviceSettingLock', _isDeviceSettingLock);
    await prefs.setBool('app_isBroadcastLock', _isBroadcastLock);
    await prefs.setBool('app_isMirroringLock', _isMirroringLock);
    await prefs.setBool('app_isConnectivityLock', _isConnectivityLock);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSettingsLock =
        prefs.getBool('app_isSettingsLock') ?? defaultSettingsLock;
    _settingsPassword =
        prefs.getString('app_SettingsPassword') ?? defaultSettingsPassword;
    _isDeviceSettingLock =
        prefs.getBool('app_isDeviceSettingLock') ?? defaultDeviceSettingLock;
    _isBroadcastLock =
        prefs.getBool('app_isBroadcastLock') ?? defaultBroadcastLock;
    _isMirroringLock =
        prefs.getBool('app_isMirroringLock') ?? defaultMirroringLock;
    _isConnectivityLock =
        prefs.getBool('app_isConnectivityLock') ?? defaultConnectivityLock;
  }

  Future<void> reloadPreferences() async {
    await _load();
    notifyListeners();
  }

  setPage(SettingPageState state, {Package? license}) {
    switch (state) {
      case SettingPageState.deviceSetting:
      case SettingPageState.accessibility:
      case SettingPageState.broadcast:
      case SettingPageState.mirroring:
      case SettingPageState.connectivity:
      case SettingPageState.whatsNew:
      case SettingPageState.legalPolicy:
        _currentTittlePage = state;
      default:
        break;
    }
    _currentPage = state;
    _license = license;
    notifyListeners();
  }

  /// ----------------- Focus Manager -----------------
  _V3SettingMenuFocusManager? _focusManager;

  void initFocus() {
    _focusManager = _V3SettingMenuFocusManager();
  }

  void clearFocus() {
    _focusManager = null;
  }

  FocusNode? get subFocusNode => _focusManager?.subFocusNode;

  void resetSubFocusNode() => _focusManager?.resetSubFocusNode();

  KeyEventResult onMainFocusMove(
    FocusNode node,
    KeyEvent event,
    VoidCallback onClick,
    SettingPageState state,
  ) =>
      _focusManager?.onMainFocusMove(node, event, onClick, state) ??
      KeyEventResult.ignored;

  KeyEventResult onSubFocusMove(FocusNode node, KeyEvent event) =>
      _focusManager?.onSubFocusMove(node, event) ?? KeyEventResult.ignored;

  void requestMainFocus(int selectedIndex) {
    _focusManager?.requestMainFocus(selectedIndex);
  }

  void resetThenFocusMenuPrimary() {
    _focusManager?.focusMenuPrimary();
  }

  void requestMainMenuFocus() {
    _focusManager?.requestMainMenuFocus();
  }

  void requestSubFocus() {
    _focusManager?.requestSubFocus();
  }

  FocusNode getMenuFocusNode(int index) {
    return _focusManager?.getMenuFocusNode(index) ?? FocusNode();
  }

  int? getFocusIndex() {
    return _focusManager?.getFocusIndex();
  }

  void requestFocusMainMenu() {
    _focusManager?.requestMainMenuFocus();
  }

  void requestFocusMain(int selectedIndex) {
    _focusManager?.requestMainFocus(selectedIndex);
  }

  void focusPrimaryMenu() {
    _focusManager?.focusMenuPrimary();
  }
}

class _V3SettingMenuFocusManager {
  final List<FocusNode> _menuFocusNodes = List<FocusNode>.generate(
      SettingPageState.mainPages.length, (index) => FocusNode());
  FocusNode subFocusNode = FocusNode();

  void resetSubFocusNode() {
    subFocusNode = FocusNode();
  }

  int _currentMainIndex = 0;

  void focusMenuPrimary() {
    _menuFocusNodes[0].requestFocus();
  }

  FocusNode getMenuFocusNode(int index) {
    return _menuFocusNodes[index];
  }

  void requestMainFocus(selectedIndex) {
    selectedIndex = selectedIndex;
    _menuFocusNodes[selectedIndex].requestFocus();
  }

  int? getFocusIndex() {
    for (var i = 0; i < _menuFocusNodes.length; i += 1) {
      if (_menuFocusNodes[i].hasFocus) {
        return i;
      }
    }
    return null;
  }

  KeyEventResult onSubFocusMove(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _menuFocusNodes[_currentMainIndex].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void requestMainMenuFocus() {
    _menuFocusNodes[_currentMainIndex].requestFocus();
  }

  void requestSubFocus() {
    for (var node in _menuFocusNodes) {
      if (node.hasFocus) {
        return;
      }
    }

    subFocusNode.requestFocus();
  }

  KeyEventResult onMainFocusMove(
    FocusNode node,
    KeyEvent event,
    VoidCallback onClick,
    SettingPageState state,
  ) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final index = getFocusIndex();

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (index == 0 || index == null) {
        return KeyEventResult.ignored;
      }
      _menuFocusNodes[index - 1].requestFocus();

      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (index == _menuFocusNodes.length - 1 || index == null) {
        return KeyEventResult.ignored;
      }
      _menuFocusNodes[index + 1].requestFocus();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      subFocusNode.requestFocus();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select) {
      _currentMainIndex = index!;
      onClick();

      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
