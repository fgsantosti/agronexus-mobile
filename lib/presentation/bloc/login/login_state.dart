part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, user, errorMessage];

  LoginState copyWith({
    AgroNexusGetter<LoginStatus>? status,
    AgroNexusGetter<UserEntity?>? user,
    AgroNexusGetter<String?>? errorMessage,
  }) {
    return LoginState(
      status: status != null ? status() : this.status,
      user: user != null ? user() : this.user,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
