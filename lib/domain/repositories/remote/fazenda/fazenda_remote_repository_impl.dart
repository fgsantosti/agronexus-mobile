import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/repositories/remote/fazenda/fazenda_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class FazendaRemoteRepositoryImpl implements FazendaRemoteRepository {
  final HttpService httpService;

  FazendaRemoteRepositoryImpl({required this.httpService});

  @override
  Future<Either<AgroNexusException, FazendaEntity>> create(
      {required FazendaEntity entity}) async {
    try {
      // Fazenda endpoint não existe temporariamente
      // await httpService.post(
      //   path: API.fazendas,
      //   data: entity.toJson(),
      //   isAuth: true,
      // );
      return Right(entity);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, Map<String, dynamic>>> delete(
      {required String id}) async {
    try {
      // Fazenda endpoint não existe temporariamente
      // await httpService.delete(
      //   path: API.fazendasById(id),
      //   isAuth: true,
      // );
      return const Right({
        'message': 'Deletado com sucesso',
      });
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, ListBaseEntity<FazendaEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    try {
      // Fazenda endpoint não existe temporariamente - retornando lista vazia
      // Map<String, dynamic> queryParameters = {};
      // queryParameters['limit'] = limit;
      // queryParameters['offset'] = offset;
      // if (search != null) {
      //   queryParameters['search'] = search;
      // }
      // Response response = await httpService.get(
      //   path: API.fazendas,
      //   queryParameters: queryParameters,
      // );
      // return Right(
      //   ListBaseEntity.fromJson(
      //     json: response.data,
      //     fromJson: FazendaEntity.fromJson,
      //   ),
      // );
      return Right(ListBaseEntity<FazendaEntity>.empty());
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, FazendaEntity>> getById(
      {required String id}) async {
    try {
      // Fazenda endpoint não existe temporariamente
      // Response response = await httpService.get(
      //   path: API.fazendasById(id),
      // );
      // return Right(FazendaEntity.fromJson(response.data));
      
      // Retornando dados mock
      return Left(AgroNexusException(message: 'Fazenda não encontrada'));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }

  @override
  Future<Either<AgroNexusException, FazendaEntity>> update(
      {required FazendaEntity entity}) async {
    try {
      // Fazenda endpoint não existe temporariamente
      // await httpService.put(
      //   path: API.fazendasById(entity.id!),
      //   data: entity.toJson(),
      // );
      return Right(entity);
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }
}
