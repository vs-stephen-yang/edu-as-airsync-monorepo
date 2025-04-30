import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/device_list_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3DeviceList extends StatefulWidget {
  const V3DeviceList({super.key});

  @override
  State<V3DeviceList> createState() => _V3DeviceListState();
}

class _V3DeviceListState extends State<V3DeviceList> {
  late DeviceListProvider _deviceListProvider;
  late ChannelProvider _channelProvider;
  AirSyncBonsoirService? _connectService;
  late PresentStateProvider _presentStateProvider;

  bool isPinDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      _deviceListProvider
          .startDiscovery(AppConfig.of(context)?.settings.versionPostfix ?? '');
    });
    _presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
  }

  bool isMobile() => (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    _channelProvider = Provider.of<ChannelProvider>(context);
    _deviceListProvider =
        Provider.of<DeviceListProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (_channelProvider.channelConnectError != null && !isPinDialogShown) {
        _showConnectErrorMessage(_channelProvider.channelConnectError!);
      }
    });

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isMobile() ? 641 : 504,
        maxHeight: isMobile() ? 541 : 538,
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 22, left: 22, right: 22),
        margin: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: context.tokens.color.vsdswColorSurface100,
          shape: RoundedRectangleBorder(
            borderRadius: context.tokens.radii.vsdswRadius2xl,
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x28151C32),
              blurRadius: 16,
              offset: Offset(0, 8),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    S.of(context).main_device_list,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.tokens.color.vsdswColorOnSurface,
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      V3Focus(
                        identifier: 'v3_qa_device_list_close',
                        child: SizedBox(
                          width:
                              (Platform.isAndroid || Platform.isIOS) ? 48 : 28,
                          height:
                              (Platform.isAndroid || Platform.isIOS) ? 48 : 28,
                          child: InkWell(
                            onTap: () {
                              _presentStateProvider.presentMainPage();
                            },
                            child: Icon(
                              size: 20.0,
                              Icons.close,
                              semanticLabel:
                                  S.of(context).v3_lbl_device_list_close,
                              color: context.tokens.color.vsdswColorOnSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap((Platform.isAndroid || Platform.isIOS) ? 10 : 22),
            Divider(
              color: context.tokens.color.vsdswColorOutline,
            ),
            Expanded(
              child: Consumer<DeviceListProvider>(
                builder: (BuildContext context, DeviceListProvider value,
                    Widget? child) {
                  return ListView.builder(
                    itemCount: value.devices.length,
                    itemBuilder: (context, index) {
                      final airSyncBonsoirService = value.devices[index];
                      return V3Focus(
                        label:
                            '${airSyncBonsoirService.name} ${airSyncBonsoirService.displayCode}',
                        identifier: 'v3_qa_device_list_item_$index',
                        child: InkWell(
                          child: isMobile()
                              ? buildMobileItem(airSyncBonsoirService, context)
                              : buildDeskTopItem(
                                  airSyncBonsoirService, context),
                          onTap: () {
                            setState(() {
                              _connectService = airSyncBonsoirService;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Divider(
              color: context.tokens.color.vsdswColorOutline,
            ),
            buildInkWellButton(
              buildContext: context,
              text: 'Next',
              enable: _connectService != null,
              onTap: () {
                if (_connectService == null) return;
                AppAnalytics.instance.setGlobalProperty(
                    'display_code', _connectService!.displayCode);

                trackEvent('click_quick_connect', EventCategory.session);
                _channelProvider.startDirectConnect(
                    otp: null,
                    service: _connectService!,
                    presentStateProvider: _presentStateProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInkWellButton(
      {required BuildContext buildContext,
      required bool enable,
      required String text,
      required GestureTapCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 32, left: 6, right: 6),
      child: V3Focus(
        label: S.of(context).v3_lbl_device_list_next,
        identifier: 'v3_qa_device_list_next',
        child: InkWell(
          onTap: enable ? onTap : null,
          child: Container(
            alignment: Alignment.center,
            height: 48,
            clipBehavior: Clip.antiAlias,
            constraints: isMobile()
                ? null
                : const BoxConstraints(
                    maxWidth: 240,
                  ),
            decoration: ShapeDecoration(
              color: enable
                  ? buildContext.tokens.color.vsdswColorPrimary
                  : buildContext.tokens.color.vsdswColorDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: buildContext.tokens.radii.vsdswRadiusFull,
              ),
              shadows: [
                BoxShadow(
                  color: enable
                      ? context.tokens.color.vsdswColorOpacityNeutralLg
                      : const Color(0x28151C32), // token沒有顏色
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: enable
                    ? buildContext.tokens.color.vsdswColorOnPrimary
                    : buildContext.tokens.color.vsdswColorOnDisabled,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 0.07,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDeskTopItem(
      AirSyncBonsoirService airSyncBonsoirService, BuildContext context) {
    final onSelected = _connectService == airSyncBonsoirService;
    final style = TextStyle(
      color: onSelected
          ? context.tokens.color.vsdswColorOnPrimary
          : context.tokens.color.vsdswColorOnSurface,
      fontSize: 16,
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold,
    );
    return Container(
      alignment: Alignment.center,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: _connectService == airSyncBonsoirService
            ? context.tokens.color.vsdswColorPrimary
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.radii.vsdswRadiusLg,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                  width: 24,
                  height: 24,
                  colorFilter: onSelected
                      ? ColorFilter.mode(
                          context.tokens.color.vsdswColorOnSurfaceInverse,
                          BlendMode.srcIn)
                      : null,
                  'assets/images/ic_device_list_screen.svg'),
              const Gap(8),
              Text(
                airSyncBonsoirService.name,
                style: style,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              SvgPicture.asset(
                width: 24,
                height: 24,
                'assets/images/ic_device_list_qrcode.svg',
                excludeFromSemantics: true,
              ),
              const Gap(8),
              Text(
                airSyncBonsoirService.displayCode,
                textAlign: TextAlign.left,
                style: style,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMobileItem(
      AirSyncBonsoirService airSyncBonsoirService, BuildContext context) {
    final onSelected = _connectService == airSyncBonsoirService;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: onSelected ? context.tokens.color.vsdswColorPrimary : null,
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.radii.vsdswRadiusXl,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
              width: 32,
              height: 32,
              colorFilter: onSelected
                  ? ColorFilter.mode(
                      context.tokens.color.vsdswColorOnSurfaceInverse,
                      BlendMode.srcIn)
                  : null,
              'assets/images/ic_device_list_screen.svg'),
          const Gap(8),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    airSyncBonsoirService.name,
                    style: TextStyle(
                      color: onSelected
                          ? context.tokens.color.vsdswColorOnPrimary
                          : context.tokens.color.vsdswColorOnSurface,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    airSyncBonsoirService.displayCode,
                    style: TextStyle(
                      color: onSelected
                          ? context.tokens.color.vsdswColorOnPrimary
                          : context.tokens.color.vsdswColorOnSurface,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _deviceListProvider.stopDiscovery();
    _deviceListProvider.clearDevices();
    _channelProvider.resetMessage();
    super.dispose();
  }

  _showConnectErrorMessage(ChannelConnectError error) {
    switch (error) {
      case ChannelConnectError.instanceNotFound:
      case ChannelConnectError.invalidDisplayCode:
      case ChannelConnectError.rateLimitExceeded:
      case ChannelConnectError.connectionModeUnsupported:
        break;
      case ChannelConnectError.invalidOtp:
        trackEvent('invalid_pin_code', EventCategory.session,
            properties: {'connectivity': 'intranet'});
        _showNewEnterPinDialog(
            errorMsg: S.current.v3_device_list_dialog_invalid_otp);
        break;
      case ChannelConnectError.authenticationRequired:
        _showNewEnterPinDialog();
        break;
      case ChannelConnectError.networkError:
        break;
      case ChannelConnectError.unknownError:
        break;
    }
  }

  void _onConnect(String otp) {
    if (_connectService == null) return;
    _channelProvider.startDirectConnect(
        otp: otp,
        service: _connectService!,
        presentStateProvider: _presentStateProvider);
  }

  void _showNewEnterPinDialog({String? errorMsg}) {
    isPinDialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DialogView(
          title: S.current.v3_device_list_dialog_title,
          errorMessage: errorMsg,
          onClose: () {
            _channelProvider.resetMessage();
            Navigator.of(context).pop();
            isPinDialogShown = false;
          },
          onConnect: (opt) {
            _channelProvider.resetMessage();

            trackEvent('enter_pin_code', EventCategory.session,
                properties: {'connectivity': 'intranet'});
            _onConnect(opt);
            Navigator.of(context).pop();
            isPinDialogShown = false;
          },
        );
      },
    );
  }
}

class DialogView extends Dialog {
  final String title;
  final String? errorMessage;
  final Function(String) onConnect;
  final VoidCallback onClose;

  const DialogView(
      {super.key,
      required this.title,
      required this.onConnect,
      required this.onClose,
      this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: context.tokens.spacing.vsdswSpacingLg,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: isMobile() ? 359 : 504,
          maxHeight: isMobile() ? 284 : 296,
        ),
        decoration: ShapeDecoration(
          color: context.tokens.color.vsdswColorSurface100,
          shape: RoundedRectangleBorder(
            borderRadius: context.tokens.radii.vsdswRadius2xl,
          ),
          shadows: [
            BoxShadow(
              color: context.tokens.color.vsdswColorOpacityNeutralMd,
              blurRadius: 16,
              offset: Offset(0, 8),
              spreadRadius: 0,
            )
          ],
        ),
        child: SizedBox.expand(
          child: Container(
            color: context.tokens.color.vsdswColorSurface100,
            child: Column(
              children: [
                Row(
                  children: [
                    const Gap(20),
                    const Spacer(),
                    AutoSizeText(
                      title,
                      minFontSize: 20,
                      style: TextStyle(
                        color: context.tokens.color.vsdswColorOnSurface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Material(
                      child: InkWell(
                        onTap: onClose,
                        child: Container(
                          color: context.tokens.color.vsdswColorSurface100,
                          child: Icon(
                            size: 20.0,
                            Icons.close,
                            color: context.tokens.color.vsdswColorOnSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                Container(
                  constraints:
                      isMobile() ? null : const BoxConstraints(maxWidth: 300),
                  child: OTPInputWidget(
                    errorMessage: errorMessage,
                    onTap: onConnect,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isMobile() => (Platform.isAndroid || Platform.isIOS);
}

class OTPInputWidget extends StatefulWidget {
  const OTPInputWidget({super.key, this.errorMessage, required this.onTap});

  final Function(String) onTap;
  final String? errorMessage;

  @override
  OTPInputWidgetState createState() => OTPInputWidgetState();
}

class OTPInputWidgetState extends State<OTPInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool buttonEnable = false;

  void _onChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        buttonEnable = true;
      } else {
        buttonEnable = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: context.tokens.color.vsdswColorSurface100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: isMobile()
                  ? context.tokens.spacing.vsdswSpacingSm
                  : const EdgeInsets.only(
                      top: 32, bottom: 16, left: 32, right: 32),
              height: 56,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: context.tokens.color.vsdswColorSurface100,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1,
                      color: widget.errorMessage == null
                          ? context.tokens.color.vsdswColorSecondaryVariant
                          : context.tokens.color.vsdswColorError),
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: [
                  BoxShadow(
                    color: widget.errorMessage == null
                        ? context.tokens.color.vsdswColorSurface200
                        : const Color(0xFFFFD9DF),
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                    spreadRadius: 4,
                  )
                ],
              ),
              child: TextFormField(
                controller: _controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: focusNode.hasFocus
                      ? null
                      : S.current.device_list_enter_pin,
                  labelStyle: TextStyle(
                    color: context.tokens.color.vsdswColorOnDisabled,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0.11,
                  ),
                  border: InputBorder.none,
                  // 去掉底線
                  enabledBorder: InputBorder.none,
                  // 去掉底線
                  focusedBorder: InputBorder.none, // 去掉底線
                ),
                onChanged: _onChanged,
              ),
            ),
            if (widget.errorMessage != null)
              createErrorWidget(widget.errorMessage!),
            buildButton(
              buildContext: context,
              text: S.current.v3_device_list_dialog_connect,
              enable: buttonEnable,
              onTap: () {
                if (!buttonEnable) return;
                widget.onTap.call(_controller.text);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget createErrorWidget(String errorMsg) {
    return Container(
      height: 16,
      margin: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
              width: 16, height: 16, 'assets/images/ic_device_list_error.svg'),
          const SizedBox(width: 4),
          Text(
            errorMsg,
            style: TextStyle(
              color: context.tokens.color.vsdswColorError,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 0.10,
              letterSpacing: 0.24,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(
      {required BuildContext buildContext,
      required bool enable,
      required String text,
      required GestureTapCallback onTap}) {
    return Material(
      child: Container(
        color: context.tokens.color.vsdswColorSurface100,
        child: InkWell(
          onTap: enable ? onTap : null,
          child: Container(
            margin: isMobile()
                ? const EdgeInsets.only(top: 16, bottom: 32, left: 6, right: 6)
                : const EdgeInsets.only(top: 22, left: 32, right: 32),
            alignment: Alignment.center,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: enable
                  ? buildContext.tokens.color.vsdswColorPrimary
                  : buildContext.tokens.color.vsdswColorDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: buildContext.tokens.radii.vsdswRadiusFull,
              ),
              shadows: [
                BoxShadow(
                  color: enable
                      ? context.tokens.color.vsdswColorOpacityPrimaryLg
                      : context.tokens.color.vsdswColorOpacityNeutralMd,
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: enable
                    ? buildContext.tokens.color.vsdswColorOnPrimary
                    : buildContext.tokens.color.vsdswColorOnDisabled,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 0.07,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isMobile() => (Platform.isAndroid || Platform.isIOS);
}
