import 'package:display_channel/display_channel.dart';

enum RemoteScreenType {
  rtc,
  multicast;

  DisplayGroupType get displayGroupType {
    switch (this) {
      case RemoteScreenType.rtc:
        return DisplayGroupType.unicast;
      case RemoteScreenType.multicast:
        return DisplayGroupType.multicast;
    }
  }

  static RemoteScreenType fromDisplayGroupType(DisplayGroupType? type) {
    switch (type) {
      case DisplayGroupType.unicast:
        return RemoteScreenType.rtc;
      case DisplayGroupType.multicast:
        return RemoteScreenType.multicast;
      default:
        return RemoteScreenType.rtc;
    }
  }
}
