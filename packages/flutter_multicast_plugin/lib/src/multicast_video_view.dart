import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MulticastVideoView extends StatelessWidget {
  final int textureId;
  final ValueListenable<double?> aspectRatioListenable;

  const MulticastVideoView({
    super.key,
    required this.textureId,
    required this.aspectRatioListenable,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double?>(
      valueListenable: aspectRatioListenable,
      builder: (context, aspectRatio, _) {
        if (aspectRatio == null) return const SizedBox.shrink();
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Texture(textureId: textureId),
        );
      },
    );
  }
}
