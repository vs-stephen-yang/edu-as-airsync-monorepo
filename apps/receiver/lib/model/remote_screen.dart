enum RemoteScreenType { rtc, multicast }

RemoteScreenType parseRemoteScreenType(String? name) {
  switch (name?.toLowerCase()) {
    case 'rtc':
      return RemoteScreenType.rtc;
    case 'multicast':
      return RemoteScreenType.multicast;
    default:
      return RemoteScreenType.rtc;
  }
}

