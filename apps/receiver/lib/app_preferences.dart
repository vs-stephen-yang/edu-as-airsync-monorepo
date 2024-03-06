import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();

  //private "Named constructors"
  AppPreferences._internal();

  // passes the instantiation to the _instance object
  factory AppPreferences() => _instance;

  static ensureInitialized() async {
    await _instance._load();
  }

  bool _showEULA = true;
  String _instanceName = 'AirSync';
  String _entityId = '';
  String _moderatorId = '';
  bool _showOverlayTab = false;

  bool get showEULA => _showEULA;

  String get instanceName => _instanceName;

  String get entityId => _entityId;

  String get moderatorId => _moderatorId;

  bool get showOverlayTab => _showOverlayTab;

  set({
    bool? showEULA,
    String? instanceName,
    String? entityId,
    String? moderatorId,
    bool? showOverlayTab,
  }) {
    if (showEULA != null) {
      _showEULA = showEULA;
    }
    if (instanceName != null) {
      _instanceName = instanceName;
    }
    if (entityId != null) {
      _entityId = entityId;
    }
    if (moderatorId != null) {
      _moderatorId = moderatorId;
    }
    if (showOverlayTab != null) {
      _showOverlayTab = showOverlayTab;
    }
    _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('app_showEULA', _showEULA);
    prefs.setString('app_instanceName', _instanceName);
    prefs.setString('app_entityId', _entityId);
    prefs.setString('app_moderatorId', _moderatorId);
    prefs.setBool('app_showOverlayTab', _showOverlayTab);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showEULA = prefs.getBool('app_showEULA') ?? true;
    _instanceName = prefs.getString('app_instanceName') ?? 'AirSync';
    _entityId = prefs.getString('app_entityId') ?? '';
    _moderatorId = prefs.getString('app_moderatorId') ?? '';
    _showOverlayTab = prefs.getBool('app_showOverlayTab') ?? false;
  }
}
