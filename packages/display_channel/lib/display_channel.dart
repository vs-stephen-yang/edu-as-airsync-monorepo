library display_channel;

export 'package:display_channel/src/display_channel_client.dart'
    show DisplayChannelClient;
export 'package:display_channel/src/channel_store.dart'
    show ConnectRequestStatus;
export 'package:display_channel/src/display_direct_server.dart'
    show DisplayDirectServer;
export 'package:display_channel/src/webtransport_direct_server.dart'
    show WebTransportDirectServer;
export 'package:display_channel/src/webtransport_certificate.dart'
    show WebTransportCertificate;
export 'package:display_channel/src/display_tunnel_server.dart'
    show DisplayTunnelServer;

// channel messages
export 'package:display_channel/src/messages/channel_message.dart';
export 'package:display_channel/src/messages/channel_message_handler.dart';

export 'package:display_channel/src/channel.dart';

// client-side
export 'package:display_channel/src/display_channel_connector.dart';

// server-side
export 'package:display_channel/src/server/connection.dart' show Connection;
export 'package:display_channel/src/server/connection_request.dart'
    show ConnectionRequest;

export 'package:display_channel/src/websocket_client_connection_stub.dart'
    if (dart.library.io) 'package:display_channel/src/websocket_client_connection_io.dart' // dart:io implementation
    if (dart.library.html) 'package:display_channel/src/websocket_client_connection_html.dart'; // dart:html implementation

export 'package:display_channel/src/websocket_client_connection_config.dart';

// encoding and decoding of display code
export 'package:display_channel/src/display_code2.dart'
    show
        decodeDisplayCode,
        encodeDisplayCode,
        DisplayCode,
        createRemoteIpCandidates,
        getInstanceGroupIdFromIp;

export 'package:display_channel/src/util/channel_util.dart'
    show fetchIPv4Addresses;

export 'package:display_channel/src/api/api_request.dart'
    show ApiRequest, buildApiRequest, SignatureLocation;
