import 'package:args/args.dart';
import 'package:display_channel/display_channel.dart';
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
      'code',
      mandatory: true,
    );

  ArgResults argResults = parser.parse(arguments);

  final stage = parseStage(argResults['stage']);
  final code = argResults['code'];

  final apiOrigin = getStageApiUrl(stage);

  log().info('Stage: ${stage.name}');
  log().info('API origin: $apiOrigin');

  final displayCode = decodeDisplayCode(code);

  log().info('Instance Index: ${displayCode.instanceIndex}');
  log().info('Instance Group Id: ${displayCode.instanceGroupId}');

  final instanceIndex = displayCode.instanceIndex;
  if (instanceIndex == null) {
    return;
  }

  log().info('Fetching instance info');

  final stopwatch = Stopwatch();
  stopwatch.start();

  final tunnelApiUrl = await fetchInstanceInfo(
    apiOrigin,
    instanceIndex,
    displayCode.instanceGroupId,
  );

  stopwatch.stop();

  log().info('Fetched. Elapsed time: ${stopwatch.elapsedMilliseconds} ms');

  log().info('tunnelApiUrl: $tunnelApiUrl');
}
