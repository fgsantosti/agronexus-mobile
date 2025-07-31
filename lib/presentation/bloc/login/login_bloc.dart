import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/services/auth_service.dart';
import 'package:agronexus/domain/services/user_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_events.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService authService;
  final UserService userService;

  LoginBloc({required this.authService, required this.userService})
      : super(const LoginState()) {
    on<PerformLoginEvent>(_onPerformLoginEvent);
    on<AutoLoginEvent>(_onAutoLoginEvent);
    on<LogoutLoginEvent>(_onLogoutLoginEvent);
    on<GetUserLoginEvent>(_onGetSelfUserEvent);
  }

  Future<void> _onGetSelfUserEvent(
      GetUserLoginEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: () => LoginStatus.loading));
    try {
      UserEntity user = await userService.getSelfUser();
      emit(state.copyWith(status: () => LoginStatus.initial, user: () => user));
    } catch (e) {
      emit(state.copyWith(status: () => LoginStatus.failure));
    }
  }

  Future<void> _onPerformLoginEvent(
      PerformLoginEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: () => LoginStatus.loading));
    try {
      UserEntity user = await authService.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: () => LoginStatus.success, user: () => user));
    } catch (e) {
      String errorMessage = "Falha ao realizar login";
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      print("🔴 Login error: $errorMessage");
      emit(state.copyWith(
        status: () => LoginStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }

  Future<void> _onAutoLoginEvent(
      AutoLoginEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: () => LoginStatus.loading));
    try {
      UserEntity user = await userService.getSelfLocalUser();
      if (user.password == null) {
        emit(state.copyWith(status: () => LoginStatus.initial));
        return;
      }
      add(PerformLoginEvent(email: user.email, password: user.password!));
    } catch (e) {
      emit(state.copyWith(status: () => LoginStatus.initial));
    }
  }

  Future<void> _onLogoutLoginEvent(
    LogoutLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: () => LoginStatus.loading));
    try {
      await authService.logout();
      emit(state.copyWith(
        status: () => LoginStatus.initial,
        user: () => null,  // Limpa o usuário
        errorMessage: () => null,  // Limpa qualquer mensagem de erro
      ));
    } catch (e) {
      emit(state.copyWith(status: () => LoginStatus.failure));
    }
  }
}
