import 'package:display_channel/src/messages/channel_message.dart';

class ChannelMessageHandler {
  void onDisplayStatus(DisplayStatusMessage msg) {}
  void onJoinDisplay(JoinDisplayMessage msg) {}
  void onAllowPresent(AllowPresentMessage msg) {}
  void onStartPresent(StartPresentMessage msg) {}
  void onStopPresent(StopPresentMessage msg) {}
  void onPresentAccepted(PresentAcceptedMessage msg) {}
  void onPresentRejected(PresentRejectedMessage msg) {}
  void onPresentSignal(PresentSignalMessage msg) {}
  void onPresentChangeQuality() {}
}
