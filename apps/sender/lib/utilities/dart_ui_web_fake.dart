FakeBrowserDetection browser = FakeBrowserDetection.instance;

class FakeBrowserDetection {
  FakeBrowserDetection._();

  static final FakeBrowserDetection instance = FakeBrowserDetection._();

  bool get isChromium => false;

  bool get isSafari => false;

  bool get isFirefox => false;

  bool get isEdge => false;
}
