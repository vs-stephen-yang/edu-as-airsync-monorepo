
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainInfoLan extends StatefulWidget {
  const MainInfoLan({super.key});
  static ValueNotifier<bool> showMainInfo = ValueNotifier(true);

  @override
  State createState() => _MainInfoState();
}

class _MainInfoState extends State<MainInfoLan> {
  static final ValueNotifier<bool> _isPinCode = ValueNotifier(true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);

    return ValueListenableBuilder(
      valueListenable: MainInfoLan.showMainInfo,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: AppColors.primary_grey,
            ),
            child: channelProvider.lanNetWork
                ? ValueListenableBuilder(
                    valueListenable: _isPinCode,
                    builder: (BuildContext context, bool value,
                        Widget? child) {
                      return Column(
                        children: [
                          const Spacer(),
                          Text(
                            value ? 'Enter Pin Code' : 'Scan to enroll',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          value
                              ? Wrap(
                                  direction: Axis.horizontal,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${channelProvider.getPinCode().substring(0,3)} - ${channelProvider.getPinCode().substring(3,6)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 35,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    FocusIconButton(
                                      childNotFocus: const Icon(
                                        Icons.refresh,
                                        color: AppColors.primary_white,
                                      ),
                                      hasFocusSize: AppUIConstant
                                          .iconHasFocusSize,
                                      notFocusSize: AppUIConstant
                                          .iconNotFocusSize,
                                      onClick: () {
                                        AppAnalytics()
                                            .trackEventAppOTPMaskClick();
                                        // _isEyeOpen.value = !_isEyeOpen.value;
                                      },
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16),
                                  child: QrImageView(
                                    data: 'https://www.example.com', // TODO: should be changed to...
                                    version: QrVersions.auto,
                                    size: 150,
                                    backgroundColor: Colors.white,
                                    gapless: false,
                                  ),
                                ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                _isPinCode.value = !_isPinCode.value;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 41, 121, 255), // isButtonEnabled?
                                fixedSize: const Size(300, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: value
                                        ? Image.asset(
                                            'assets/images/ic_pin.png',
                                          )
                                        : const Icon(
                                            Icons.qr_code,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                  ),
                                  Text(value ? 'QR Code' : 'Pin Code',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Column(
                    children: [
                      const Spacer(),
                      const Icon(
                        Icons.wifi_off,
                        color: AppColors.iconDisableStandbyBackground,
                        size: 120,
                      ),
                      const Text(
                        'You’re currently offline',
                        style: TextStyle(
                          color: AppColors.iconDisableStandbyBackground,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            _isPinCode.value = !_isPinCode.value;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 41, 121, 255), // isButtonEnabled?
                            fixedSize: const Size(300, 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: ValueListenableBuilder(
                              valueListenable: _isPinCode,
                              builder: (BuildContext context,
                                  bool value, Widget? child) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8),
                                      child: value
                                          ? Image.asset(
                                              'assets/images/ic_pin.png',
                                            )
                                          : const Icon(
                                              Icons.qr_code,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                    ),
                                    Text(
                                      value ? 'QR Code' : 'Pin Code',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
