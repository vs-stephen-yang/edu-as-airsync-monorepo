import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/widgets/custom_text_form_field.dart';
import 'package:display_flutter/widgets/focus_elevated_button.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class InstanceNameEditorDialog extends StatefulWidget {
  const InstanceNameEditorDialog({super.key});

  @override
  State<StatefulWidget> createState() => _InstanceNameEditorDialogState();
}

class _InstanceNameEditorDialogState extends State<InstanceNameEditorDialog> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _saveBtnEnable = false;

  Future<void> _clickSaveName(String newInstanceName) async {
    AppPreferences().set(instanceName: newInstanceName);

    InstanceInfoProvider instanceInfoProvider =
        Provider.of<InstanceInfoProvider>(context, listen: false);

    instanceInfoProvider.instanceName = newInstanceName;

    navService.goBack();
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = AppPreferences().instanceName;
    if (_nameController.text.isNotEmpty) {
      _saveBtnEnable = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: AppColors.primaryDialog,
      alignment: MediaQuery.of(context).orientation == Orientation.portrait
          ? const Alignment(-1.0, 0.5)
          : Alignment.centerLeft,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 0.40
                : 0.25),
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              V3AutoHyphenatingText(
                S.of(context).main_settings_device_name_title,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                labelText: S.of(context).main_settings_device_name_hint,
                labelBackgroundColor: Colors.transparent,
                labelTextColor: Colors.white,
                inputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    _saveBtnEnable = true;
                  } else {
                    _saveBtnEnable = false;
                  }
                  if (!mounted) return;
                  setState(() {});
                },
                onFieldSubmitted: (String value) async {
                  if (_saveBtnEnable) {
                    await _clickSaveName(value);
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FocusElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                    ),
                    hasFocusWidth: 120,
                    notFocusWidth: 110,
                    hasFocusHeight: 30,
                    notFocusHeight: 25,
                    onClick: () {
                      navService.goBack();
                    },
                    child: AutoSizeText(
                      S.of(context).main_settings_device_name_cancel,
                      style: const TextStyle(color: AppColors.primaryGrey),
                    ),
                  ),
                  FocusElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    hasFocusWidth: 120,
                    notFocusWidth: 110,
                    hasFocusHeight: 30,
                    notFocusHeight: 25,
                    onClick: _saveBtnEnable
                        ? () {
                            _clickSaveName(_nameController.text);
                          }
                        : null,
                    child: AutoSizeText(
                      S.of(context).main_settings_device_name_save,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
