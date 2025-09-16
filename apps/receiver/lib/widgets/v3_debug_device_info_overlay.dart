import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:flutter/material.dart';

class V3DebugDeviceInfoOverlay extends StatelessWidget {
  const V3DebugDeviceInfoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    context.splitScreenRatio;
    if (!DeviceFeatureAdapter.showDeviceInfoOverlay) {
      return SizedBox.shrink();
    }
    final size = MediaQuery.of(context).size;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final physicalWidth = (size.width * dpr).toStringAsFixed(0);
    final physicalHeight = (size.height * dpr).toStringAsFixed(0);

    return Positioned(
      top: 0,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.splitScreenRatio.name,
                  style: TextStyle(fontSize: 14, color: Colors.red)),
              Text(
                'isInMultiWindow: ${context.isInMultiWindow}, DPR: ${dpr.toStringAsFixed(2)},\n'
                'Logical: ${size.width.toStringAsFixed(1)} × ${size.height.toStringAsFixed(1)} dp,\n'
                'Physical: $physicalWidth × $physicalHeight px\n'
                'Status Bar(${context.isNavigationBarVisible}), Height: ${context.statusBarHeightPx}px\n'
                'Navigation Bar(${context.isNavigationBarVisible}), Height: ${context.navigationBarHeightPx}px',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
