import 'package:display_flutter/providers/channel_provider.dart';

class RTCPlayOrder {
  final List<String?> _playOrder = List.filled(4, null);

  void add(String id) {
    int checkIndex = _playOrder.indexOf(id);
    if (checkIndex != -1) return;
    int index = _playOrder.indexOf(null);
    if (index != -1) {
      _playOrder[index] = id;
    }
  }

  void remove(String id) {
    int index = _playOrder.indexOf(id);
    if (index != -1) {
      _playOrder[_playOrder.indexOf(id)] = null;
    }
  }

  List<String?> getAllOrder() {
    return _playOrder;
  }

  int getOrderByIndex(int index) {
    for (int i = 0; i < ChannelProvider.channelRtcConnectors.length; i++) {
      if (ChannelProvider.channelRtcConnectors[i].clientId == _playOrder[index]) {
        return i;
      }
    }
    return 999;
  }

  int getOrder(String clientId) {
    int index = _playOrder.indexOf(clientId);
    if (index != -1) {
      for (int j = 0; j < ChannelProvider.channelRtcConnectors.length; j++) {
        if (ChannelProvider.channelRtcConnectors[j].clientId == clientId) {
          return j;
        }
      }
    }
    return 999;
  }
}