import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

/// Use this provider to show a dialog.
/// ref.read(dialogProvider.notifier).showDialog(
///   title: 'Title',
///   content: 'Description？',
///   confirmText: 'Confirm',
///   cancelText: 'Cancel',
///   onConfirm: () {
///     print('onConfirm');
///   },
///   onCancel: () {
///     print('onCancel');
///   },
/// );

class DialogState {
  final String? title;
  final TextStyle? titleStyle;
  final String? content;
  final TextStyle? contentStyle;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final double? width;
  final double? height;
  final bool? showIcon;

  DialogState({
    this.title,
    this.titleStyle,
    this.content,
    this.contentStyle,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.width,
    this.height,
    this.showIcon,
  });

  bool get isVisible => title != null || content != null;
}

class MessageDialogProvider extends StateNotifier<DialogState> {
  MessageDialogProvider() : super(DialogState());

  void showDialog({
    String? title,
    TextStyle? titleStyle,
    String? content,
    TextStyle? contentStyle,
    String? confirmText,
    String? cancelText,
    double? width,
    double? height,
    bool? showIcon,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    if (navService.canPop()) {
      navService.goBack();
    }
    state = DialogState(
      title: title,
      titleStyle: titleStyle,
      content: content,
      contentStyle: contentStyle,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      width: width,
      height: height,
      showIcon: showIcon,
    );
  }

  void hideDialog() {
    state = DialogState();
  }
}

final dialogProvider =
    StateNotifierProvider<MessageDialogProvider, DialogState>((ref) {
  return MessageDialogProvider();
});
