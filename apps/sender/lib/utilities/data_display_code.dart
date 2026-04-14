import 'dart:async';

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
    // Remove exist display code and add to last one.
    // "Display Code drop-down menu" will reversed list to show last one on top.
    await remove(displayCode);
    unawaited(_displayCodeBox?.add(displayCode));
  }

  Future<List?> load() async {
    _displayCodeBox = await _openBox();
    return _displayCodeList = _displayCodeBox?.values.toList();
  }

  Future<void> remove(String displayCode) async {
    _displayCodeBox = await _openBox();

    var list = _displayCodeBox?.values.toList();
    list?.remove(displayCode);

    await _displayCodeBox?.clear();

    list?.forEach((element) async {
      await _displayCodeBox?.add(element);
    });
  }
}
