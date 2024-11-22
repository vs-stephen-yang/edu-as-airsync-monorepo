import 'dart:developer';

import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_settings_radio_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3SettingsConnectivity extends StatelessWidget {
  const V3SettingsConnectivity({super.key});

  @override
  Widget build(BuildContext context) {
    List<V3SettingsRadioGroupItem> radioItems = [
      V3SettingsRadioGroupItem(
        value: ConnectivityType.both.name,
        title: S.of(context).v3_settings_connectivity_both,
        divider: true,
      ),
      V3SettingsRadioGroupItem(
        value: ConnectivityType.local.name,
        title: S.of(context).v3_settings_connectivity_local,
        subtitle: S.of(context).v3_settings_connectivity_local_desc,
        subtitleIcon: SvgPicture.asset(
          'assets/images/ic_settings_local_connection.svg',
          width: 22,
          height: 22,
        ),
        divider: true,
      ),
      V3SettingsRadioGroupItem(
        value: ConnectivityType.internet.name,
        title: S.of(context).v3_settings_connectivity_internet,
        subtitle: S.of(context).v3_settings_connectivity_internet_desc,
        divider: false,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 57, left: 13, right: 13),
      child: V3SettingsRadioGroup(
        initSelectedValue: AppPreferences().connectivityType,
        radioList: radioItems,
        onChanged: (value) {
          int index = radioItems.indexWhere((item) => item.value == value);
          if (index != -1) {
            ConnectivityType type = ConnectivityType.values[index];
            trackEvent(
              'click_connectivity',
              EventCategory.setting,
              target: type.name,
            );

            AppPreferences().setSelectedConnectivityType(type);
            Provider.of<ChannelProvider>(context, listen: false)
                .launchChannelServer();
          } else {
            log('ConnectivityType not found');
          }
        },
      ),
    );
  }
}
