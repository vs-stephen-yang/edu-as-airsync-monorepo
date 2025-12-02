import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/widgets/streaming/streaming_features.dart';
import 'package:display_flutter/widgets/v3_feature_set.dart';
import 'package:flutter/material.dart';

/// Streaming 功能列包裝器
///
/// 根據 streaming 狀態自動切換顯示：
/// - Streaming 進行中：顯示 StreamingFeaturesContainer（整合版）
/// - Streaming 未進行：顯示 V3FeatureSet（原本的功能選單）
class StreamingFeatureWrapper extends StatelessWidget {
  const StreamingFeatureWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HybridConnectionList.hybridSplitScreenCount,
      builder: (context, count, child) {
        // 判斷是否在 streaming 進行中
        // 當有任何 streaming 連線時，視為 streaming 進行中
        final isStreaming = count > 0;

        if (isStreaming) {
          // Streaming 進行中：顯示整合版功能列
          return const StreamingFeaturesContainer();
        } else {
          // Streaming 未進行：顯示原本的 V3FeatureSet
          return const V3FeatureSet();
        }
      },
    );
  }
}
