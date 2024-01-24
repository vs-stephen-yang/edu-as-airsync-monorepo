library display_channel;

export 'package:display_channel/src/display_channel_client.dart'
    show DisplayChannelClient;
export 'package:display_channel/src/channel_server.dart'
    show ConnectRequestStatus;
export 'package:display_channel/src/display_direct_server.dart'
    show DisplayDirectServer;
export 'package:display_channel/src/display_tunnel_server.dart'
    show DisplayTunnelServer;

// channel messages
export 'package:display_channel/src/messages/channel_message.dart';
export 'package:display_channel/src/messages/channel_message_handler.dart';

export 'package:display_channel/src/channel.dart';

// client-side
export 'src/channel.dart' show Channel;

// server-side
export 'package:display_channel/src/server/connection.dart' show Connection;
export 'package:display_channel/src/server/connection_request.dart'
    show ConnectionRequest;

export 'package:display_channel/src/websocket_client_connection_stub.dart'
    if (dart.library.io) 'package:display_channel/src/websocket_client_connection_io.dart' // dart:io implementation
    if (dart.library.html) 'package:display_channel/src/websocket_client_connection_html.dart'; // dart:html implementation

// encoding and decoding of display code
export 'package:display_channel/src/display_code.dart'
    show decodeDisplayCode, encodeDisplayCode, DisplayCode;
