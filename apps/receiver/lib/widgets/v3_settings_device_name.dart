import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/utility/V3TextFieldShortcutsHandler.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_menu_back_icon_button.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class V3SettingsDeviceName extends StatefulWidget {
  const V3SettingsDeviceName({
    super.key,
    required this.focusNode,
    required this.openedWithLogicalKey,
  });

  final FocusNode focusNode;
  final bool openedWithLogicalKey;

  @override
  State<V3SettingsDeviceName> createState() => _V3SettingsDeviceNameState();
}

class _V3SettingsDeviceNameState extends State<V3SettingsDeviceName> {
  final TextEditingController _controller =
      TextEditingController(text: AppPreferences().instanceName);
  final FocusNode saveFocusNode = FocusNode();

  bool _isEditing = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(listenToFocusNode);
  }

  @override
  void dispose() {
    _controller.dispose();
    saveFocusNode.dispose();
    widget.focusNode.removeListener(listenToFocusNode);
    super.dispose();
  }

  String? validateDeviceName(String value) {
    if (value.isEmpty) {
      return S.of(context).v3_settings_device_name_empty_error;
    }

    return null;
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
            child: V3MenuBackIconButton(
              onPressed: () {
                settingsProvider.setPage(SettingPageState.deviceSetting);
              },
              title: S.of(context).v3_settings_device_name,
            )),
        Positioned(
            left: 13,
            top: 48,
            width: 352,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 44,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: V3AutoHyphenatingText(
                            S.of(context).v3_settings_device_name,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          V3Focus(
                            label:
                                S.of(context).v3_lbl_settings_enter_device_name,
                            identifier: "v3_qa_settings_enter_device_name",
                            child: () {
                              return V3TextFieldShortcutsHandler(
                                focusNode: widget.focusNode,
                                child: TextField(
                                  autofocus: true,
                                  textAlign: TextAlign.right,
                                  controller: _controller,
                                  focusNode: widget.focusNode,
                                  style: TextStyle(
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceInverse,
                                    fontSize: 12,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // 去掉底線
                                  ),
                                  maxLines: 2,
                                  minLines: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[a-zA-Z0-9]')),
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _errorText = validateDeviceName(value);
                                    });
                                  },
                                  onSubmitted: (_) => onSummit(),
                                ),
                              );
                            }(),
                          ),
                          if (_errorText != null)
                            Flexible(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, right: 20),
                                child: V3AutoHyphenatingText(
                                  _errorText!,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    overflow: TextOverflow.visible,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    V3Focus(
                      label: S.of(context).v3_lbl_settings_device_name_close,
                      identifier: "v3_qa_settings_device_name_close",
                      child: Visibility(
                        visible: _isEditing,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: IconButton(
                          focusNode: FocusNode()
                            // disable remote focus
                            ..canRequestFocus = false
                            // skip when using tab key to be focused
                            ..skipTraversal = true,
                          icon: SvgPicture.asset(
                            'assets/images/ic_close_white.svg',
                            fit: BoxFit.contain,
                            width: 21,
                          ),
                          padding: const EdgeInsets.only(right: 8),
                          onPressed: () {
                            _controller.text = '';
                            setState(() {
                              _errorText = validateDeviceName('');
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )),
        Positioned(
          right: 13,
          bottom: 13,
          child: _SaveButton(S.of(context).v3_settings_device_name_save,
              focusNode: saveFocusNode,
              controller: _controller,
              isValid: () => validateDeviceName(_controller.text) == null,
              onClick: () {
                // Validate before saving
                final error = validateDeviceName(_controller.text);
                if (error != null) {
                  setState(() {
                    _errorText = error;
                  });
                  return;
                }

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

  void listenToFocusNode() {
    if (mounted) {
      setState(() {
        _isEditing = widget.focusNode.hasFocus;
      });
    }
  }

  void onSummit() {
    if (widget.openedWithLogicalKey) {
      widget.focusNode.unfocus();
      saveFocusNode.requestFocus();
    }
  }
}

class _SaveButton extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final VoidCallback onClick;
  final FocusNode focusNode;
  final bool Function() isValid;

  const _SaveButton(
    this.text, {
    required this.controller,
    required this.onClick,
    required this.focusNode,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final disableOpacity =
        context.tokens.color.vsdslColorOpacityNeutralLg.opacity;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final enable = value.text.isNotEmpty && isValid();
        return V3SettingMenuSubItemFocus(
          label: S.of(context).v3_lbl_settings_device_name_save,
          identifier: "v3_qa_settings_device_name_save",
          child: InkWell(
            focusNode: focusNode,
            onTap: enable
                ? () {
                    trackEvent('edit_name', EventCategory.session);
                    onClick();
                  }
                : null,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 80,
                minHeight: 26,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.tokens.color.vsdslColorPrimary
                    .withValues(alpha: enable ? 1 : disableOpacity),
                borderRadius: BorderRadius.circular(
                    context.tokens.spacing.vsdslSpacing2xl.top),
              ),
              child: AutoSizeText(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: context.tokens.color.vsdslColorOnPrimary
                      .withValues(alpha: enable ? 1 : disableOpacity),
                ),
                textAlign: TextAlign.center,
                minFontSize: 8, // 允許字體縮小到最小 8 號
              ),
            ),
          ),
        );
      },
    );
  }
}
