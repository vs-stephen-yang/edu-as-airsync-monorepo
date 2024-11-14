import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_settings_radio_group_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsConnectivity extends StatelessWidget {
  const V3SettingsConnectivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 57, left: 13, right: 13),
      child: FocusScope(
        child: Column(
          children: [
            _buildRadioGroupItem(context,
                item: S.of(context).v3_settings_connectivity_both,
                type: ConnectivityType.both),
            _buildDivider(context),
            _buildRadioGroupItem(context,
                item: S.of(context).v3_settings_connectivity_local,
                type: ConnectivityType.local),
            _buildLocalDesc(context),
            _buildDivider(context),
            _buildRadioGroupItem(context,
                item: S.of(context).v3_settings_connectivity_internet,
                type: ConnectivityType.internet),
            _buildInternetDesc(context),
          ],
        ),
      ),
    );
  }

  Padding _buildInternetDesc(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: context.tokens.spacing.vsdslSpacingSm.top, left: 25),
      child: Row(
        children: [
          Text(
            S.of(context).v3_settings_connectivity_internet_desc,
            style: TextStyle(
              fontSize: 9,
              color: context.tokens.color.vsdslColorOnSurfaceVariant,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Padding _buildLocalDesc(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: context.tokens.spacing.vsdslSpacingSm.top,
          left: 25,
          bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
      child: Row(
        children: [
          const Image(
            width: 21,
            height: 21,
            image: Svg('assets/images/ic_settings_local_connection.svg'),
          ),
          SizedBox(width: context.tokens.spacing.vsdslSpacingXs.right),
          Expanded(
            child: Text(
              S.of(context).v3_settings_connectivity_local_desc,
              style: TextStyle(
                fontSize: 9,
                color: context.tokens.color.vsdslColorOnSurfaceVariant,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  V3SettingsRadioGroupItem _buildRadioGroupItem(BuildContext context,
      {required String item, required ConnectivityType type}) {
    return V3SettingsRadioGroupItem(
        value: item,
        defaultSelectedState:
            AppPreferences().connectivityType == type.toString(),
        onChange: (bool selected) {
          if (selected) {
            trackEvent(
              'click_connectivity',
              EventCategory.setting,
              target: type.name,
            );

            AppPreferences().setSelectedConnectivityType(type);
            Provider.of<ChannelProvider>(context, listen: false)
                .launchChannelServer();
          }
        });
  }

  Container _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(
          top: context.tokens.spacing.vsdslSpacingSm.top,
          bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
      color: context.tokens.color.vsdslColorOutlineVariant,
    );
  }
}
