import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'display_code_event.dart';
part 'display_code_state.dart';

class DisplayCodeBloc extends Bloc<DisplayCodeEvent, DisplayCodeState> {
  String apiGateway, instanceID;
  late String displayCode= '', token, name, otp= '';

  DisplayCodeBloc(this.apiGateway, this.instanceID) : super(DisplayCodeInitial()) {
    on<GetDisplayCode>((event, emit) async {
      bool result = await _processGetDisplayCode(instanceID, apiGateway);
      if (result) {
        emit(DisplayCodeSuccess());
        _processOTP();
      } else {
        bool result = await _registerDisplayCode(instanceID, apiGateway);
        if (!result) {
          emit(DisplayCodeError());
        }
      }
    });
  }

  Future<bool> _registerDisplayCode(String instanceID, String apiGateway) async {
    var api = Uri.parse('$apiGateway/presentation/displays');
    var property = json.encode(
        {'version': '1.0.0', 'platform': 'android', 'capacities': '[]'});

    http.Response response = await http.post(api,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'id': instanceID, 'property': property}));
    print("zz _registerDisplayCode ${response.statusCode}");
    if (response.statusCode >= HttpStatus.ok && response.statusCode < HttpStatus.multiStatus) {
      _processGetDisplayCode(instanceID, apiGateway);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _processGetDisplayCode(String instanceID, String apiGateway) async {
    var api = Uri.parse('$apiGateway/presentation/displays/$instanceID');
    http.Response response = await http.get(api);
    print("zz $api ${response.statusCode} ");
    if (response.statusCode >= HttpStatus.ok && response.statusCode < HttpStatus.multiStatus) {
      Map json = jsonDecode(response.body);
      displayCode = json['code'];
      token = Uri.encodeComponent(json['token']);
      Map<String, dynamic> map = json['property'];
      List<dynamic> license = map['licenses'];
      name = license[0]['name'];

      // save the above info
      //TODO:save mWebRTCInfo

      // connectControlSocket
      //TODO:check the JAVA side
      // WebRTCNativeViewController._(_id).channel.invokeMethod("connectControlSocket");
      // controller.channel.invokeMethod("connectControlSocket");

      return true;
    } else {
      return false;
    }
  }

  Future<bool> _getOneTimePassword(String instanceID, String apiGateway) async {
    var api = Uri.parse('$apiGateway/presentation/displays/otp/generate');
    var property = json.encode({'id': instanceID, 'count': '1'});

    http.Response response = await http.post(api,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'id': instanceID, 'property': property}));
    print("zz _getOneTimePassword ${response.statusCode}");
    if (response.statusCode >= HttpStatus.ok && response.statusCode < HttpStatus.multiStatus) {
      Map json = jsonDecode(response.body);
      List jsonArray = json['list'];
      otp = jsonArray[0]['code'];
      // TODO: update OTPUpdate = true
      Timer(const Duration(seconds: 30), () async {
        _processOTP();
      });
      return true;
    } else {
      // TODO: update otpCode = "-"
      // TODO: update otpTimer = 0
      // TODO: update OTPUpdate = true
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
