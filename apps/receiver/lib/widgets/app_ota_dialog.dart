import 'package:display_flutter/app_update_helper.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppOTADialog extends StatefulWidget {
  const AppOTADialog({super.key, required this.child});

  final Widget child;

  @override
  State createState() => AppOTADialogState();
}

class AppOTADialogState extends State<AppOTADialog> {
  late AppUpdateHelper _appUpdateHelper;

  @override
  void initState() {
    log.info(
        '[OTA Dialog] INIT: instance=$hashCode route=${ModalRoute.of(context)?.settings.name}');
    _appUpdateHelper = context.read<AppUpdateHelper>();
    _appUpdateHelper.initializeChecking();
    super.initState();
  }

  @override
  void dispose() {
    log.info('[OTA Dialog] DISPOSE: instance=$hashCode');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

// [USER STORY 90944] Silent software OTA，所有 OTA 邏輯已移至 AppUpdateHelper
// 如果未來需要顯示 OTA UI，可以在這裡添加相關方法
}
