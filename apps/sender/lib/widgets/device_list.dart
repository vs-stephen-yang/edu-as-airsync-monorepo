import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/device_list_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({super.key});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late DeviceListProvider _deviceListProvider;
  late ChannelProvider _channelProvider;
  late AirSyncBonsoirService _connectService;
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

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.6,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          _presentStateProvider.presentMainPage();
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const Image(
                        image: Svg('assets/images/ic_quick_connect.svg'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    S.of(context).main_device_list,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeTitle,
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Divider(
                color: Colors.white12,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Consumer<DeviceListProvider>(
                builder: (BuildContext context, DeviceListProvider value,
                    Widget? child) {
                  return ListView.builder(
                      itemCount: value.devices.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            _connectService = value.devices[index];

                            AppAnalytics.instance.setGlobalProperty(
                                'display_code', _connectService.displayCode);
                            trackEvent(
                              'click_quick_connect',
                              EventCategory.session,
                              target: _connectService.displayCode,
                            );

                            _channelProvider.startDirectConnect(
                                otp: null,
                                service: _connectService,
                                presentStateProvider: _presentStateProvider);
                          },
                          child: ListTile(
                            title: Row(children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  value.devices[index].name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'IP',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ]),
                            subtitle: Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value.devices[index].displayCode,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value.devices[index].ip,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
              child: Divider(
                color: Colors.white12,
              ),
            ),
          ],
        ),
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
        _showEnterPinDialog();
        break;
      case ChannelConnectError.authenticationRequired:
        _showEnterPinDialog();
        break;
      case ChannelConnectError.networkError:
        break;
      case ChannelConnectError.unknownError:
        break;
      default:
        break;
    }
  }

  void _onOkPressed(List<TextEditingController> controllers) {
    String otp = '';
    for (var element in controllers) {
      otp += _convertFullWidthToHalfWidth(element.text);
    }
    _channelProvider.startDirectConnect(
        otp: otp,
        service: _connectService,
        presentStateProvider: _presentStateProvider);
  }

  void _showEnterPinDialog() {
    isPinDialogShown = true;

    List<TextEditingController> controllers =
        List.generate(4, (index) => TextEditingController());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(S.of(context).device_list_enter_pin),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                4,
                (index) => Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.iconPinCodeBackground,
                        borderRadius: BorderRadius.circular(6), // 设置圆角半径为10
                      ),
                      child: TextFormField(
                        controller: controllers[index],
                        autofocus: index == 0,
                        // set the initial focus to the first digit of OTP
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (String value) {
                          if (value.length == 1 &&
                              index < controllers.length - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        onFieldSubmitted: (String value) {
                          if (value.length == 1 && index == 3) {
                            _channelProvider.resetMessage();
                            _onOkPressed(controllers);
                            Navigator.of(context).pop();
                            isPinDialogShown = false;
                          }
                        },
                      ),
                    )),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.white), // 设置按钮背景颜色
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey), // 设置按钮文字颜色
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                    side: const BorderSide(color: Colors.grey), // 设置按钮边框
                  ),
                ),
              ),
              onPressed: () {
                _channelProvider.resetMessage();
                Navigator.of(context).pop();
                isPinDialogShown = false;
              },
              child: Text(S.of(context).present_select_screen_cancel),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blue), // 设置按钮背景颜色
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white), // 设置按钮文字颜色
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 设置按钮圆角
                    side: const BorderSide(color: Colors.blue), // 设置按钮边框
                  ),
                ),
              ),
              onPressed: () {
                _channelProvider.resetMessage();
                _onOkPressed(controllers);
                Navigator.of(context).pop();
                isPinDialogShown = false;
              },
              child: Text(S.of(context).device_list_enter_pin_ok),
            ),
          ],
        );
      },
    );
  }

  String _convertFullWidthToHalfWidth(String input) {
    return input.replaceAllMapped(
      RegExp(r'[０-９]'),
      (Match match) =>
          String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFEE0),
    );
  }
}
