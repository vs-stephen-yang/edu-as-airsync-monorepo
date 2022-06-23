import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'main_info_event.dart';

part 'main_info_state.dart';

// https://bloclibrary.dev/#/gettingstarted
class MainInfoBloc extends Bloc<MainInfoEvent, MainInfoState> {
  String apiGateway, instanceID, version;

  MainInfoBloc(this.apiGateway, this.instanceID, this.version)
      : super(MainInfoState.initialState) {
    on<GetDisplayCode>(_processGetDisplayCode);
    on<RegisterDisplayCode>(_registerDisplayCode);
    on<GetOneTimePassword>(_getOneTimePassword);
  }

  Future<void> _processGetDisplayCode(
      MainInfoEvent event, Emitter<MainInfoState> emit) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiGateway/presentation/displays/$instanceID'),
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map json = jsonDecode(response.body);
        AppPreferences().set(entityId: json['entityId'] ?? '');
        ControlSocket().displayCode = json['code'];
        ControlSocket().token = Uri.encodeComponent(json['token']);
        Map<String, dynamic> property = json['property'];
        List<dynamic> license = property['licenses'];
        ControlSocket().licenseName = license[0]['name'];
        List<dynamic> features = property['features'];
        for (String feature in features) {
          ControlSocket().featureList.add(feature);
        }
        emit(MainInfoState.getDisplayCodeSuccess);
      } else {
        emit(MainInfoState.getDisplayCodeError);
      }
    } catch (e) {
      log(e.toString());
      // http.get maybe no network connection.
      emit(MainInfoState.getDisplayCodeError);
    }
  }

  Future<void> _registerDisplayCode(
      MainInfoEvent event, Emitter<MainInfoState> emit) async {
    emit(MainInfoState.registerDisplayCode);

    try {
      http.Response response = await http.post(
        Uri.parse('$apiGateway/presentation/displays'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({
          'id': instanceID,
          'property': {
            'version': version,
            'platform': 'android',
            'capacities': '[]'
          }
        }),
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        emit(MainInfoState.registerDisplayCodeSuccess);
      } else {
        emit(MainInfoState.registerDisplayCodeError);
      }
    } catch (e) {
      log(e.toString());
      // http.post maybe no network connection.
      emit(MainInfoState.registerDisplayCodeError);
    }
  }

  Future<void> _getOneTimePassword(
      MainInfoEvent event, Emitter<MainInfoState> emit) async {
    emit(MainInfoState.getOneTimePassword);

    try {
      http.Response response = await http.post(
        Uri.parse('$apiGateway/presentation/displays/otp/generate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode({'id': instanceID, 'count': '1'}),
      );

      if (response.statusCode == HttpStatus.created) {
        Map json = jsonDecode(response.body);
        if (json.containsKey('list')) {
          List jsonArray = json['list'];
          if (jsonArray.isNotEmpty) {
            ControlSocket().otpCode = jsonArray[0]['code'] ?? '';
            if (ControlSocket().otpCode.isNotEmpty) {
              emit(MainInfoState.getOneTimePasswordSuccess);
              return;
            }
          }
        }
      }
      // every thing else
      emit(MainInfoState.getOneTimePasswordError);
    } catch (e) {
      log(e.toString());
      // http.post maybe no network connection.
      emit(MainInfoState.getOneTimePasswordError);
    }
  }
}
