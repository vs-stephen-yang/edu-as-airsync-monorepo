import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();

  //private "Named constructors"
  AppPreferences._internal();

  // passes the instantiation to the _instance object
  factory AppPreferences() => _instance;

  static ensureInitialized() async {
    await _instance._load();
    await _instance._loadInvitedToGroupSelectedItem();
  }

  bool _showEULA = true;
  String _instanceName = 'AirSync';
  String _entityId = '';
  String _moderatorId = '';

  bool get showEULA => _showEULA;

  String get instanceName => _instanceName;

  String get entityId => _entityId;

  String get moderatorId => _moderatorId;

  set({
    bool? showEULA,
    String? instanceName,
    String? entityId,
    String? moderatorId,
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
    _save();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('app_showEULA', _showEULA);
    prefs.setString('app_instanceName', _instanceName);
    prefs.setString('app_entityId', _entityId);
    prefs.setString('app_moderatorId', _moderatorId);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showEULA = prefs.getBool('app_showEULA') ?? true;
    _instanceName = prefs.getString('app_instanceName') ?? 'AirSync';
    _entityId = prefs.getString('app_entityId') ?? '';
    _moderatorId = prefs.getString('app_moderatorId') ?? '';
  }

  //TODO: MOVE TO GROUP FEATURE FILE
  String _invitedToGroup = 'Notify me';
  String get invitedToGroup => _invitedToGroup;

  void setInvitedToGroupSelectedItem({String? item}) async {
    if (item != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _invitedToGroup = item;
      await prefs.setString('app_setting_invited_to_group', item);
    }
  }

  _loadInvitedToGroupSelectedItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _invitedToGroup =
        prefs.getString('app_setting_invited_to_group') ?? _invitedToGroup;
  }

}
