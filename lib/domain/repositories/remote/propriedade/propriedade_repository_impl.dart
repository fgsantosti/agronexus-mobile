import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/domain/repositories/remote/propriedade/propriedade_remote_repository.dart';
import 'package:dio/dio.dart';

class PropriedadeRepositoryImpl implements PropriedadeRemoteRepository {
  final HttpService httpService;

  PropriedadeRepositoryImpl({required this.httpService});

  @override
  Future<List<PropriedadeEntity>> getPropriedades({
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

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) {
        // Converter Map<String?, dynamic> para Map<String, dynamic>
        Map<String, dynamic> convertedJson = {};
        json.forEach((key, value) {
          if (key != null) {
            convertedJson[key] = value;
          }
        });
        return PropriedadeEntity.fromJson(convertedJson);
      }).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<PropriedadeEntity> getPropriedade(String id) async {
    try {
      Response response = await httpService.get(
        path: API.propriedadeById(id),
        isAuth: true,
      );
      return PropriedadeEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<PropriedadeEntity> createPropriedade(PropriedadeEntity propriedade) async {
    try {
      Response response = await httpService.post(
        path: API.propriedades,
        data: propriedade.toJson(),
        isAuth: true,
      );
      return PropriedadeEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<PropriedadeEntity> updatePropriedade(String id, PropriedadeEntity propriedade) async {
    try {
      Response response = await httpService.put(
        path: API.propriedadeById(id),
        data: propriedade.toJson(),
        isAuth: true,
      );
      return PropriedadeEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deletePropriedade(String id) async {
    try {
      await httpService.delete(
        path: API.propriedadeById(id),
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
