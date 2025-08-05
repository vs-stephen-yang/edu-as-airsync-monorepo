import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_ui_constant.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/utility/misc_util.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainInfo extends StatelessWidget {
  const MainInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChannelProvider, InstanceInfoProvider>(
      builder: (context, channelProvider, instanceInfo, child) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                  alignment: Alignment.center,
                  width: 400,
                  height: 400,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: AppColors.primaryGrey,
                  ),
                  child: (channelProvider.isNetworkConnected)
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
                              getDisplayCodeVisualIdentity(
                                  instanceInfo.displayCode),
                              style: const TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            Text(
                              S.of(context).main_content_one_time_password,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (instanceInfo.displayCode.isNotEmpty)
                              ValueListenableBuilder<bool>(
                                valueListenable: channelProvider.isEyeOpen,
                                builder: (_, eyeOpen, __) {
                                  return Wrap(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 16,
                                    children: <Widget>[
                                      ValueListenableBuilder<String>(
                                        valueListenable: channelProvider.otp,
                                        builder: (_, otp, __) {
                                          return Text(
                                            eyeOpen ? otp : 'XXXX',
                                            style: const TextStyle(
                                              fontFamily: 'Inconsolata',
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 4,
                                            ),
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder<int>(
                                        valueListenable:
                                            channelProvider.countDownProgress,
                                        builder: (_, progress, __) {
                                          return Transform(
                                            alignment: Alignment.center,
                                            transform:
                                                Matrix4.rotationY(math.pi),
                                            child: SizedBox(
                                              width: 26,
                                              height: 26,
                                              child: CircularProgressIndicator(
                                                value: progress /
                                                    channelProvider
                                                        .maxCountDown,
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
                                      FocusIconButton(
                                        icons: eyeOpen
                                            ? Icons.remove_red_eye_sharp
                                            : Icons.remove_red_eye_outlined,
                                        splashRadius: 20,
                                        focusColor: Colors.grey,
                                        hasFocusSize:
                                            AppUIConstant.iconNotFocusSize,
                                        notFocusSize:
                                            AppUIConstant.iconNotFocusSize,
                                        onClick: () {
                                          channelProvider.isEyeOpen.value =
                                              !channelProvider.isEyeOpen.value;
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
                        )),
            ),
            ValueListenableBuilder<bool>(
                valueListenable: channelProvider.isLanModeOnly,
                builder: (context, value, _) {
                  return value
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              // Change the color of the Toast
                              color: Colors.grey,
                              // Change the border radius of the Toast
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: AutoSizeText(
                              S.of(context).main_content_lan_only,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : const SizedBox();
                }),
          ],
        );
      },
    );
  }
}
