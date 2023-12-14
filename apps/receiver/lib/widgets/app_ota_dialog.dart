import 'dart:io';

import 'package:app_ota_flutter/app_ota_flutter.dart';
import 'package:app_ota_flutter/model/ota_info.dart';
import 'package:display_flutter/app_update_helper.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    AppUpdateHelper().initializeChecking(listener: this);
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
        if (AppUpdateHelper().otaFlavor == OtaFlavor.ifp ||
            AppUpdateHelper().otaFlavor == OtaFlavor.edla) {
          _installNow(info);
        } else {
          _showOTADialog(status, info);
        }
        break;
      case UpdateStatus.updateInApp:
        AppUpdateHelper().startInAppUpdate();
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
        return WillPopScope(
          // False will prevent and true will allow to dismiss
          onWillPop: () async => false,
          child: AlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: Image(
                    image: Svg('assets/images/ic_logo_my.svg'),
                  ),
                ),
                const SizedBox(width: 20),
                Text(S.of(context).update_title),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).update_message),
                const SizedBox(height: 40),
                if (status == UpdateStatus.updateDownloading)
                  ValueListenableBuilder<double>(
                    valueListenable: progress,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey,
                        color: const Color(0xFFB1E26E),
                      );
                    },
                  ),
                if (status == UpdateStatus.updateDownloading)
                  ValueListenableBuilder<double>(
                    valueListenable: progress,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: Text('${(value * 100).toInt()}%'),
                      );
                    },
                  ),
              ],
            ),
            actions: [
              if (status == UpdateStatus.updateDownloaded)
                TextButton(
                  onPressed: () {
                    _installNow(info);
                  },
                  child: Text(S.of(context).update_install_now),
                )
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
}
