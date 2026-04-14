import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/message_dialog_provider.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3MessageDialog extends ConsumerWidget {
  const V3MessageDialog({super.key});

  String _withCountdown(
    DialogState dialogState,
    DialogCountdownAction action,
    String text,
  ) {
    if (dialogState.countdownAction != action) return text;
    final remaining = dialogState.countdownRemaining;
    if (remaining == null) return text;
    return '$text (${remaining}s)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogState = ref.watch(dialogProvider);
    final isProgressDialog = dialogState.isProgressDialog;
    final blockInteraction = dialogState.blockInteraction;
    final scrollController = ScrollController();
    if (!dialogState.isVisible) {
      return const SizedBox.shrink();
    }
    return WillPopScope(
      onWillPop: () async => !blockInteraction,
      child: FocusScope(
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
            height: (dialogState.height ?? 265) * AppPreferences().textScale,
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
                if (!isProgressDialog && dialogState.title != null)
                  V3AutoHyphenatingText(
                    dialogState.title!,
                    style: dialogState.titleStyle ??
                        TextStyle(
                          color: context.tokens.color.vsdslColorNeutral,
                          fontSize: 16,
                        ),
                  ),
                if (!isProgressDialog &&
                    dialogState.title != null &&
                    dialogState.content != null)
                  const SizedBox(height: 12),
                if (isProgressDialog)
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                          if (dialogState.title != null) ...[
                            const SizedBox(height: 16),
                            V3AutoHyphenatingText(
                              dialogState.title!,
                              textAlign: TextAlign.center,
                              style: dialogState.titleStyle ??
                                  TextStyle(
                                    color:
                                        context.tokens.color.vsdslColorNeutral,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                          if (dialogState.content != null) ...[
                            const SizedBox(height: 8),
                            V3AutoHyphenatingText(
                              dialogState.content!,
                              textAlign: TextAlign.center,
                              style: dialogState.contentStyle ??
                                  TextStyle(
                                    color:
                                        context.tokens.color.vsdslColorNeutral,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else if (dialogState.content != null)
                  Expanded(
                    child: V3Scrollbar(
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: V3AutoHyphenatingText(
                          dialogState.content!,
                          style: dialogState.contentStyle ??
                              TextStyle(
                                color: context.tokens.color.vsdslColorNeutral,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                  ),
                if (!isProgressDialog &&
                    (dialogState.cancelText != null ||
                        dialogState.confirmText != null)) ...[
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
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                  side: BorderSide(
                                      color: context.tokens.color
                                          .vsdslColorPrimaryVariant,
                                      width: 1.0),
                                ),
                              ),
                              elevation: WidgetStateProperty.all(4.0),
                            ),
                            onPressed: () {
                              ref.read(dialogProvider.notifier).hideDialog();
                              dialogState.onCancel?.call();
                            },
                            child: V3AutoHyphenatingText(
                              _withCountdown(
                                dialogState,
                                DialogCountdownAction.cancel,
                                dialogState.cancelText!,
                              ),
                            ),
                          ),
                        ),
                      if (dialogState.cancelText != null &&
                          dialogState.confirmText != null)
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
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              elevation: WidgetStateProperty.all(4.0),
                            ),
                            onPressed: () {
                              if (dialogState.dismissOnConfirm) {
                                ref.read(dialogProvider.notifier).hideDialog();
                              }
                              dialogState.onConfirm?.call();
                            },
                            child: V3AutoHyphenatingText(
                              _withCountdown(
                                dialogState,
                                DialogCountdownAction.confirm,
                                dialogState.confirmText!,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (isProgressDialog &&
                    (dialogState.cancelText != null ||
                        dialogState.confirmText != null)) ...[
                  const SizedBox(height: 24),
                  if (dialogState.confirmText == null &&
                      dialogState.cancelText != null)
                    SizedBox(
                      width: double.infinity,
                      child: V3Focus(
                        label: S.of(context).v3_lbl_message_dialog_cancel,
                        identifier: 'v3_qa_message_dialog_cancel',
                        child: ElevatedButton(
                          style: ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                return context
                                    .tokens.color.vsdslColorPrimaryVariant;
                              },
                            ),
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return context
                                      .tokens.color.vsdslColorSurface200;
                                }
                                return context
                                    .tokens.color.vsdslColorOnSurfaceInverse;
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
                          child: V3AutoHyphenatingText(
                            _withCountdown(
                              dialogState,
                              DialogCountdownAction.cancel,
                              dialogState.cancelText!,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
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
                                    return context
                                        .tokens.color.vsdslColorPrimaryVariant;
                                  },
                                ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return context
                                          .tokens.color.vsdslColorSurface200;
                                    }
                                    return context.tokens.color
                                        .vsdslColorOnSurfaceInverse;
                                  },
                                ),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                    side: BorderSide(
                                        color: context.tokens.color
                                            .vsdslColorPrimaryVariant,
                                        width: 1.0),
                                  ),
                                ),
                                elevation: WidgetStateProperty.all(4.0),
                              ),
                              onPressed: () {
                                ref.read(dialogProvider.notifier).hideDialog();
                                dialogState.onCancel?.call();
                              },
                              child: V3AutoHyphenatingText(
                                _withCountdown(
                                  dialogState,
                                  DialogCountdownAction.cancel,
                                  dialogState.cancelText!,
                                ),
                              ),
                            ),
                          ),
                        if (dialogState.cancelText != null &&
                            dialogState.confirmText != null)
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
                                    return context.tokens.color
                                        .vsdslColorOnSurfaceInverse;
                                  },
                                ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return context.tokens.color
                                          .vsdslColorPrimaryVariant;
                                    }
                                    return context
                                        .tokens.color.vsdslColorPrimary;
                                  },
                                ),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                elevation: WidgetStateProperty.all(4.0),
                              ),
                              onPressed: () {
                                if (dialogState.dismissOnConfirm) {
                                  ref
                                      .read(dialogProvider.notifier)
                                      .hideDialog();
                                }
                                dialogState.onConfirm?.call();
                              },
                              child: V3AutoHyphenatingText(
                                _withCountdown(
                                  dialogState,
                                  DialogCountdownAction.confirm,
                                  dialogState.confirmText!,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
