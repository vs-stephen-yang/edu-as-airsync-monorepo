part of 'display_code_bloc.dart';

@immutable
abstract class DisplayCodeEvent {
  const DisplayCodeEvent();

  @override
  List<Object> get props =>[];
}

class RegisterDisplayCode extends DisplayCodeEvent {
}

class GetDisplayCode extends DisplayCodeEvent {

}

class GetOneTimePassword extends DisplayCodeEvent {

}

class StartOneTimePasswordTimer extends DisplayCodeEvent {

}