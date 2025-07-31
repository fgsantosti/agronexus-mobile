import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/repositories/remote/propriedade/propriedade_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class PropriedadeRemoteRepositoryImpl implements PropriedadeRemoteRepository {
  final HttpService httpService;

  PropriedadeRemoteRepositoryImpl({required this.httpService});

  @override
  Future<Either<AgroNexusException, PropriedadeEntity>> create(
      {required PropriedadeEntity entity}) async {
    try {
      Response response = await httpService.post(
        path: API.propriedades,
        data: entity.toJson(),
        isAuth: true,
      );
      return Right(PropriedadeEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, Map<String, dynamic>>> delete(
      {required String id}) async {
    try {
      await httpService.delete(
        path: API.propriedadeById(id),
        isAuth: true,
      );
      return const Right({
        'message': 'Deletado com sucesso',
      });
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, ListBaseEntity<PropriedadeEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        'limit': limit,
        'offset': offset,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      Response response = await httpService.get(
        path: API.propriedades,
        queryParameters: queryParameters,
        isAuth: true,
      );
      return Right(
        ListBaseEntity<PropriedadeEntity>.fromJson(
          json: response.data,
          fromJson: (Map<String?, dynamic> json) {
            // Converter Map<String?, dynamic> para Map<String, dynamic>
            Map<String, dynamic> convertedJson = {};
            json.forEach((key, value) {
              if (key != null) {
                convertedJson[key] = value;
              }
            });
            return PropriedadeEntity.fromJson(convertedJson);
          },
        ),
      );
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, PropriedadeEntity>> get(
      {required String id}) async {
    try {
      Response response = await httpService.get(
        path: API.propriedadeById(id),
        isAuth: true,
      );
      return Right(PropriedadeEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, PropriedadeEntity>> update(
      {required PropriedadeEntity entity}) async {
    try {
      Response response = await httpService.put(
        path: API.propriedadeById(entity.id!),
        data: entity.toJson(),
        isAuth: true,
      );
      return Right(PropriedadeEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }
}
