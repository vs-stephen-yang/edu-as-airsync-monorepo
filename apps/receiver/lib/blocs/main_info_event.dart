part of 'main_info_bloc.dart';

@immutable
abstract class MainInfoEvent {}

class GetDisplayCode extends MainInfoEvent {}

class RegisterDisplayCode extends MainInfoEvent {}

class GetOneTimePassword extends MainInfoEvent {}
