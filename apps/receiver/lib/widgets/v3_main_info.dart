import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/v3_header_bar.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_main_info_landscape.dart';
import 'package:display_flutter/widgets/v3_no_network_status.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3MainInfo extends StatelessWidget {
  const V3MainInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiWindowLayout(
      builder: (context, constraints, ratio, isMultiWindow, isPortrait,
          isFloatWindow) {
        if (!isPortrait) {
          if (ratio == SplitScreenRatio.launcher) {
            return buildSmallFrame(width: 280, height: 157.3);
          }
          if (ratio == SplitScreenRatio.floatingDefault) {
            return buildSmallFrame(width: 533.3333, height: 300);
          }
        }
        return Container(
          alignment: Alignment.center,
          margin: !isPortrait
              ? const EdgeInsets.symmetric(vertical: 106, horizontal: 53)
              : const EdgeInsets.symmetric(vertical: 120, horizontal: 29),
          decoration: _buildContainerDecoration(context),
          child: Consumer<ConnectivityProvider>(
            builder: (_, connectivityProvider, __) {
              return connectivityProvider.connectionStatus ==
                      ConnectivityResult.none
                  ? const V3NoNetworkStatus()
                  : !isPortrait
                      ? const V3MainInfoLandscape()
                      : _buildPortraitContent(context);
            },
          ),
        );
      },
    );
  }

  Widget buildSmallFrame({
    required double width,
    required double height,
  }) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              V3HeaderBar(),
              Expanded(
                child: Consumer<ConnectivityProvider>(
                  builder: (_, connectivityProvider, __) {
                    return connectivityProvider.connectionStatus ==
                            ConnectivityResult.none
                        ? const V3NoNetworkStatus()
                        : const V3MainInfoLandscape();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ShapeDecoration _buildContainerDecoration(BuildContext context) {
    return ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        side: BorderSide(
          width: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
      ),
      color: context.tokens.color.vsdslColorSurface100.withValues(alpha: 0.84),
    );
  }

  Widget _buildPortraitContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _portraitContent(context),
        ),
        const Gap(30),
        Container(
          height: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
        const Expanded(
          child: V3ParticipantsView(isLandscape: false),
        ),
      ],
    );
  }

  Widget _portraitContent(BuildContext context) {
    // 創建 ScrollController
    final ScrollController scrollController = ScrollController();
    return ValueListenableBuilder<int>(
      valueListenable: AppPreferences().textSizeOptionNotifier,
      builder: (context, value, child) {
        return Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 30, top: 30),
                child: V3Scrollbar(
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: const V3Instruction(isCastToDevice: false),
                  ),
                ),
              ),
            ),
            Container(
              width: 171,
              height: 240,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: _buildQrCodeDecoration(context),
              child: const V3QrCodeQuickConnect(),
            ),
          ],
        );
      },
    );
  }

  ShapeDecoration _buildQrCodeDecoration(BuildContext context) {
    return ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.radii.vsdslRadiusXl,
        side: BorderSide(
          width: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
      ),
    );
  }
}
