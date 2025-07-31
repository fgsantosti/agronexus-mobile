part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class PerformLoginEvent extends LoginEvent {
  final String email;
  final String password;

  const PerformLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AutoLoginEvent extends LoginEvent {
  const AutoLoginEvent();

  @override
  List<Object?> get props => [];
}

class LogoutLoginEvent extends LoginEvent {
  const LogoutLoginEvent();

  @override
  List<Object?> get props => [];
}

class GetUserLoginEvent extends LoginEvent {
  const GetUserLoginEvent();

  @override
  List<Object?> get props => [];
}
