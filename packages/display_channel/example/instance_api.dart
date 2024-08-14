import 'package:args/args.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'package:display_channel/src/util/log.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'apiOrigin',
      defaultsTo: 'https://api.gateway.dev2.airsync.net',
    );

  ArgResults argResults = parser.parse(arguments);

  final apiOrigin = argResults['apiOrigin'];
  String instanceId = 'integration-test-001';
  int groupId = 1;

  log().info('instanceId: $instanceId');
  log().info('groupId: $groupId');

  final stopwatch = Stopwatch();

  log().info('Registering instance');

  stopwatch.start();
  final instanceInfo = await registerInstance(apiOrigin, instanceId, groupId);
  stopwatch.stop();

  log().info('Registered. Elapsed time: ${stopwatch.elapsedMilliseconds} ms');

  log().info('instanceIndex: ${instanceInfo.instanceIndex}');
  log().info('tunnelApiUrl: ${instanceInfo.tunnelApiUrl}');

  log().info('Fetching instance info');

  stopwatch.start();
  final tunnelApiUrl =
      await fetchInstanceInfo(apiOrigin, instanceInfo.instanceIndex, groupId);
  stopwatch.stop();

  log().info('Fetched. Elapsed time: ${stopwatch.elapsedMilliseconds} ms');

  log().info('tunnelApiUrl: $tunnelApiUrl');
}
