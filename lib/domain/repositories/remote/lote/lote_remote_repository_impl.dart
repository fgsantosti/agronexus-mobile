import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/domain/repositories/remote/lote/lote_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class LoteRemoteRepositoryImpl implements LoteRemoteRepository {
  final HttpService httpService;

  LoteRemoteRepositoryImpl({required this.httpService});

  @override
  Future<Either<AgroNexusException, LoteEntity>> create(
      {required LoteEntity entity}) async {
    try {
      await httpService.post(
        path: API.lotes,
        data: entity.toJson(),
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
        path: API.lotesById(id),
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
  Future<Either<AgroNexusException, ListBaseEntity<LoteEntity>>> list({
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
        path: API.lotes,
        queryParameters: queryParameters,
      );
      return Right(
        ListBaseEntity.fromJson(
          json: response.data,
          fromJson: LoteEntity.fromJson,
        ),
      );
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, LoteEntity>> getById(
      {required String id}) async {
    try {
      Response response = await httpService.get(
        path: API.lotesById(id),
      );
      return Right(LoteEntity.fromJson(response.data));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, LoteEntity>> update(
      {required LoteEntity entity}) async {
    try {
      await httpService.put(
        path: API.lotesById(entity.id!),
        data: entity.toJson(),
      );
      return Right(entity);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }
}
