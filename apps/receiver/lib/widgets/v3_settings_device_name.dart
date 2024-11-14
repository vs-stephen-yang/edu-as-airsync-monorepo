import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsDeviceName extends StatefulWidget {
  const V3SettingsDeviceName({super.key, required this.focusNode});

  final FocusNode focusNode;
  @override
  State<V3SettingsDeviceName> createState() => _V3SettingsDeviceNameState();
}

class _V3SettingsDeviceNameState extends State<V3SettingsDeviceName> {
  final TextEditingController _controller =
      TextEditingController(text: AppPreferences().instanceName);
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.focusNode);
    });
    // 監聽焦點變化
    widget.focusNode.addListener(() {
      setState(() {
        _isEditing = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    return Stack(
      children: [
        Positioned(
            left: 0,
            top: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Image(
                    image: Svg('assets/images/ic_arrow_left.svg'),
                    width: 21,
                    height: 21,
                  ),
                  onPressed: () {
                    settingsProvider.setPage(SettingPageState.deviceSetting);
                  },
                ),
                Padding(
                    padding: EdgeInsets.only(
                        right: context.tokens.spacing.vsdslSpacingXs.right)),
                Text(
                  S.of(context).v3_settings_device_name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            )),
        Positioned(
            left: 13,
            top: 48,
            width: 352,
            child: Row(
              children: [
                Text(
                  S.of(context).v3_settings_device_name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  child: TextField(
                    textAlign: TextAlign.right,
                    controller: _controller,
                    focusNode: widget.focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none, // 去掉底線
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ),
                Visibility(
                  visible: _isEditing,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: IconButton(
                    icon: const Image(
                      image: Svg('assets/images/ic_close_white.svg'),
                      width: 21,
                      height: 21,
                    ),
                    padding: const EdgeInsets.only(left: 0, right: 13),
                    onPressed: () {
                      _isEditing = false;
                      widget.focusNode.unfocus();
                    },
                  ),
                )
              ],
            )),
        Positioned(
          right: 13,
          bottom: 13,
          child: _saveButton(
              context, S.of(context).v3_settings_device_name_save, onClick: () {
            AppPreferences().set(instanceName: _controller.text);
            InstanceInfoProvider instanceInfoProvider =
                Provider.of<InstanceInfoProvider>(context, listen: false);
            instanceInfoProvider.instanceName = _controller.text;
            settingsProvider.setPage(SettingPageState.deviceSetting);
          }),
        )
      ],
    );
  }

  _saveButton(BuildContext context, String text,
      {required VoidCallback onClick}) {
    return InkWell(
      onTap: () {
        trackEvent('edit_name', EventCategory.session);
        onClick();
      },
      child: Container(
        width: 80,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.tokens.color.vsdslColorPrimary,
          borderRadius:
              BorderRadius.circular(context.tokens.spacing.vsdslSpacing2xl.top),
        ),
        child: AutoSizeText(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
