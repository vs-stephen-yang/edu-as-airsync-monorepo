import 'package:display_channel/display_channel.dart';

ChannelCloseReason convertRemoteReasonToChannelCloseReason(Reason reason) {
  ChannelCloseCode code = reason.code >= ChannelCloseCode.values.length
      ? ChannelCloseCode.remoteUnknown
      : ChannelCloseCode.values[reason.code];

  if (code == ChannelCloseCode.close) {
    code = ChannelCloseCode.remoteClose;
  }

  return ChannelCloseReason(
    code,
    text: reason.text,
  );
}

Reason convertChannelCloseReasonToReason(ChannelCloseReason reason) {
  return Reason(
    reason.code.index,
    text: reason.text,
  );
}

Reason? convertConnectRequestStatusToReason(ConnectRequestStatus status) {
  switch (status) {
    case ConnectRequestStatus.invalidOtp:
      return Reason(
        ChannelCloseCode.authenticationError.index,
        text: 'Wrong OTP',
      );
    case ConnectRequestStatus.invalidDisplayCode:
      return Reason(
        ChannelCloseCode.invalidDisplayCode.index,
        text: 'Wrong display code',
      );
    default:
      return null;
  }
}
