import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/oss_licenses.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsLegalPolicy extends StatelessWidget {
  const V3SettingsLegalPolicy({super.key});

  final List<String> _hiddenLicenses = const [
    'app_ota_flutter',
    'device_info_vs',
    'display_channel',
    'flutter_input_injection',
    'flutter_ion_sfu',
    'flutter_mirror',
  ];

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 57, right: 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 26,
            child: Row(children: [
              Text(
                S.of(context).v3_settings_privacy_policy,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Image(
                  image: Svg('assets/images/ic_arrow_right.svg'),
                  width: 21,
                  height: 21,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  settingsProvider.setPage(SettingPageState.licenses);
                },
              )
            ]),
          ),
          Container(
            height: 1,
            margin: EdgeInsets.only(
                top: context.tokens.spacing.vsdslSpacingSm.top,
                bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
            color: context.tokens.color.vsdslColorOutlineVariant,
          ),
          SizedBox(
            height: 26,
            child: Text(
              S.of(context).v3_settings_open_source_license,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dependencies
                  .where((license) => !_hiddenLicenses.contains(license.name))
                  .length,
              itemBuilder: (context, index) {
                final visibleLicenses = dependencies
                    .where((license) => !_hiddenLicenses.contains(license.name))
                    .toList();
                final license = visibleLicenses[index];
                return SizedBox(
                  height: 26,
                  child: Row(
                    children: [
                      Text(
                        license.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Image(
                          image: Svg('assets/images/ic_arrow_right.svg'),
                          width: 21,
                          height: 21,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          settingsProvider.setPage(SettingPageState.licenses,
                              license: license);
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class License {
  String? name;
  String? description;

  License(this.name, this.description);

  License.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
  }
}
