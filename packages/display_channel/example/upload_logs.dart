import 'package:args/args.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'package:display_channel/src/util/log.dart';

import 'package:http/http.dart' as http;

import 'package:display_channel/src/util/stage_util.dart';

Future<void> uploadFileFromStrings(
  String url,
  String strings,
) async {
  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Content-Type': 'text/plain',
    },
    body: strings,
  );

  if (response.statusCode == 200) {
    log().info('File uploaded successfully');
  } else {
    log().warning('File upload failed with status: ${response.statusCode}');
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'stage',
      defaultsTo: 'dev',
    )
    ..addOption(
      'instanceId',
      defaultsTo: 'test-530f0210-d345-446e-8c5e-8c682526d6cd',
    );

  ArgResults argResults = parser.parse(arguments);

  final stage = parseStage(argResults['stage']);
  final instanceId = argResults['instanceId'];
  final apiOrigin = getStageApiUrl(stage);

  log().info('Stage: ${stage.name}');
  log().info('API Origin: $apiOrigin');
  log().info('Instance Id: $instanceId');

  final stopwatch = Stopwatch();

  stopwatch.start();
  final result = await createLogUploadUrl(apiOrigin, instanceId);
  stopwatch.stop();

  log().info('Registered. Elapsed time: ${stopwatch.elapsedMilliseconds} ms');

  log().info('URL: ${result.url}');
  log().info('Key: ${result.key}');

  // Upload logs
  List<String> strings = ['Line 1', 'Line 2', 'Line 3'];
  String combinedString = strings.join('\n');

  await uploadFileFromStrings(result.url, combinedString);
}
