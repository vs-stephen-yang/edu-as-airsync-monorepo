import 'package:args/args.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'package:display_channel/src/util/log.dart';
import 'package:display_channel/src/util/stage_util.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'stage',
      defaultsTo: 'dev',
    )
    ..addOption(
      'instanceId',
      defaultsTo: 'test-d96b4693-19d4-4cdd-8882-b064174f483f',
    )
    ..addOption(
      'groupId',
      defaultsTo: '1',
    );

  ArgResults argResults = parser.parse(arguments);

  final stage = parseStage(argResults['stage']);
  final instanceId = argResults['instanceId'];
  final groupId = int.parse(argResults['groupId']);

  final apiOrigin = getStageApiUrl(stage);

  log().info('Stage: ${stage.name}');
  log().info('API origin: $apiOrigin');
  log().info('Instance Id: $instanceId');
  log().info('Group Id: $groupId');

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
