import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/utility/navigation_service_util.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectionStatusState {
  bothTunnelOn,
  bothTunnelOff,
  internetTunnelOn,
  internetTunnelOff,
  local,
}

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  final GlobalKey _buttonKey = GlobalKey();
  ConnectionStatusState? _currentState;
  Timer? _debounceTimer;

  late final StreamSubscription _mergedSubscription;

  late final ChannelProvider _channel;

  @override
  void initState() {
    super.initState();

    _channel = Provider.of<ChannelProvider>(context, listen: false);

    final tunnel = _channel.tunnelActivated;
    final pref = AppPreferences().connectivityTypeNotifier.value;
    final initialState = resolveConnectionStatus(
      tunnelServerActivated: tunnel,
      userSettingConnectivityType: pref,
    );
    _currentState = initialState;

    final channelStream = _channel.tunnelActivatedStream;

    final preferenceStream = Rx.defer(() {
      final controller = StreamController<String>();
      void listener() =>
          controller.add(AppPreferences().connectivityTypeNotifier.value);
      AppPreferences().connectivityTypeNotifier.addListener(listener);
      controller.add(AppPreferences().connectivityTypeNotifier.value);
      controller.onCancel = () {
        AppPreferences().connectivityTypeNotifier.removeListener(listener);
        controller.close();
      };
      return controller.stream;
    });

    _mergedSubscription =
        Rx.combineLatest2<bool, String, ConnectionStatusState>(
      channelStream,
      preferenceStream,
      (tunnel, pref) => resolveConnectionStatus(
        tunnelServerActivated: tunnel,
        userSettingConnectivityType: pref,
      ),
    ).listen(_handleStateUpdate);
  }

  void _handleStateUpdate(ConnectionStatusState newState) {
    final stableState = _getExpectedStableState(newState);

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    // 若新狀態屬於警告/錯誤，先顯示預期最終狀態，再等 2 秒 fallback 顯示錯誤
    if (newState == ConnectionStatusState.bothTunnelOff ||
        newState == ConnectionStatusState.internetTunnelOff) {
      setState(() => _currentState = stableState);

      _debounceTimer = Timer(const Duration(seconds: 2), () {
        setState(() => _currentState = newState);
      });
    } else {
      // 若是正常狀態，立即顯示
      setState(() => _currentState = newState);
    }
  }

  ConnectionStatusState _getExpectedStableState(ConnectionStatusState current) {
    switch (current) {
      case ConnectionStatusState.bothTunnelOff:
        return ConnectionStatusState.bothTunnelOn;
      case ConnectionStatusState.internetTunnelOff:
        return ConnectionStatusState.internetTunnelOn;
      default:
        return current;
    }
  }

  @override
  void dispose() {
    _mergedSubscription.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentState == null) return const SizedBox.shrink();

    return buildConnectionStatusWidget(
      context: context,
      state: _currentState!,
      key: _buttonKey,
      onShowDialog: _showConnectionStatusDialog,
    );
  }

  Offset? _getWidgetPosition(BuildContext context) {
    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    Offset p = renderBox.localToGlobal(Offset.zero);
    double width = renderBox.size.width;
    double height = renderBox.size.height;

    // 10 -> _TrianglePainter height, 2 -> bottom padding
    double dialogTop = p.dy + height + 10 + 2;
    // 133 + 10 -> dialog width + padding , width / 2 -> half of the button width
    double dialogLeft = p.dx - (133 + 10) + (width / 2);

    return Offset(dialogLeft, dialogTop);
  }

  Future<void> _showConnectionStatusDialog(BuildContext context,
      {required String message}) async {
    final position = _getWidgetPosition(context);
    final route = DialogRoute(
        barrierColor: Colors.transparent,
        context: context,
        builder: (_) {
          return FocusAwareBuilder(builder: (primaryFocusNode) {
            return Stack(
              children: [
                Positioned(
                  top: position?.dy,
                  left: position?.dx,
                  child: Dialog(
                    backgroundColor: context.tokens.color.vsdslColorSurface100,
                    shadowColor:
                        context.tokens.color.vsdslColorOpacityNeutralXl,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    insetPadding: EdgeInsets.zero,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 20, right: 20),
                          child: SizedBox(
                            width: 266,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: context
                                          .tokens.color.vsdslColorNeutral,
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: AutoSizeText(
                                        message,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.3,
                                          color: context
                                              .tokens.color.vsdslColorNeutral,
                                        ),
                                        maxFontSize: 12,
                                        minFontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: V3Focus(
                                    label: S
                                        .of(context)
                                        .v3_lbl_connection_dialog_close,
                                    identifier: 'v3_qa_connection_dialog_close',
                                    borderRadius: BorderRadius.circular(2),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      focusNode: primaryFocusNode,
                                      onTap: () => Navigator.pop(context),
                                      child: Text(
                                        S
                                            .of(context)
                                            .v3_main_connection_dialog_close,
                                        style: TextStyle(
                                          color: context
                                              .tokens.color.vsdslColorInfo,
                                          height: 1.3,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -10,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.center,
                            child: CustomPaint(
                              size: const Size(20, 10),
                              painter: _TrianglePainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          });
        },
        barrierDismissible: false);

    navService.setRoute(route);
    await navService.push(route);
  }

  ConnectionStatusState resolveConnectionStatus({
    required String userSettingConnectivityType,
    required bool tunnelServerActivated,
  }) {
    if (userSettingConnectivityType == 'both') {
      return tunnelServerActivated
          ? ConnectionStatusState.bothTunnelOn
          : ConnectionStatusState.bothTunnelOff;
    }

    if (userSettingConnectivityType == 'internet') {
      return tunnelServerActivated
          ? ConnectionStatusState.internetTunnelOn
          : ConnectionStatusState.internetTunnelOff;
    }

    return ConnectionStatusState.local;
  }

  Widget buildConnectionStatusWidget({
    required BuildContext context,
    required ConnectionStatusState state,
    required GlobalKey key,
    required Future<void> Function(BuildContext, {required String message})
        onShowDialog,
  }) {
    switch (state) {
      case ConnectionStatusState.bothTunnelOn:
        return const SizedBox.shrink();
      case ConnectionStatusState.bothTunnelOff:
        return V3Focus(
          label: S.of(context).v3_lbl_internet_connection_warning,
          identifier: 'v3_qa_internet_connection_warning',
          child: InkWell(
            onTap: () => onShowDialog(
              context,
              message: S.of(context).v3_main_local_connection_only_dialog_desc,
            ),
            child: _ConnectionStatusWidget(
              key: key,
              imgPath: 'assets/images/ic_local_connection_only_warning.svg',
              message: S.of(context).v3_settings_local_connection_only,
              textColor: context.tokens.color.vsdslColorOnWarningVariant,
              backgroundColor: context.tokens.color.vsdslColorWarning,
            ),
          ),
        );

      case ConnectionStatusState.internetTunnelOn:
        return _ConnectionStatusWidget(
          imgPath: 'assets/images/ic_internet_connection_only.svg',
          message: S.of(context).v3_main_internet_connection_only,
          textColor: context.tokens.color.vsdslColorOnSurface,
        );

      case ConnectionStatusState.internetTunnelOff:
        return V3Focus(
          label: S.of(context).v3_lbl_internet_connection_only_error,
          identifier: 'v3_qa_internet_connection_only_error',
          child: InkWell(
            onTap: () => onShowDialog(
              context,
              message: S
                  .of(context)
                  .v3_main_internet_connection_only_error_dialog_desc,
            ),
            child: _ConnectionStatusWidget(
              key: key,
              imgPath: 'assets/images/ic_internet_connection_only_error.svg',
              message: S.of(context).v3_main_internet_connection_only_error,
              textColor: context.tokens.color.vsdslColorOnError,
              backgroundColor: context.tokens.color.vsdslColorError,
            ),
          ),
        );

      case ConnectionStatusState.local:
        return _ConnectionStatusWidget(
          imgPath: 'assets/images/ic_local_connection_only.svg',
          message: S.of(context).v3_settings_local_connection_only,
          textColor: context.tokens.color.vsdslColorOnSurface,
        );
    }
  }
}

class _ConnectionStatusWidget extends StatelessWidget {
  final String message;
  final String imgPath;
  final Color? textColor;
  final Color? backgroundColor;

  const _ConnectionStatusWidget({
    super.key,
    required this.message,
    required this.imgPath,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: backgroundColor ?? context.tokens.color.vsdslColorSurface200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.tokens.spacing.vsdslSpacingXl.left,
        vertical: context.tokens.spacing.vsdslSpacingSm.top,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            imgPath,
            excludeFromSemantics: true,
            width: 21,
            height: 21,
            colorFilter: ColorFilter.mode(
              textColor ?? context.tokens.color.vsdslColorSurface600,
              BlendMode.srcIn,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: context.tokens.spacing.vsdslSpacingSm.left,
            ),
            child: AutoSizeText(
              message,
              style: context.tokens.textStyle.airsyncFontSubtitle600.apply(
                color: textColor ?? context.tokens.color.vsdslColorSurface600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // canvas.drawShadow(path, Colors.black26, 3, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
