import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/repositories/remote/user/user_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class UserRemoteRepositoryImpl implements UserRemoteRepository {
  final HttpService _httpService;

  UserRemoteRepositoryImpl({required HttpService httpService})
      : _httpService = httpService;

  @override
  Future<Either<AgroNexusException, UserEntity>> create({
    required UserEntity entity,
    required String password,
    required String password2,
  }) async {
    try {
      Map<String, dynamic> data = entity.toJsonSend();
      data["password1"] = password;
      data["password2"] = password2;
      
      // Log para debug
      print('Dados sendo enviados para API /api/auth/registro/:');
      print('Data: $data');
      
      Response response = await _httpService.post(
        path: API.registro,
        isAuth: false,
        data: data,
      );
      return Right(UserEntity.fromJson(response.data));
    } catch (e) {
      print('Erro no cadastro de usuário: $e');
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, void>> delete({required String id}) async {
    try {
      await _httpService.delete(path: API.usuarioById(id));
      return const Right(null);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, UserEntity>> getSelfUser() async {
    try {
      Response response = await _httpService.get(path: API.usuariosMe);
      return Right(UserEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, UserEntity>> getById(String id) async {
    try {
      Response response = await _httpService.get(path: API.usuarioById(id));
      return Right(UserEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, ListBaseEntity<UserEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? profile,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};
      queryParameters['limit'] = limit;
      queryParameters['offset'] = offset;
      if (profile != null) {
        queryParameters['profile'] = profile;
      }
      if (search != null) {
        queryParameters['search'] = search;
      }
      Response response = await _httpService.get(
        path: API.usuarios,
        queryParameters: queryParameters,
      );
      return Right(
        ListBaseEntity<UserEntity>.fromJson(
          json: response.data,
          fromJson: (Map<String?, dynamic> json) {
            // Converter Map<String?, dynamic> para Map<String, dynamic>
            Map<String, dynamic> convertedJson = {};
            json.forEach((key, value) {
              if (key != null) {
                convertedJson[key] = value;
              }
            });
            return UserEntity.fromJson(convertedJson);
          },
        ),
      );
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, UserEntity>> update({
    required UserEntity entity,
  }) async {
    try {
      Map<String, dynamic> data = entity.toJsonSend();
      Response response = await _httpService.patch(
        path: API.usuarioById(entity.id!),
        data: data,
      );
      return Right(UserEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, Map<String, dynamic>>> updatePassword({
    required String lastPassword,
    required String password,
    required String password2,
  }) async {
    try {
      Response response = await _httpService.put(
        path: API.usuariosPassword,
        data: {
          "last_password": lastPassword,
          "password": password,
          "password_confirmation": password2,
        },
      );
      response.data["mensagem"] =
          response.data["mensagem"] ?? "Senha alterada com sucesso!";
      return Right({"mensagem": "Senha alterada com sucesso!"});
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  // @override
  // Future<Either<CRAException, UserEntity>> forgotPassword({
  //   required String email,
  // }) async {
  //   try {
  //     Map<String, dynamic> data = {"email": email, "next_url": ""};
  //     Response response = await _httpService.post(
  //       path: API.forgotPassword,
  //       data: data,
  //     );
  //     return Right(UserDto.fromJson(response.data));
  //   } catch (e) {
  //     return Left(
  //       CRAException(
  //           message: TranslatorCodes.userForgotPasswordError.localized),
  //     );
  //   }
  // }
}
