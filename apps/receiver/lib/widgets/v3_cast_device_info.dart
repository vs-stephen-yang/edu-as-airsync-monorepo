import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_cast_devices_view.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_no_network_status.dart';
import 'package:display_flutter/widgets/v3_qrcode_image.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3CastDeviceInfo extends StatelessWidget {
  const V3CastDeviceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          side: BorderSide(
            width: 1,
            color: context.tokens.color.vsdslColorOutline,
          ),
        ),
        color: context.tokens.color.vsdslColorSurface100,
      ),
      child: Consumer<ConnectivityProvider>(
        builder: (_, connectivityProvider, __) {
          if (connectivityProvider.connectionStatus ==
              ConnectivityResult.none) {
            return const V3NoNetworkStatus();
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildHeader(context),
              Expanded(
                child: MultiWindowAdaptiveLayout(
                  portrait: const V3CastDevicePortraitLayout(),
                  landscape: const V3CastDeviceLandscapeLayout(),
                  landscapeHalf: const V3CastDevicePortraitLayout(),
                  landscapeOneThird: const V3CastDevicePortraitLayout(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const Gap(13),
        Container(
          alignment: Alignment.center,
          child: V3AutoHyphenatingText(
            S.of(context).v3_cast_to_device_menu_title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.tokens.color.vsdslColorOnSurface,
            ),
          ),
        ),
        const Gap(13),
        Container(
          height: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
      ],
    );
  }
}

/// V3CastDevicePortraitLayout
///
/// 此版面設計為直式顯示的投放裝置畫面，分為上下兩區：
///
/// - 上半部包含操作說明與 QR code，根據實際內容自動撐開高度。
/// - 下半部顯示可用裝置列表，其高度會根據剩餘空間決定：
///   - 若剩餘空間 < miniHeight，則下半部固定為 miniHeight 並允許整體滾動。
///   - 若剩餘空間 >= miniHeight，則裝置區填滿剩餘空間。
///
/// 使用 GlobalKey 於排版後量測上半部實際高度，確保動態適配並避免 hit test 錯誤。
class V3CastDevicePortraitLayout extends StatefulWidget {
  const V3CastDevicePortraitLayout({super.key});

  @override
  State<V3CastDevicePortraitLayout> createState() =>
      _V3CastDevicePortraitLayoutState();
}

class _V3CastDevicePortraitLayoutState
    extends State<V3CastDevicePortraitLayout> {
  static const miniHeight = 400.0;

  // 使用 GlobalKey 取得上半部實際渲染後的高度
  final GlobalKey _topKey = GlobalKey();

  // 儲存上半部實際高度
  double _topHeight = 0;

  @override
  void initState() {
    super.initState();
    // 當畫面第一次完成渲染後，觸發取得上方實際高度
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTopHeight());
  }

  // 計算上半部 widget 的實際高度
  void _updateTopHeight() {
    final context = _topKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      if (!mounted) return;
      setState(() {
        _topHeight = renderBox.size.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ScrollController scrollController = ScrollController();

        // 計算畫面剩餘的空間：總高度 - 上半部高度
        final remainingHeight = constraints.maxHeight - _topHeight;

        // 根據剩餘空間設定下半部高度：
        // - 小於 miniHeight 時設為 miniHeight（表示整個畫面會變 scrollable）
        // - 否則使用實際剩餘高度
        final deviceListHeight =
            remainingHeight < miniHeight ? miniHeight : remainingHeight;

        return V3Scrollbar(
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 上半部：包含操作說明、QR code 等，並用 key 標記
                Padding(
                  key: _topKey,
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    children: const [
                      V3Instruction(isCastToDevice: true),
                      V3OrDivider(),
                      Gap(17),
                      V3QrCodeInstruction(),
                      Gap(17),
                    ],
                  ),
                ),

                // 下半部：設備列表區塊，會根據剩餘高度動態決定大小
                Container(
                  height: deviceListHeight,
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    color: context.tokens.color.vsdslColorSurface200
                        .withValues(alpha: 0.32),
                  ),
                  child: const V3CastDevicesView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class V3CastDeviceLandscapeLayout extends StatelessWidget {
  const V3CastDeviceLandscapeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: V3Scrollbar(
              controller: scrollController,
              thumbVisibility: false,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const V3Instruction(isCastToDevice: true),
                    const Gap(8),
                    const V3OrDivider(),
                    const Gap(17),
                    const V3QrCodeInstruction(),
                    const Gap(17),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 11,
          child: Container(
            decoration: ShapeDecoration(
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(30)),
              ),
              color: context.tokens.color.vsdslColorSurface200
                  .withValues(alpha: 0.32),
            ),
            child: const V3CastDevicesView(),
          ),
        ),
      ],
    );
  }
}

class V3OrDivider extends StatelessWidget {
  const V3OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            color: context.tokens.color.vsdslColorOutline,
          ),
        ),
        SizedBox(
          width: 50,
          child: V3AutoHyphenatingText(
            S.of(context).v3_cast_to_device_menu_or,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.tokens.color.vsdslColorOnSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            color: context.tokens.color.vsdslColorOutline,
          ),
        ),
      ],
    );
  }
}

class V3QrCodeInstruction extends StatelessWidget {
  const V3QrCodeInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Container(
      height: 160,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.radii.vsdslRadiusXl,
          side: BorderSide(
            width: 1,
            color: context.tokens.color.vsdslColorOutline,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 27,
      ),
      child: Row(
        children: [
          const V3QrCodeImage(size: 120),
          const Gap(20),
          Expanded(
            child: V3Scrollbar(
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    V3AutoHyphenatingText(
                      S.of(context).v3_cast_to_device_menu_quick_connect1,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                    ),
                    const Gap(5),
                    V3AutoHyphenatingText(
                      S.of(context).v3_cast_to_device_menu_quick_connect2,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
