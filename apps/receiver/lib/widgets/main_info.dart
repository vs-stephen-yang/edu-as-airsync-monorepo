import 'dart:async';
import 'dart:math' as math;

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/blocs/main_info_bloc.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/moderator.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainInfo extends StatefulWidget {
  const MainInfo({Key? key}) : super(key: key);
  static ValueNotifier<bool> showMainInfo = ValueNotifier(true);

  // Update Display Privilege Status,...
  static bool updateDisplayStatus = false;

  @override
  State createState() => _MainInfoState();
}

class _MainInfoState extends State<MainInfo> {
  late MainInfoBloc _mainInfoBloc;
  static const int maxCountDown = 30;
  static final ValueNotifier<bool> _isEyeOpen = ValueNotifier(true);
  static final ValueNotifier<double> _countDownProgress = ValueNotifier(1);
  static int _countDownValue = maxCountDown;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainInfoBloc = MainInfoBloc(
        AppConfig.of(context)!.settings.apiGateway,
        AppInstanceCreate().displayInstanceID,
        AppConfig.of(context)!.appVersion)
      ..add(GetDisplayCode());
  }

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return BlocProvider(
      create: (_) => _mainInfoBloc,
      child: BlocListener<MainInfoBloc, MainInfoState>(
        listener: (context, state) {
          switch (state) {
            case MainInfoState.getDisplayCodeSuccess:
              AppAnalytics()
                  .setEventProperties(displayCode: ControlSocket().displayCode);
              if (appConfig != null) {
                ControlSocket().connect(appConfig.settings.apiGateway);
              }
              BlocProvider.of<MainInfoBloc>(context).add(GetOneTimePassword());
              break;
            case MainInfoState.getDisplayCodeError:
              _showSnackBarMessage(S.of(context).main_get_display_code_failure);
              BlocProvider.of<MainInfoBloc>(context).add(RegisterDisplayCode());
              break;
            case MainInfoState.getDisplayCodeInfoSuccess:
              if (AppPreferences().entityId.isNotEmpty &&
                  ControlSocket().entityId.isEmpty) {
                AppAnalytics().trackEventUnenrolled();
                AppAnalytics()
                    .setEventProperties(entityId: ControlSocket().entityId);
              } else if (AppPreferences().entityId.isEmpty &&
                  ControlSocket().entityId.isNotEmpty) {
                AppAnalytics()
                    .setEventProperties(entityId: ControlSocket().entityId);
                AppAnalytics().trackEventEnrolled();
              }
              AppPreferences().set(entityId: ControlSocket().entityId);

              if (ControlSocket().featureList.isEmpty) {
                AppAnalytics().trackEventLicenseRevoked();
                // Disable SplitScreen and Moderator features.
                ModeratorView().logout();
                streamFunctionKey.currentState?.setState(() {
                  ControlSocket().moderator = null;
                });
              } else {
                AppAnalytics().trackEventLicenseGranted();
              }
              break;
            case MainInfoState.registerDisplayCodeSuccess:
              BlocProvider.of<MainInfoBloc>(context).add(GetDisplayCode());
              break;
            case MainInfoState.registerDisplayCodeError:
              _showSnackBarMessage(
                  S.of(context).main_register_display_code_failure);
              Timer(const Duration(seconds: 5), () async {
                BlocProvider.of<MainInfoBloc>(context)
                    .add(RegisterDisplayCode());
              });
              break;
            case MainInfoState.getOneTimePasswordSuccess:
              Timer.periodic(const Duration(milliseconds: 100), (timer) {
                if (timer.tick < maxCountDown * 10) {
                  _countDownProgress.value =
                      1 - (timer.tick / 10 / maxCountDown);
                  _countDownValue = maxCountDown - timer.tick ~/ 10;
                } else {
                  _countDownProgress.value = 1;
                  _countDownValue = maxCountDown;
                  timer.cancel();
                  BlocProvider.of<MainInfoBloc>(context)
                      .add(GetOneTimePassword());
                }
              });
              break;
            case MainInfoState.getOneTimePasswordError:
              _countDownProgress.value = 1;
              _countDownValue = maxCountDown;
              if (!Home.showCloudOff.value) {
                _showSnackBarMessage(
                    S.of(context).main_content_one_time_password_get_fail);
              }
              Timer(const Duration(seconds: 5), () async {
                BlocProvider.of<MainInfoBloc>(context)
                    .add(GetOneTimePassword());
              });
              break;
            default:
              break;
          }
        },
        child: BlocBuilder<MainInfoBloc, MainInfoState>(
          builder: (context, state) {
            return ValueListenableBuilder(
              valueListenable: MainInfo.showMainInfo,
              builder: (BuildContext context, bool value, Widget? child) {
                if (value) {
                  if (!ControlSocket().isPresenting() &&
                      ControlSocket().moderator == null &&
                      MainInfo.updateDisplayStatus) {
                    MainInfo.updateDisplayStatus = false;
                    BlocProvider.of<MainInfoBloc>(context)
                        .add(GetDisplayCodeInfo());
                  }
                }

                return Visibility(
                  visible: value,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: ControlSocket().isPresenting()
                          ? AppColors.primaryBlackA30
                          : Colors.transparent,
                    ),
                    child: Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _buildMainInfoWidget(),
                        _buildEnrollWidget(appConfig),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  _getDisplayCode() {
    String result = '';
    for (int i = 0; i < ControlSocket().displayCode.length; i++) {
      if (i % 3 == 0 && result.isNotEmpty) {
        result += '-';
      }
      result += ControlSocket().displayCode.substring(i, i + 1);
    }
    return result;
  }

  _showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  _buildMainInfoWidget() {
    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      children: <Widget>[
        Text(
          S.of(context).main_content_display_code,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          _getDisplayCode(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          S.of(context).main_content_one_time_password,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _isEyeOpen,
          builder: (BuildContext context, bool value, Widget? child) {
            return Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: <Widget>[
                Text(
                  value ? ControlSocket().otpCode : "XXXX",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _countDownProgress,
                  builder: (BuildContext context, double value, Widget? child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 4,
                              backgroundColor: Colors.black,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                        ),
                        Text(
                          _countDownValue.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    AppAnalytics().trackEventAppOTPMaskClick();
                    _isEyeOpen.value = !_isEyeOpen.value;
                  },
                  icon: Image.asset(
                    value
                        ? 'assets/images/ic_eye_open.png'
                        : 'assets/images/ic_eye_close.png',
                    width: 48,
                    height: 48,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  _buildEnrollWidget(AppConfig? appConfig) {
    return Visibility(
      visible: AppPreferences().entityId.isEmpty,
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        children: <Widget>[
          Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: <Widget>[
              Container(
                height: 2,
                width: 50,
                color: Colors.white,
              ),
              Text(
                S.of(context).main_content_scan_or,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                height: 2,
                width: 50,
                color: Colors.white,
              ),
            ],
          ),
          // Add size box to prevent flick.
          SizedBox(
            width: 120,
            height: 120,
            child: QrImage(
              data: appConfig != null
                  ? (AppInstanceCreate().isInstalledInVBS100)
                      ? appConfig.settings.prefixQRCode +
                          AppInstanceCreate().serialNumber
                      : appConfig.settings.prefixQRCode +
                          AppInstanceCreate().instanceID
                  : '',
              version: QrVersions.auto,
              size: 120.0,
              backgroundColor: Colors.white,
              embeddedImage: const Svg('assets/images/ic_logo_my.svg'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                // Cannot set too large, will scan failure!!
                size: const Size(25, 25),
              ),
            ),
          ),
          Text(
            S.of(context).main_content_scan_to_enroll,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
