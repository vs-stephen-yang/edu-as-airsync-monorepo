import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3OptionsMenu extends StatefulWidget {
  const V3OptionsMenu({super.key});

  @override
  State<StatefulWidget> createState() => _V3OptionsMenuState();
}

class _V3OptionsMenuState extends State<V3OptionsMenu> {
  final List<OptionsItems> _listOptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _addOptionsToList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.radii.vsdswRadius2xl,
      ),
      alignment: Alignment.bottomLeft,
      backgroundColor: context.tokens.color.vsdswColorSurfaceInverse,
      insetPadding: const EdgeInsets.only(left: 8, bottom: 8),
      child: SizedBox(
        width: 270,
        height: 345,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: ListView.separated(
                itemCount: _listOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              _listOptions[index].itemTitle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: context
                                    .tokens.color.vsdswColorOnSurfaceInverse,
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              height: 24,
                              child: IconButton(
                                icon: _listOptions[index].isEnabled
                                    ? SvgPicture.asset(
                                        'assets/images/v3_ic_switch_on.svg')
                                    : SvgPicture.asset(
                                        'assets/images/v3_ic_switch_off.svg'),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _listOptions[index].isEnabled =
                                      !_listOptions[index].isEnabled;
                                  _listOptions[index].callback?.call();
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: context.tokens.spacing.vsdswSpacingXs.top),
                        AutoSizeText(
                          _listOptions[index].itemSubTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                context.tokens.color.vsdswColorOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    thickness: 1,
                    height: context.tokens.spacing.vsdswSpacingSm.vertical,
                    color: context.tokens.color.vsdswColorOutlineVariant,
                  );
                },
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: CircleAvatar(
                backgroundColor: context.tokens.color.vsdswColorSurface900,
                radius: 24,
                child: IconButton(
                  icon: SvgPicture.asset('assets/images/v3_ic_menu_close.svg'),
                  color: context.tokens.color.vsdswColorNeutralInverse,
                  onPressed: () {
                    if (navService.canPop()) {
                      navService.goBack();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _addOptionsToList() {
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    bool isHQButtonEnabled = channelProvider.profileStore.selectedProfile ==
        ProfileStore.videoQualityFirstProfile;
    // bool isHEButtonEnabled = false;

    _listOptions.clear();
    _listOptions.add(
      OptionsItems(
        S.of(context).v3_present_options_menu_hq_title,
        S.of(context).v3_present_options_menu_hq_subtitle,
        isHQButtonEnabled,
        () {
          isHQButtonEnabled = !isHQButtonEnabled;

          AppAnalytics.instance.trackEvent(
            'click_HQ',
            EventCategory.session,
            target: isHQButtonEnabled ? 'on' : 'off',
          );

          channelProvider.presentChangeHighQuality(
              isHighQuality: isHQButtonEnabled);
        },
      ),
    );
    // todo: implement hardware encoding feature.
    // _listOptions.add(
    //   OptionsItems(
    //     S.of(context).v3_present_options_menu_he_title,
    //     S.of(context).v3_present_options_menu_he_subtitle,
    //     isHEButtonEnabled,
    //     () {},
    //   ),
    // );
  }
}

class OptionsItems {
  String itemTitle;
  String itemSubTitle;
  bool isEnabled;
  VoidCallback? callback;

  OptionsItems(
      this.itemTitle, this.itemSubTitle, this.isEnabled, this.callback);
}
