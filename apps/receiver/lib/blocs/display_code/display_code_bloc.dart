import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/webrtc_info.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'display_code_event.dart';
part 'display_code_state.dart';

class DisplayCodeBloc extends Bloc<DisplayCodeEvent, DisplayCodeState> {
  String apiGateway, instanceID, version;
  late String otp = '';
  WebRTCInfo mWebRTCInfo = WebRTCInfo.getInstance();

  DisplayCodeBloc(this.apiGateway, this.instanceID, this.version)
      : super(DisplayCodeInitial()) {
    on<GetDisplayCode>((event, emit) async {
      bool result = await _processGetDisplayCode(instanceID, apiGateway);
      if (result) {
        emit(DisplayCodeSuccess());
        _processOTP();
      } else {
        bool result =
            await _registerDisplayCode(instanceID, apiGateway, version);
        if (!result) {
          emit(DisplayCodeError());
        }
      }
    });
  }

  Future<bool> _registerDisplayCode(String instanceID, String apiGateway, String version) async {
    var api = Uri.parse('$apiGateway/presentation/displays');
    var property = {
      'version': version,
      'platform': 'android',
      'capacities': '[]'
    };
    http.Response response = await http.post(api,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({'id': instanceID, 'property': property}));

    if (response.statusCode >= HttpStatus.ok &&
        response.statusCode < HttpStatus.multiStatus) {
      _processGetDisplayCode(instanceID, apiGateway);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _processGetDisplayCode(String instanceID, String apiGateway) async {
    WebRTCInfo.getInstance().instanceId = instanceID;
    var api = Uri.parse('$apiGateway/presentation/displays/$instanceID');
    http.Response response = await http.get(api);

    if (response.statusCode >= HttpStatus.ok &&
        response.statusCode < HttpStatus.multiStatus) {
      Map json = jsonDecode(response.body);
      AppPreferences().set(entityId: json['entityId'] ?? '');
      WebRTCInfo.getInstance().displayCode = json['code'];
      WebRTCInfo.getInstance().token = Uri.encodeComponent(json['token']);
      Map<String, dynamic> property = json['property'];
      List<dynamic> license = property['licenses'];
      WebRTCInfo.getInstance().licenseName = license[0]['name'];
      List<dynamic> features = property['features'];
      for (String feature in features) {
        WebRTCInfo.getInstance().featureList.add(feature);
      }

      return true;
    } else {
      return false;
    }
  }

  Future<bool> _getOneTimePassword(String instanceID, String apiGateway) async {
    var api = Uri.parse('$apiGateway/presentation/displays/otp/generate');

    http.Response response = await http.post(api,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'id': instanceID, 'count': '1'}));

    if (response.statusCode >= HttpStatus.created) {
      Map json = jsonDecode(response.body);
      List jsonArray = json['list'];
      mWebRTCInfo.otpCode = otp = jsonArray[0]['code'];
      mWebRTCInfo.otpTimer = mWebRTCInfo.otpCode == "-" ? 0 : 30;
      mWebRTCInfo.otpUpdate = true;
      Timer(const Duration(seconds: 30), () async {
        _processOTP();
      });
      return true;
    } else {
      mWebRTCInfo.otpCode = "-";
      mWebRTCInfo.otpTimer = 0;
      mWebRTCInfo.otpUpdate = true;

      Timer(const Duration(seconds: 5), () async {
        _processOTP();
      });
      return false;
    }
  }

  void _processOTP() async{
    bool result = await _getOneTimePassword(instanceID, apiGateway);
    if (result) {
      emit(OneTimePasswordTimer());
    } else {
      emit(OneTimePasswordError());
    }
  }

}
