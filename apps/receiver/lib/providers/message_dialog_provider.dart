import 'dart:ui';

import 'package:display_flutter/screens/v3_home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final double? width;
  final double? height;
  final bool? showIcon;

  DialogState({
    this.title,
    this.content,
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
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    double? width,
    double? height,
    bool? showIcon,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    V3Home.isShowSettingsMenu.value = false;
    state = DialogState(
      title: title,
      content: content,
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
