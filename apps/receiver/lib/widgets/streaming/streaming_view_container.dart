import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/streaming/grid_view_config.dart';
import 'package:display_flutter/widgets/streaming/list_view_config.dart';
import 'package:display_flutter/widgets/streaming/single_view_config.dart';
import 'package:display_flutter/widgets/streaming/split_view_config.dart';
import 'package:display_flutter/widgets/streaming/v3_streaming_view.dart';
import 'package:flutter/cupertino.dart';

class StreamingViewContainer extends StatelessWidget {
  const StreamingViewContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiWindowAdaptiveLayout(
      landscape: V3StreamingView(
        config: gridViewConfig,
      ),
      landscapeOneThird: V3StreamingView(
        config: listViewConfig,
      ),
      launcherMain: V3StreamingView(config: gridViewConfig),
      floatingDefault: V3StreamingView(config: splitViewConfig),
      launcher: V3StreamingView(config: singleViewConfig),
    );
  }
}
