FakeBrowserDetection browser = FakeBrowserDetection.instance;

class FakeBrowserDetection {
  FakeBrowserDetection._();

  static final FakeBrowserDetection instance = FakeBrowserDetection._();

  bool get isChromium => false;

  bool get isSafari => false;

  bool get isFirefox => false;

  bool get isEdge => false;
}

FakeWindow window = FakeWindow.instance;

class FakeWindow {
  FakeWindow._();

  static final FakeWindow instance = FakeWindow._();

  FakeNavigator get navigator => FakeNavigator();
}

class FakeNavigator {
  String get userAgent => "";
}
