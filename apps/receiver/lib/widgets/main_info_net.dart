import 'dart:async';
import 'dart:math' as math;

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainInfoInternet extends StatefulWidget {
  const MainInfoInternet({super.key});

  @override
  State createState() => _MainInfoInternetState();
}

class _MainInfoInternetState extends State<MainInfoInternet> {
  static const int maxCountDown = 300;
  static final ValueNotifier<bool> _isEyeOpen = ValueNotifier(true);
  static final ValueNotifier<int> _countDownProgress = ValueNotifier(300);
  static final ValueNotifier<int> _otp = ValueNotifier(0000);
  static Timer? _mGetOTPTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _otp.value = math.Random().nextInt(9000) + 1000;
  }

  @override
  void dispose() {
    _cancelOTP();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 400,
      height: 400,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: AppColors.primary_grey,
      ),
      child: Consumer<ChannelProvider>(
        builder: (context, channelProvider, child) {
          return (channelProvider.connectNet)
              ? Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  children: <Widget>[
                    Text(
                      S.of(context).main_content_display_code,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getDisplayCode(channelProvider.displayCode),
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      S.of(context).main_content_one_time_password,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (channelProvider.displayCode.isNotEmpty)
                      ValueListenableBuilder<bool>(
                        valueListenable: _isEyeOpen,
                        builder: (context, eyeOpen, child) {
                          if (_mGetOTPTimer == null) _generateOTP();
                          return Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            children: <Widget>[
                              ValueListenableBuilder<int>(
                                valueListenable: _otp,
                                builder: (context, otp, child) {
                                  if (!channelProvider.otpList
                                      .contains(_otp.value.toString())) {
                                    channelProvider
                                        .setOtpList(_otp.value.toString());
                                  }
                                  return Text(
                                    eyeOpen ? otp.toString() : 'XXXX',
                                    style: const TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: _countDownProgress,
                                builder: (context, progress, child) {
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(math.pi),
                                    child: SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        value: progress / maxCountDown,
                                        strokeWidth: 4,
                                        backgroundColor: Colors.black,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              FocusIconButton(
                                icons: eyeOpen
                                    ? Icons.remove_red_eye_sharp
                                    : Icons.remove_red_eye_outlined,
                                splashRadius: 20,
                                focusColor: Colors.grey,
                                hasFocusSize: AppUIConstant.iconNotFocusSize,
                                notFocusSize: AppUIConstant.iconNotFocusSize,
                                onClick: () {
                                  AppAnalytics().trackEventAppOTPMaskClick();
                                  _isEyeOpen.value = !_isEyeOpen.value;
                                },
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: AppColors.iconDisableStandbyBackground,
                        size: 120,
                      ),
                      Text(
                        S.of(context).main_status_no_network,
                        style: const TextStyle(
                          color: AppColors.iconDisableStandbyBackground,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  _getDisplayCode(String displayCode) {
    String result = '';
    for (int i = 0; i < displayCode.length; i++) {
      if (i % 3 == 0 && result.isNotEmpty) {
        result += '-';
      }
      result += displayCode.substring(i, i + 1);
    }
    return result;
  }

  _generateOTP() {
    _mGetOTPTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _countDownProgress.value -= 1;
      if (_countDownProgress.value == 0) {
        _otp.value = math.Random().nextInt(9000) + 1000;
        _countDownProgress.value = maxCountDown;
      }
    });
  }

  _cancelOTP() {
    _mGetOTPTimer?.cancel();
    _mGetOTPTimer = null;
    _countDownProgress.value = maxCountDown;
  }
}
