import 'package:display_channel/src/util/log.dart';

import 'api_util.dart';

void main() async {
  const instanceId = '100';
  const instanceGroupId = 1;
  const apiBaseUrl = 'https://api.gateway.dev2.airsync.net';

  log().info('Registering instance');

  final instanceInfo = await registerInstance(
    apiBaseUrl,
    instanceId,
    instanceGroupId,
  );
  log().info('Instance Index: ${instanceInfo.instanceIndex}');
  log().info('Instance Group Id: ${instanceInfo.tunnelApiUrl}');

  log().info('Fetching instance info');
  final tunnelUrl = await fetchInstanceInfo(
    apiBaseUrl,
    instanceInfo.instanceIndex,
    instanceGroupId,
  );

  log().info('Tunnel URL: $tunnelUrl');
}
