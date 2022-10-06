import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PrivilegeDialog extends StatelessWidget {
  const PrivilegeDialog({Key? key, required this.title}) : super(key: key);

  static ValueNotifier<bool> showPrivilegeQrCode = ValueNotifier(false);
  final String title;

  @override
  Widget build(BuildContext context) {
    AppConfig? appConfig = AppConfig.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: AppColors.primary_dialog,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 2.5,
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
                          child: QrImage(
                            data: appConfig != null
                                ? appConfig.settings.prefixQRCode +
                                    AppInstanceCreate().displayInstanceID
                                : '',
                            version: QrVersions.auto,
                            size: 120.0,
                            padding: const EdgeInsets.all(5),
                            embeddedImage:
                                const Svg('assets/images/ic_logo_my.svg'),
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              // Cannot set too large, will scan failure!!
                              size: const Size(30, 30),
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: AutoSizeText(
                  S.of(context).main_privilege_close,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                ),
                style: ElevatedButton.styleFrom(
                  onPrimary: AppColors.neutral1,
                  primary: Colors.white,
                  minimumSize: const Size(80, 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
