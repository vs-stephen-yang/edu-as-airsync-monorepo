import 'dart:convert';
import 'dart:developer';

import 'package:display_flutter/utility/ApiException.dart';
import 'package:http/http.dart' as http;

class ApiResponseFactory {
  static dynamic returnResponse(http.StreamedResponse streamResponse) async {
    var response = await http.Response.fromStream(streamResponse);
    switch (response.statusCode) {
      case 201:
      case 200:
        var responseJson = json.decode(response.body.toString());
        log('responseJson: $responseJson');
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 404:
        throw NotFoundException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
