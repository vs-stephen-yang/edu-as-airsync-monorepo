import 'dart:io';

import 'package:app_ota_flutter/app_ota_flutter.dart';
import 'package:app_ota_flutter/model/ota_info.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_update_helper.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class AppOTADialog extends StatefulWidget {
  const AppOTADialog({super.key, required this.child});

  final Widget child;

  @override
  State createState() => AppOTADialogState();
}

class AppOTADialogState extends State<AppOTADialog>
    implements AppUpdateListener {
  ValueNotifier<double> progress = ValueNotifier(0);
  BuildContext? ctxDownloading; //variable for downloading dialog context

  late AppUpdateHelper _appUpdateHelper;

  @override
  void initState() {
    _appUpdateHelper = context.read<AppUpdateHelper>();

    _appUpdateHelper.initializeChecking(listener: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onUpdateCheckFinished(UpdateStatus status, OtaInfo? info,
      {double? progress}) {
    switch (status) {
      case UpdateStatus.updateDownloading:
        if (progress == -1) {
          _showOTADialog(status, info);
        } else if (progress != null) {
          this.progress.value = progress;
        }
        break;
      case UpdateStatus.updateDownloaded:
        if (_appUpdateHelper.otaFlavor == OtaFlavor.ifp ||
            _appUpdateHelper.otaFlavor == OtaFlavor.edla) {
          _installNow(info);
        } else {
          _showOTADialog(status, info);
        }
        break;
      case UpdateStatus.updateInApp:
        _appUpdateHelper.startInAppUpdate();
        break;
      case UpdateStatus.updateToDate:
      case UpdateStatus.unknown:
        // Not available
        break;
    }
  }

  _showOTADialog(UpdateStatus status, OtaInfo? info) {
    if (ctxDownloading != null) Navigator.pop(ctxDownloading!);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ctxDownloading = context;
        return PopScope(
          // Using canPop=false to block back key return,
          // it will break "Show Prompt mechanism"
          canPop: false,
          child: AlertDialog(
            title: Semantics(
              identifier: 'v3_qa_ota_dialog_tittle',
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: Image(
                      image: Svg('assets/images/ic_logo_airsync_icon.svg'),
                    ),
                  ),
                  const Gap(20),
                  // title will expand the dialog, no need to use -
                  Text(
                    S.of(context).update_title,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // message will expand the dialog, no need to use -
                Text(
                  S.of(context).update_message,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorInfo,
                    fontSize: 14,
                  ),
                ),
                const Gap(40),
                if (status == UpdateStatus.updateDownloading)
                  ValueListenableBuilder<double>(
                    valueListenable: progress,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor:
                            context.tokens.color.vsdslColorSurface300,
                        color: context.tokens.color.vsdslColorSecondary,
                      );
                    },
                  ),
                const Gap(10),
                if (status == UpdateStatus.updateDownloading)
                  ValueListenableBuilder<double>(
                    valueListenable: progress,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Align(
                        alignment: Alignment.bottomRight,
                        // Only for percentage, no need to use -
                        child: Text(
                          '${(value * 100).toInt()}%',
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorInfo,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            actions: [
              if (status == UpdateStatus.updateDownloaded)
                _updateDialogButton(
                  text: S.of(context).update_install_now,
                  textColor: Colors.white,
                  backgroundColor: context.tokens.color.vsdslColorPrimary,
                  onPressed: () {
                    trackEvent('start_ota', EventCategory.system);
                    _installNow(info);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  _installNow(OtaInfo? info) async {
    var folder = await getExternalStorageDirectory();
    var otaFile = File("${folder?.path}/${info?.fileName}");
    AppUpdateHelper().startAppUpdate(otaFile.path);
  }

  Widget _updateDialogButton(
      {required String text,
      required Color textColor,
      required Color backgroundColor,
      required GestureTapCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        width: 105,
        height: 40,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: backgroundColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.31),
                    blurRadius: 24,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: V3AutoHyphenatingText(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
