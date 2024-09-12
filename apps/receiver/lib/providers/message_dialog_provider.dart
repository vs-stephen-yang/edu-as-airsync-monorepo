import 'dart:ui';

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

  DialogState({
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
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
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    state = DialogState(
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
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
