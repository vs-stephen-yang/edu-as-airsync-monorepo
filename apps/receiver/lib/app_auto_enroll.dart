import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AppAutoEnroll {
  static final AppAutoEnroll _instance = AppAutoEnroll._internal();

  //private "Named constructors"
  AppAutoEnroll._internal();

  // passes the instantiation to the _instance object
  factory AppAutoEnroll() => _instance;

  Future<String> getEnrollInformation(
      ConfigSettings settings, String instanceId) async {
    String entityId = '';
    try {
      MethodChannel methodChannel =
          const MethodChannel('com.mvbcast.crosswalk/auto_enroll');

      String result = await methodChannel.invokeMethod('getEnrollInformation');

      if (result.isNotEmpty) {
        try {
          http.Response response = await http.post(
            Uri.parse(
                '${settings.apiGateway}/presentation/displays/entity/enroll'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: json.encode({
              'organization': result,
              'id': instanceId,
            }),
          );
          if (response.statusCode == HttpStatus.created) {
            Map json = jsonDecode(response.body);
            if (json.containsKey('entityId')) {
              entityId = json['entityId'];
            }
          }
        } catch (e) {
          log(e.toString());
        }
      }
    } on PlatformException catch (e) {
      log('${e.message}');
    } catch (e) {
      log(e.toString());
    }
    return entityId;
  }
}
