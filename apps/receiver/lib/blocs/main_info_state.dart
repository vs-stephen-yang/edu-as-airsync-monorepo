part of 'main_info_bloc.dart';

enum MainInfoState {
  initialState,
  /// Due to dis-enroll entity the backend may send twice "mode-update"
  /// at same time, and Bloc did not support emit same state at same time,
  /// use this empty state to switch to another state then emit same state again.
  /// https://stackoverflow.com/a/58956232/13160681
  emptyState,
  getDisplayCodeSuccess,
  getDisplayCodeError,
  getDisplayCodeInfoSuccess,
  getDisplayCodeInfoError,
  registerDisplayCode,
  registerDisplayCodeSuccess,
  registerDisplayCodeError,
  getOneTimePassword,
  getOneTimePasswordSuccess,
  getOneTimePasswordError
}
