import 'dart:async';
import 'dart:math' as math;

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainInfoInternet extends StatefulWidget {
  const MainInfoInternet({super.key});
  static ValueNotifier<bool> showMainInfo = ValueNotifier(true);

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
    _otp.value = math.Random().nextInt(9000)+1000;
  }

  @override
  void dispose() {
    _cancelOTP();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);

    return ValueListenableBuilder(
      valueListenable: MainInfoInternet.showMainInfo,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: value,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: AppColors.primary_grey,
            ),
            child: channelProvider.connectNet
                ? Wrap(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    children: <Widget>[
                      Text(
                        S.of(context).main_content_display_code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _getDisplayCode(channelProvider.displayCode),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        S.of(context).main_content_one_time_password,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (channelProvider.displayCode.isNotEmpty)
                        ValueListenableBuilder(
                          valueListenable: _isEyeOpen,
                          builder: (BuildContext context, bool value, Widget? child) {
                            if (_mGetOTPTimer == null) _generateOTP();
                            return Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              children: <Widget>[
                                ValueListenableBuilder<int>(
                                  valueListenable: _otp,
                                  builder: (BuildContext context, int otp,
                                      Widget? child) {
                                    if (!channelProvider.otpList.contains(_otp.value.toString())) {
                                      channelProvider.setOtpList(_otp.value.toString());
                                    }
                                    return Text(
                                      value ? otp.toString() : 'XXXX',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 35,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _countDownProgress,
                                  builder: (BuildContext context, int value,
                                      Widget? child) {
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          value: value / maxCountDown,
                                          strokeWidth: 4,
                                          backgroundColor: Colors.black,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                InkWell(
                                  child: Icon(
                                    value
                                        ? Icons.remove_red_eye_sharp
                                        : Icons.remove_red_eye_outlined,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  onTap: () {
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
                : const Column(
                    children: [
                      Spacer(),
                      Icon(
                        Icons.wifi_off,
                        color: AppColors.iconDisableStandbyBackground,
                        size: 120,
                      ),
                      Text(
                        'You’re currently offline',
                        style: TextStyle(
                          color: AppColors.iconDisableStandbyBackground,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
          ),
        );
      },
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
        _otp.value = math.Random().nextInt(9000)+1000;
        _countDownProgress.value = maxCountDown;
      }
    });
  }

  _cancelOTP() {
    _mGetOTPTimer?.cancel();
    _mGetOTPTimer = null;
    _countDownProgress.value = maxCountDown;
  }

  _showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
