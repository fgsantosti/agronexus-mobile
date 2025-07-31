import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/dashboard_entity.dart';
import 'package:agronexus/domain/repositories/remote/dashboard/dashboard_remote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class DashboardRemoteRepositoryImpl implements DashboardRemoteRepository {
  final HttpService httpService;

  DashboardRemoteRepositoryImpl({required this.httpService});

  @override
  Future<Either<AgroNexusException, DashboardEntity>> get() async {
    try {
      // Dashboard endpoint não existe temporariamente
      // Response response = await httpService.get(path: API.dashboard);
      // return Right(DashboardEntity.fromJson(response.data));
      
      // Retornando dados mock temporariamente
      return Right(DashboardEntity(
        totalFazendas: 0,
        totalLotes: 0,
        totalAnimais: 0,
      ));
    } catch (e) {
      return Left(await AgroNexusException.fromDioError(e));
    }
  }
}
