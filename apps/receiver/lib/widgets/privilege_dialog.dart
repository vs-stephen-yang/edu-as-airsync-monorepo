import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PrivilegeDialog extends StatelessWidget {
  const PrivilegeDialog({Key? key, required this.title}) : super(key: key);

  static ValueNotifier<bool> showPrivilegeQrCode = ValueNotifier(false);
  final String title;

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return MenuDialog(
      backgroundColor: AppColors.primary_dialog,
      menuSize: Size(MediaQuery.of(context).size.width / 2.5,
          MediaQuery.of(context).size.height / 2),
      alignment: Alignment.center,
      edgeInsets: null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: AutoSizeText(
              title,
              style: const TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
          ),
          Flexible(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: showPrivilegeQrCode,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return Visibility(
                      visible: AppPreferences().entityId.isEmpty,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: QrImageView(
                          data: appConfig != null
                              ? appConfig.settings.prefixQRCode +
                                  AppInstanceCreate().displayInstanceID
                              : '',
                          version: QrVersions.auto,
                          size: 120.0,
                          padding: const EdgeInsets.all(5),
                          embeddedImage:
                              const Svg('assets/images/ic_logo_my.svg'),
                          embeddedImageStyle: const QrEmbeddedImageStyle(
                            // Cannot set too large, will scan failure!!
                            size: Size(30, 30),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AutoSizeText(
                    S.of(context).main_privilege_message,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: FocusElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.neutral1,
                backgroundColor: Colors.white,
                minimumSize: const Size(80, 15),
              ),
              onClick: () {
                navService.popUntil('/home');
              },
              child: AutoSizeText(
                S.of(context).main_privilege_close,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
