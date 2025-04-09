import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/message_dialog_provider.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3MessageDialog extends ConsumerWidget {
  const V3MessageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogState = ref.watch(dialogProvider);

    if (!dialogState.isVisible) {
      return const SizedBox.shrink();
    }
    return FocusScope(
      autofocus: true,
      node: FocusScopeNode(),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        color: context.tokens.color.vsdslColorOpacityNeutralXs,
        child: Container(
          width: dialogState.width ?? 400,
          // 設置固定寬度
          height: dialogState.height ?? 265,
          // 設置固定高度
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.tokens.color.vsdslColorSurface100,
            borderRadius: BorderRadius.circular(
                context.tokens.radii.vsdslRadiusXl.topLeft.x),
            border: Border.all(
                color: context.tokens.color.vsdslColorSurface100, width: 1.0),
            boxShadow: context.tokens.shadow.vsdslShadowNeutralXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (dialogState.showIcon ?? false) ...[
                SvgPicture.asset(
                  'assets/images/ic_logo_airsync_icon.svg',
                  excludeFromSemantics: true,
                  width: 66,
                  height: 66,
                ),
                const SizedBox(height: 12),
              ],
              if (dialogState.title != null)
                Text(
                  dialogState.title!,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorNeutral,
                    fontSize: 16,
                  ),
                ),
              if (dialogState.title != null && dialogState.content != null)
                const SizedBox(height: 12),
              if (dialogState.content != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      dialogState.content!,
                      style: dialogState.contentStyle ??
                          TextStyle(
                            color: context.tokens.color.vsdslColorNeutral,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (dialogState.cancelText != null)
                    V3Focus(
                      label: S.of(context).v3_lbl_message_dialog_cancel,
                      identifier: 'v3_qa_message_dialog_cancel',
                      child: ElevatedButton(
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              return context.tokens.color
                                  .vsdslColorPrimaryVariant; // 默认前景颜色
                            },
                          ),
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return context.tokens.color
                                    .vsdslColorSurface200; // 按下状态的背景颜色
                              }
                              return context.tokens.color
                                  .vsdslColorOnSurfaceInverse; // 默认背景颜色
                            },
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                              side: BorderSide(
                                  color: context
                                      .tokens.color.vsdslColorPrimaryVariant,
                                  width: 1.0),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(4.0),
                        ),
                        onPressed: () {
                          ref.read(dialogProvider.notifier).hideDialog();
                          dialogState.onCancel?.call();
                        },
                        child: Text(dialogState.cancelText!),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (dialogState.confirmText != null)
                    V3Focus(
                      label: S.of(context).v3_lbl_message_dialog_confirm,
                      identifier: 'v3_qa_message_dialog_confirm',
                      child: ElevatedButton(
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return context
                                    .tokens.color.vsdslColorSurface300;
                              }
                              return context
                                  .tokens.color.vsdslColorOnSurfaceInverse;
                            },
                          ),
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return context
                                    .tokens.color.vsdslColorPrimaryVariant;
                              }
                              return context.tokens.color.vsdslColorPrimary;
                            },
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(4.0),
                        ),
                        onPressed: () {
                          ref.read(dialogProvider.notifier).hideDialog();
                          dialogState.onConfirm?.call();
                        },
                        child: Text(dialogState.confirmText!),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
