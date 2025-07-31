import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/inject_dependencies.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/repositories/local/auth/auth_local_repository.dart';
import 'package:agronexus/domain/repositories/remote/auth/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRemoteRepositoryImpl implements AuthRemoteRepository {
  final HttpService httpService;

  AuthRemoteRepositoryImpl({required this.httpService});

  @override
  Future<Either<AgroNexusException, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {"username": email, "password": password};
      print("🟡 Enviando dados de login: $data");
      
      Response response = await httpService.post(
        path: API.login,
        data: data,
        isAuth: false,
      );
      
      // Debug: imprimir a resposta para análise
      print("🟢 Login response status: ${response.statusCode}");
      print("🟢 Login response data: ${response.data}");
      
      try {
        print("🟡 Tentando criar UserEntity...");
        print("🟡 Dados do user da resposta: ${response.data["user"]}");
        print("🟡 Tipo dos dados: ${response.data["user"].runtimeType}");
        
        UserEntity user = UserEntity.fromJson(response.data["user"]);
        print("🟢 User criado: ${user.firstName} - ${user.email}");
        
        user = user.copyWith(
          accessToken: () => response.data["access"],
          refreshToken: () => response.data["refresh"],
        );
        print("🟢 User com tokens: accessToken=${user.accessToken != null ? 'presente' : 'ausente'}");
        
        return Right(user);
      } catch (userError) {
        print("🔴 Erro ao criar UserEntity: $userError");
        print("🔴 Stack trace: ${StackTrace.current}");
        throw userError;
      }
    } catch (e) {
      print("🔴 Erro no login: $e");
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, Map<String, dynamic>>> refresh() async {
    try {
      // Pega o refresh token do repositório local usando o getIt
      AuthLocalRepository authLocalRepo = getIt<AuthLocalRepository>();
      String refreshToken = await authLocalRepo.getRefreshToken();
      final data = {"refresh": refreshToken};
      
      Response response = await httpService.post(
        path: API.refresh,
        data: data,
        isAuth: false,
      );
      
      return Right(response.data);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, Map<String, dynamic>>> revoke() async {
    try {
      Response response = await httpService.post(
        path: API.logout,
        data: {},
        isAuth: true,
      );
      
      return Right(response.data);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }
}
