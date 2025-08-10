import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/domain/repositories/remote/lote/lote_remote_repository.dart';
import 'package:dio/dio.dart';

class LoteRemoteRepositoryImpl implements LoteRemoteRepository {
  final HttpService httpService;

  LoteRemoteRepositoryImpl({required this.httpService});

  @override
  Future<List<LoteEntity>> getLotes({String? search}) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      Response response = await httpService.get(
        path: API.lotes,
        isAuth: true,
        queryParameters: queryParameters,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => LoteEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<LoteEntity> getLoteById(String id) async {
    try {
      Response response = await httpService.get(
        path: API.lotesById(id),
        isAuth: true,
      );
      return LoteEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<LoteEntity> createLote(LoteEntity lote) async {
    try {
      Response response = await httpService.post(
        path: API.lotes,
        data: lote.toJson(),
        isAuth: true,
      );
      return LoteEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<LoteEntity> updateLote(String id, LoteEntity lote) async {
    try {
      Response response = await httpService.put(
        path: API.lotesById(id),
        data: lote.toJson(),
        isAuth: true,
      );
      return LoteEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteLote(String id) async {
    try {
      await httpService.delete(
        path: API.lotesById(id),
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
