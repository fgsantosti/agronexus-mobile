import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/repositories/local/auth/auth_local_repository.dart';
import 'package:agronexus/domain/repositories/remote/auth/auth_repository.dart';
import 'package:agronexus/domain/services/user_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AuthService {
  final AuthLocalRepository authLocalRepository;
  final AuthRemoteRepository authRepository;
  final UserService userService;

  AuthService({
    required this.authLocalRepository,
    required this.authRepository,
    required this.userService,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final data = await authRepository.login(
        email: email,
        password: password,
      );
      await data.fold(
        (l) => throw l,
        (r) async {
          await authLocalRepository.saveToken(r.accessToken ?? "");
          await authLocalRepository.saveRefreshToken(r.refreshToken ?? "");
          await userService.setSelfUser(password: password);
        },
      );
    }
    return await userService.getSelfUser();
  }

  Future<String> get token async => await authLocalRepository.getToken();
  Future<String> get refresh async =>
      await authLocalRepository.getRefreshToken();
  Future<UserEntity> get user async => await userService.getSelfUser();
  
  Future<void> logout() async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      try {
        await authRepository.revoke();
      } catch (e) {
        // Ignora erro se não conseguir fazer logout no servidor
      }
    }
    await authLocalRepository.logout();
  }
  
  Future<void> refreshToken() async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final data = await authRepository.refresh();
      await data.fold(
        (l) => throw l,
        (r) async {
          await authLocalRepository.saveToken(r["access"] ?? "");
          // Se vier um novo refresh token, salva também
          if (r["refresh"] != null) {
            await authLocalRepository.saveRefreshToken(r["refresh"]);
          }
        },
      );
    }
  }
}
