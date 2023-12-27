import 'package:hive_flutter/hive_flutter.dart';

class DataDisplayCode {
  static final DataDisplayCode _instance = DataDisplayCode._internal();

  DataDisplayCode._internal();

  static DataDisplayCode getInstance() => _instance;

  Box? _displayCodeBox;
  List? _displayCodeList;

  List? get displayCodeList => _displayCodeList;

  Future<void> initialize() async {
    await Hive.initFlutter('display_code_db');
  }

  Future<Box?> _openBox() async {
    if (_displayCodeBox == null || !_displayCodeBox!.isOpen) {
      _displayCodeBox = await Hive.openBox<String>('display_code');
    }
    return _displayCodeBox;
  }

  Future<void> save(String displayCode) async {
    _displayCodeBox = await _openBox();
    if (_displayCodeBox?.length == 0) {
      _displayCodeBox?.add(displayCode);
    } else {
      bool saveToBox = true;
      _displayCodeBox?.values.forEach((element) {
        if (element == displayCode) {
          saveToBox = false;
          return;
        }
      });
      if (saveToBox) {
        _displayCodeBox?.add(displayCode);
      }
    }
  }

  Future<List?> load() async {
    _displayCodeBox = await _openBox();
    return _displayCodeList = _displayCodeBox?.values.toList();
  }
}
