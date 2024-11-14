import 'dart:convert';

import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:flutter/foundation.dart';
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
    await _instance._loadSelectedConnectivityType();
    await _instance._loadGroupSelectedList();
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
    String? connectivityType,
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

  String _invitedToGroup = InvitedToGroupOption.notifyMe.value.toString();

  String get invitedToGroup {
    return int.tryParse(_invitedToGroup)?.toString() ?? InvitedToGroupOption.notifyMe.value.toString();
  }

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

  List<Map<String, String>> _groupSelectedList = [];

  List<Map<String, String>> get groupSelectedList => _groupSelectedList;

  void setGroupSelectedList(List<Map<String, String>> selectedList) async {
    _groupSelectedList = selectedList;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(selectedList);
    await prefs.setString('app_setting_group_selected_list', jsonString);
  }

  _loadGroupSelectedList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('app_setting_group_selected_list');
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      _groupSelectedList =
          jsonList.map((item) => Map<String, String>.from(item)).toList();
    }
  }

  String get connectivityType => connectivityTypeNotifier.value;

  ValueNotifier<String> connectivityTypeNotifier =
      ValueNotifier<String>(ConnectivityType.both.toString());

  Future<void> setSelectedConnectivityType(ConnectivityType type) async {
    connectivityTypeNotifier.value = type.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'app_setting_connectivity_type', connectivityTypeNotifier.value);
  }

  _loadSelectedConnectivityType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String type = prefs.getString('app_setting_connectivity_type') ??
        ConnectivityType.both.toString();
    connectivityTypeNotifier.value = type;
  }
}

enum ConnectivityType {
  both,
  local,
  internet,
}
