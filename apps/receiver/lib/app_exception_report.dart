import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/aes_cipher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;
import 'package:http_parser/http_parser.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'app_instance_create.dart';

class AppExceptionReport {
  static final AppExceptionReport _instance = AppExceptionReport._internal();

  //private "Named constructors"
  AppExceptionReport._internal();

  // passes the instantiation to the _instance object
  factory AppExceptionReport() => _instance;

  ensureInitialized(
      ConfigSettings configSettings, PackageInfo packageInfo) async {
    if (kIsWeb) {
      _isInitialized = false;
      // todo: how to save temp file for upload. (getApplicationDocumentsDirectory did not support web)
    } else {
      _isInitialized = true;
      initializeDateFormatting('en');
      //build channel
      _methodChannel.setMethodCallHandler((call) {
        sendToServer(configSettings, packageInfo, call.method,
            call.arguments.toString());
        return call.arguments;
      });
      //create folder (It's too late to create folder when exception occurring.)
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      Directory directory =
          await (Directory('${documentsDirectory.path}/Exception').create());
      _exceptionDirectory = directory.path;

      //get device info
      _deviceInfo = await _getDeviceInfo();
    }
  }

  static const _methodChannel =
      MethodChannel('com.mvbcast.crosswalk/display_exception');

  bool _isInitialized = false;
  late String _exceptionDirectory;
  late String _deviceInfo;

  int _timeStamp = 0;
  String _error = '';

  sendToServer(ConfigSettings configSettings, PackageInfo packageInfo,
      String error, String stackTrace) async {
    if (!_isInitialized) return;

    int current = DateTime.now().millisecondsSinceEpoch;
    if ((current - _timeStamp) < 60000 && error == _error) {
      log('Exception (ignore duplicate error): $error');
      return;
    }
    //可能會連續呼叫 sendToServer()，要在 await 之前更新 _timeStamp & _error，否則會無法阻擋
    _timeStamp = current;
    _error = error;

    if (AppInstanceCreate().isRegistered /*&& kReleaseMode*/) {
      String uid = AppInstanceCreate().instanceID;

      // create file name
      String message = error.length > 90 ? error.substring(0, 90) : error;
      message = message.replaceAll('/', '_');
      final time = DateFormat('yyyy-MM-dd-HH-mm-ss-SSS').format(DateTime.now());
      String fileName = time + '-' + message + '.txt';

      // create local file
      File file = File('$_exceptionDirectory/' + fileName);
      file.writeAsStringSync(_deviceInfo + '\n\n' + error + '\n' + stackTrace);

      // upload exception file to server
      Uint8List uint8ListBytes;
      var bytes = await file.readAsBytes();
      uint8ListBytes = Uint8List.fromList(bytes);
      MediaType mediaType = MediaType('text', 'plain');
      try {
        var url = Uri.parse(
            configSettings.icarExceptionFileUrl.replaceAll('uid', uid));
        log('file url: $url');
        var request = CloseableMultipartRequest('POST', url);
        // request.headers['Authorization'] = 'bearer ';
        request.files.add(http.MultipartFile.fromBytes('file', uint8ListBytes,
            filename: fileName, contentType: mediaType));
        http.StreamedResponse streamedResponse = await request.send();

        if (streamedResponse.statusCode == 200) {}
        await for (var value
            in streamedResponse.stream.transform(utf8.decoder)) {
          Map<String, dynamic> result = json.decode(value);
          String? filePathOnServer = result['file_path'];

          //inform server for the exception file
          if (filePathOnServer != null) {
            await _httpInformException(
                configSettings, packageInfo, uid, message, filePathOnServer);
          }
        }
      } catch (e) {
        log(e.toString());
      }
    } else {
      log('Exception (debug mode): $error $stackTrace');
    }
  }

  Future<String> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      return '';
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        return 'OS: ${info.version.release}  sdkInt: ${info.version.sdkInt}  brand: ${info.brand}  model: ${info.model}  product: ${info.product} ';
      } else if (Platform.isIOS) {
        IosDeviceInfo info = await deviceInfo.iosInfo;
        return 'systemVersion: ${info.systemVersion}  systemName: ${info.systemName}  model: ${info.model}  machine: ${info.utsname.machine} ';
      } else {
        return '';
      }
    }
  }

  Future<void> _httpInformException(
      ConfigSettings configSettings,
      PackageInfo packageInfo,
      String uid,
      String message,
      String fileUrl) async {
    String url = configSettings.icarExceptionUrl +
        Uri.encodeFull(aesEncryptWithBase64(uid, configSettings.icarHostName));
    String request =
        _buildInformExceptionString(packageInfo, uid, message, fileUrl);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8'
    };
    http.Client client = http.Client();
    try {
      await client.post(Uri.parse(url), headers: headers, body: request);
    } catch (e) {
      log(e.toString());
    } finally {
      client.close();
    }
  }

  String _buildInformExceptionString(
      PackageInfo packageInfo, String uid, String message, String fileUrl) {
    String platform;
    if (kIsWeb) {
      platform = 'Web';
    } else {
      if (Platform.isIOS) {
        platform = 'iOS';
      } else if (Platform.isAndroid) {
        platform = 'Android';
      } else {
        platform = ''; // todo: support other platform.
      }
    }

    Map<String, dynamic> request = {
      'uid': uid,
      'agenda': message,
      'version': packageInfo.version,
      'agent': platform,
      'file_url': fileUrl,
      'app_name': packageInfo.appName
    };
    return json.encode(request);
  }
}

//NOTE:
// If we call http.Client.close(),
// CloseableMultipartRequest may not catch exception.
//
// After tracing, it seems process hang at this line:
// var response =
//      await stream.pipe(DelegatingStreamConsumer.typed(ioRequest));
// (in io_client.dart)
//
abstract class Closeable {
  void closeByUser();

  bool isCloseByUser();
}

//// Cancel ongoing file upload sent with http.MultipartRequest()
//// https://stackoverflow.com/a/54025600
////
class CloseableMultipartRequest extends http.MultipartRequest
    implements Closeable {
  io_client.IOClient client = io_client.IOClient(HttpClient());
  bool _isCloseByUser = false;

  CloseableMultipartRequest(String method, Uri uri) : super(method, uri) {
    _isCloseByUser = false;
  }

  @override
  void closeByUser() {
    client.close();
    _isCloseByUser = true;
  }

  @override
  bool isCloseByUser() {
    return _isCloseByUser;
  }

  @override
  Future<http.StreamedResponse> send() async {
    try {
      var response = await client.send(this);
      var stream = onDone(response.stream, client.close);
      return http.StreamedResponse(
        http.ByteStream(stream),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e) {
      client.close();
      rethrow;
    } finally {
      client.close();
    }
  }

  Stream<T> onDone<T>(Stream<T> stream, void Function() onDone) =>
      stream.transform(StreamTransformer.fromHandlers(handleDone: (sink) {
        sink.close();
        onDone();
      }));
}
