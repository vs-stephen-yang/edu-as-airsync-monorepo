import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart';

enum BrowserAgent {
  unKnown,
  chrome,
  safari,
  firefox,
  explorer,
  edge,
  edgeChromium,
}

enum OSPlatform {
  unKnown,
  macOS,
  windows,
  iOS,
  android,
  linux,
}

// Modified from https://github.com/tomaschyly/web_browser_detect/blob/master/lib/src/browser.dart
class Browser {
  BrowserAgent get browserAgent =>
      _detected?.browserAgent ?? BrowserAgent.unKnown;

  String get browser => _browserIdentifiers[browserAgent]!;

  String get version => _version;

  OSPlatform get osPlatform => _osPlatform ?? OSPlatform.unKnown;

  String get operatingSystem => _osIdentifiers[osPlatform]!;

  static const Map<BrowserAgent, String> _browserIdentifiers =
      <BrowserAgent, String>{
    BrowserAgent.unKnown: 'Unknown browser',
    BrowserAgent.chrome: 'Chrome',
    BrowserAgent.safari: 'Safari',
    BrowserAgent.firefox: 'Firefox',
    BrowserAgent.explorer: 'Internet Explorer',
    BrowserAgent.edge: 'Edge',
    BrowserAgent.edgeChromium: 'Chromium Edge',
  };

  static const Map<OSPlatform, String> _osIdentifiers = <OSPlatform, String>{
    OSPlatform.unKnown: 'Unknown OS',
    OSPlatform.macOS: 'macOS',
    OSPlatform.windows: 'Windows',
    OSPlatform.iOS: 'iOS',
    OSPlatform.android: 'Android',
    OSPlatform.linux: 'Linux',
  };

  _BrowserDetection? _detected;
  String _version = 'Unknown version';
  OSPlatform? _osPlatform;

  /// Browser initialization
  Browser() {
    if (!kIsWeb) {
      throw Exception('Browser is supported only on the web platform');
    }

    String appVersion = window.navigator.appVersion;

    _detectBrowser(
      userAgent: window.navigator.userAgent,
      vendor: window.navigator.vendor,
      appVersion: appVersion,
    );

    _detectOS(userAgent: window.navigator.userAgent.toLowerCase());
  }

  /// Browser initialization from provided userAgent or vendor, works crossplatform
  Browser.detectFrom({
    required String userAgent,
    required String vendor,
    required String appVersion,
  }) {
    _detectBrowser(
        userAgent: userAgent, vendor: vendor, appVersion: appVersion);
    _detectOS(userAgent: userAgent.toLowerCase());
  }

  /// Alternative initialization for crossplatform, returns null instead of Exception
  static Browser? detectOrNull() {
    try {
      return Browser();
    } catch (e) {
      return null;
    }
  }

  /// Detect current browser if it is known
  _detectBrowser({
    required String userAgent,
    required String vendor,
    required String appVersion,
  }) {
    final List<_BrowserDetection> detections = <_BrowserDetection>[
      _BrowserDetection(
        browserAgent: BrowserAgent.edgeChromium,
        string: userAgent,
        subString: 'Edg',
      ),
      _BrowserDetection(
        browserAgent: BrowserAgent.chrome,
        string: userAgent,
        subString: 'Chrome',
      ),
      _BrowserDetection(
        browserAgent: BrowserAgent.safari,
        string: vendor,
        subString: 'Apple',
        versionSearch: 'Version',
      ),
      _BrowserDetection(
        browserAgent: BrowserAgent.firefox,
        string: userAgent,
        subString: 'Firefox',
      ),
      _BrowserDetection(
        browserAgent: BrowserAgent.explorer,
        string: userAgent,
        subString: 'MSIE',
        versionSearch: 'MSIE',
      ),
      _BrowserDetection(
        browserAgent: BrowserAgent.explorer,
        string: userAgent,
        subString: 'Trident',
        versionSearch: 'rv',
      ),
      _BrowserDetection(
        browserAgent: BrowserAgent.edge,
        string: userAgent,
        subString: 'Edge',
      ),
    ];

    for (_BrowserDetection detection in detections) {
      if (detection.string.contains(detection.subString)) {
        _detected = detection;

        final String versionSearchString =
            detection.versionSearch ?? detection.subString;
        String versionFromString = userAgent;
        int index = versionFromString.indexOf(versionSearchString);
        if (index == -1) {
          versionFromString = appVersion;
          index = versionFromString.indexOf(versionSearchString);
        }

        if (index == -1) {
          _version = 'Unknown version';
        } else {
          _version = versionFromString
              .substring(index + versionSearchString.length + 1);

          if (_version.split(' ').length > 1) {
            _version = _version.split(' ').first;
          }
        }

        break;
      }
    }
  }

  /// Detect current OS based on userAgent
  void _detectOS({required String userAgent}) {
    if (userAgent.contains(RegExp(r'(macintosh|macintel|macppc|mac68k|macos)',
        caseSensitive: false))) {
      _osPlatform = OSPlatform.macOS;
    } else if (userAgent
        .contains(RegExp(r'(iphone|ipad|ipod)', caseSensitive: false))) {
      _osPlatform = OSPlatform.iOS;
    } else if (userAgent.contains(
        RegExp(r'(win32|win64|windows|wince)', caseSensitive: false))) {
      _osPlatform = OSPlatform.windows;
    } else if (userAgent.contains('android')) {
      _osPlatform = OSPlatform.android;
    } else if (userAgent.contains('linux')) {
      _osPlatform = OSPlatform.linux;
    } else {
      _osPlatform = OSPlatform.unKnown;
    }
  }
}

class _BrowserDetection {
  final BrowserAgent browserAgent;
  final String string;
  final String subString;
  final String? versionSearch;

  /// BrowserDetection initialization
  _BrowserDetection({
    required this.browserAgent,
    required this.string,
    required this.subString,
    this.versionSearch,
  });
}
