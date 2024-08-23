import 'package:args/args.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'package:display_channel/src/util/log.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'apiOrigin',
      defaultsTo: 'https://api2.gateway.dev.airsync.net',
    )
    ..addOption(
      'instanceId',
      defaultsTo: 'integration-test-001',
    )
    ..addOption(
      'groupId',
      defaultsTo: '1',
    );

  ArgResults argResults = parser.parse(arguments);

  final apiOrigin = argResults['apiOrigin'];
  String instanceId = argResults['instanceId'];
  int groupId = int.parse(argResults['groupId']);

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

  stopwatch.reset();
  stopwatch.start();
  final tunnelApiUrl =
      await fetchInstanceInfo(apiOrigin, instanceInfo.instanceIndex, groupId);
  stopwatch.stop();

  log().info('Fetched. Elapsed time: ${stopwatch.elapsedMilliseconds} ms');

  log().info('tunnelApiUrl: $tunnelApiUrl');
}
