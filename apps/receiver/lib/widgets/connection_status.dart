import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/utility/navigation_service_util.dart';
import 'package:display_flutter/widgets/focus_aware_builder.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Provider.of<ChannelProvider>(context, listen: false)
          .tunnelActivatedStream
          .stream,
      builder: (context, snapshot) => ValueListenableBuilder(
          valueListenable: AppPreferences().connectivityTypeNotifier,
          builder: (context, userSettingConnectivityType, child) {
            final tunnelServerActivated = snapshot.data ?? false;
            if (userSettingConnectivityType == ConnectivityType.both.name) {
              return tunnelServerActivated
                  ? const SizedBox.shrink()
                  : V3Focus(
                      child: InkWell(
                        onTap: () => _showConnectionStatusDialog(context,
                            message: S
                                .of(context)
                                .v3_main_local_connection_only_dialog_desc),
                        child: _ConnectionStatusWidget(
                          key: _buttonKey,
                          imgPath:
                              'assets/images/ic_local_connection_only_warning.svg',
                          message:
                              S.of(context).v3_settings_local_connection_only,
                          color: context.tokens.color.vsdslColorWarning,
                        ),
                      ),
                    );
            }

            if (userSettingConnectivityType == ConnectivityType.internet.name) {
              if (tunnelServerActivated) {
                return _ConnectionStatusWidget(
                  imgPath: 'assets/images/ic_internet_connection_only.svg',
                  message: S.of(context).v3_main_internet_connection_only,
                  color: context.tokens.color.vsdslColorSurface600,
                );
              }

              return V3Focus(
                child: InkWell(
                  onTap: () => _showConnectionStatusDialog(context,
                      message: S
                          .of(context)
                          .v3_main_internet_connection_only_error_dialog_desc),
                  child: _ConnectionStatusWidget(
                    key: _buttonKey,
                    imgPath:
                        'assets/images/ic_internet_connection_only_error.svg',
                    message:
                        S.of(context).v3_main_internet_connection_only_error,
                    color: context.tokens.color.vsdslColorError,
                  ),
                ),
              );
            }

            return _ConnectionStatusWidget(
              imgPath: 'assets/images/ic_local_connection_only.svg',
              message: S.of(context).v3_settings_local_connection_only,
            );
          }),
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
}

class _ConnectionStatusWidget extends StatelessWidget {
  final String message;
  final String imgPath;
  final Color? color;

  const _ConnectionStatusWidget({
    super.key,
    required this.message,
    required this.imgPath,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.tokens.color.vsdslColorSurface200,
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
          Image(
            image: Svg(imgPath),
            color: color ?? context.tokens.color.vsdslColorSurface600,
            width: 21,
            height: 21,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: context.tokens.spacing.vsdslSpacingSm.left,
            ),
            child: AutoSizeText(
              message,
              style: context.tokens.textStyle.airsyncFontSubtitle600.apply(
                color: color ?? context.tokens.color.vsdslColorSurface600,
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
