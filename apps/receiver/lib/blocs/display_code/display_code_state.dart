part of 'display_code_bloc.dart';

@immutable
abstract class DisplayCodeState {}

class DisplayCodeInitial extends DisplayCodeState {}

class DisplayCodeSuccess extends DisplayCodeState {}

class DisplayCodeError extends DisplayCodeState {}

class OneTimePasswordInitial extends DisplayCodeState {}

class OneTimePasswordTimer extends DisplayCodeState {}

class OneTimePasswordError extends DisplayCodeState {}
