import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/domain/repositories/remote/area/area_remote_repository.dart';
import 'package:dio/dio.dart';

class AreaRemoteRepositoryImpl implements AreaRemoteRepository {
  final HttpService httpService;
  AreaRemoteRepositoryImpl({required this.httpService});

  @override
  Future<List<AreaEntity>> getAreas({String? propriedadeId}) async {
    try {
      final query = <String, dynamic>{};
      if (propriedadeId != null && propriedadeId.isNotEmpty) {
        query['propriedade'] = propriedadeId;
      }
      final Response response = await httpService.get(
        path: API.areas,
        isAuth: true,
        queryParameters: query,
      );
      final List data = response.data['results'] ?? response.data;
      return data.map((e) => AreaEntity.fromJson(e)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<AreaEntity> createArea(AreaEntity area) async {
    try {
      final payload = {
        'nome': area.nome,
        'tipo': area.tipo,
        'tamanho_ha': area.tamanhoHa,
        'status': area.status,
        'propriedade_id': area.propriedadeId,
        if (area.tipoForragem != null) 'tipo_forragem': area.tipoForragem,
        if (area.observacoes != null) 'observacoes': area.observacoes,
        if (area.coordenadasPoligono != null) 'coordenadas_poligono': area.coordenadasPoligono,
      };
      final Response response = await httpService.post(
        path: API.areas,
        isAuth: true,
        data: payload,
      );
      return AreaEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<AreaEntity> updateArea(String id, AreaEntity area) async {
    try {
      final payload = {
        'nome': area.nome,
        'tipo': area.tipo,
        'tamanho_ha': area.tamanhoHa,
        'status': area.status,
        'propriedade_id': area.propriedadeId,
        if (area.tipoForragem != null) 'tipo_forragem': area.tipoForragem,
        if (area.observacoes != null) 'observacoes': area.observacoes,
        if (area.coordenadasPoligono != null) 'coordenadas_poligono': area.coordenadasPoligono,
      };
      final Response response = await httpService.put(
        path: API.areaById(id),
        isAuth: true,
        data: payload,
      );
      return AreaEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteArea(String id) async {
    try {
      await httpService.delete(
        path: API.areaById(id),
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
