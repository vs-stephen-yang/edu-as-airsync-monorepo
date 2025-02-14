enum Stage {
  dev,
  stage,
  prod,
}

Stage parseStage(String stageName) {
  try {
    return Stage.values.firstWhere((e) => e.name == stageName);
  } catch (e) {
    throw ArgumentError('Unknown stage name: $stageName');
  }
}

String getStageApiUrl(Stage stage) {
  switch (stage) {
    case Stage.dev:
      return 'https://api.dev.airsync.net';
    case Stage.stage:
      return 'https://api.stage.airsync.net';
    case Stage.prod:
      return 'https://api.airsync.net';
  }
}
