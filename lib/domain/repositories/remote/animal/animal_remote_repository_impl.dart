import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/repositories/remote/animal/animal_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AnimalRemoteRepositoryImpl implements AnimalRemoteRepository {
  final HttpService httpService;

  AnimalRemoteRepositoryImpl({required this.httpService});

  @override
  Future<Either<AgroNexusException, AnimalEntity>> create(
      {required AnimalEntity entity}) async {
    try {
      await httpService.post(
        path: API.animais,
        data: entity.toJsonSend(),
        isAuth: true,
      );
      return Right(entity);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, Map<String, dynamic>>> delete(
      {required String id}) async {
    try {
      await httpService.delete(
        path: API.animalById(id),
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
  Future<Either<AgroNexusException, ListBaseEntity<AnimalEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};
      queryParameters['limit'] = limit;
      queryParameters['offset'] = offset;
      if (search != null) {
        queryParameters['search'] = search;
      }
      Response response = await httpService.get(
        path: API.animais,
        queryParameters: queryParameters,
      );
      return Right(
        ListBaseEntity.fromJson(
          json: response.data,
          fromJson: AnimalEntity.fromJson,
        ),
      );
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, AnimalEntity>> getById(
      {required String id}) async {
    try {
      Response response = await httpService.get(
        path: API.animalById(id),
      );
      return Right(AnimalEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, AnimalEntity>> update(
      {required AnimalEntity entity}) async {
    try {
      await httpService.put(
        path: API.animalById(entity.id!),
        data: entity.toJsonSend(),
      );
      return Right(entity);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }
}
