import 'dart:async';

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

enum DialogCountdownAction { confirm, cancel }

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
  final int? countdownSeconds;
  final int? countdownRemaining;
  final DialogCountdownAction? countdownAction;
  final bool dismissOnConfirm;
  final bool isProgressDialog;
  final bool blockInteraction;

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
    this.countdownSeconds,
    this.countdownRemaining,
    this.countdownAction,
    this.dismissOnConfirm = true,
    this.isProgressDialog = false,
    this.blockInteraction = false,
  });

  bool get isVisible => isProgressDialog || title != null || content != null;

  bool get hasCountdown =>
      countdownRemaining != null && countdownAction != null;

  DialogState copyWith({
    int? countdownRemaining,
    DialogCountdownAction? countdownAction,
    bool clearCountdown = false,
  }) {
    final shouldClearCountdown = clearCountdown;
    return DialogState(
      title: title,
      titleStyle: titleStyle,
      content: content,
      contentStyle: contentStyle,
      confirmText: shouldClearCountdown ? null : confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      width: width,
      height: height,
      showIcon: showIcon,
      countdownSeconds: shouldClearCountdown ? null : countdownSeconds,
      countdownRemaining: shouldClearCountdown
          ? null
          : (countdownRemaining ?? this.countdownRemaining),
      countdownAction: shouldClearCountdown
          ? null
          : (countdownAction ?? this.countdownAction),
      dismissOnConfirm: dismissOnConfirm,
      isProgressDialog: isProgressDialog,
      blockInteraction: blockInteraction,
    );
  }
}

class MessageDialogProvider extends StateNotifier<DialogState> {
  MessageDialogProvider() : super(DialogState());

  Timer? _countdownTimer;

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
    int? countdownSeconds,
    DialogCountdownAction? countdownAction,
    bool dismissOnConfirm = true,
    bool isProgressDialog = false,
    bool blockInteraction = false,
  }) {
    _stopCountdown();
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
      countdownSeconds: countdownSeconds,
      countdownRemaining: countdownSeconds,
      countdownAction: countdownAction,
      dismissOnConfirm: dismissOnConfirm,
      isProgressDialog: isProgressDialog,
      blockInteraction: blockInteraction,
    );
    _startCountdownIfNeeded();
  }

  void showProgress({
    String? title,
    TextStyle? titleStyle,
    String? content,
    TextStyle? contentStyle,
    double? width,
    double? height,
    String? cancelText,
    VoidCallback? onCancel,
  }) {
    showDialog(
      title: title,
      titleStyle: titleStyle,
      content: content,
      contentStyle: contentStyle,
      width: width,
      height: height,
      isProgressDialog: true,
      blockInteraction: true,
      confirmText: null,
      cancelText: cancelText,
      countdownSeconds: null,
      countdownAction: null,
      onCancel: onCancel,
    );
  }

  void hideDialog() {
    _stopCountdown();
    state = DialogState();
  }

  void stopCountdownOnly() {
    if (!state.hasCountdown) {
      return;
    }
    _stopCountdown();
    state = state.copyWith(clearCountdown: true);
  }

  void _startCountdownIfNeeded() {
    if (state.countdownSeconds == null || state.countdownAction == null) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.hasCountdown) return;
      final remaining = state.countdownRemaining ?? 0;
      if (remaining <= 1) {
        _triggerCountdownAction();
        return;
      }
      state = state.copyWith(countdownRemaining: remaining - 1);
    });
  }

  void _triggerCountdownAction() {
    final action = state.countdownAction;
    final onConfirm = state.onConfirm;
    final onCancel = state.onCancel;
    hideDialog();
    if (action == DialogCountdownAction.confirm) {
      onConfirm?.call();
    } else if (action == DialogCountdownAction.cancel) {
      onCancel?.call();
    }
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }
}

final dialogProvider =
    StateNotifierProvider<MessageDialogProvider, DialogState>((ref) {
  return MessageDialogProvider();
});
