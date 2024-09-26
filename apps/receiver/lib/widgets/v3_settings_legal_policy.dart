import 'dart:convert';

import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsLegalPolicy extends StatefulWidget {
  const V3SettingsLegalPolicy({super.key});

  @override
  State<V3SettingsLegalPolicy> createState() => _V3SettingsLegalPolicyState();
}

class _V3SettingsLegalPolicyState extends State<V3SettingsLegalPolicy> {
  // late List<LicenseEntry> _licenses;

  @override
  void initState() {
    super.initState();
    // _loadLicenses();
  }

  Future<List<License>> _loadLicenses() async {
    final bundle = DefaultAssetBundle.of(context);
    final licenses = await bundle.loadString('assets/3rd_licenses.json');
    return json
        .decode(licenses)
        .map<License>((licenses) => License.fromJson(licenses))
        .toList();
    // return _licenses = await LicenseRegistry.licenses.toList();
  }

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
                S.of(context).v3_settings_legal_policy,
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
                  settingsProvider.setPage(SettingPageState.legalPolicy);
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
            child: FutureBuilder<List<License>>(
              future: _loadLicenses(),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                          ? const Center(child: Text('Error loading licenses'))
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final license = snapshot.data![index];
                                return SizedBox(
                                  height: 26,
                                  child: Row(
                                    children: [
                                      Text(
                                        license.name!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Image(
                                          image: Svg(
                                              'assets/images/ic_arrow_right.svg'),
                                          width: 21,
                                          height: 21,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          settingsProvider.setPage(
                                              SettingPageState.privacyPolicy);
                                        },
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
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
