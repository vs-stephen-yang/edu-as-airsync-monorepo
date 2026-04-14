import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/channel_message_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'convertRemoteReasonToChannelCloseReason(close) should return remoteClose.',
      () {
    //arrange
    final reason = Reason(0);

    //action
    final actual = convertRemoteReasonToChannelCloseReason(reason);

    //assert
    expect(actual.code, ChannelCloseCode.remoteClose);
  });

  test('convertRemoteReasonToChannelCloseReason() should handle unknown code',
      () {
    //arrange
    final reason = Reason(100);

    //action
    final actual = convertRemoteReasonToChannelCloseReason(reason);

    //assert
    expect(actual.code, ChannelCloseCode.remoteUnknown);
  });
}
