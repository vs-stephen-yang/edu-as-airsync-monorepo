import 'dart:ui';

double getSafeDevicePixelRatio({double fallback = 1.0}) {
  final views = PlatformDispatcher.instance.views;
  return views.isNotEmpty ? views.first.devicePixelRatio : fallback;
}
