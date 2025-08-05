import 'package:agronexus/config/api.dart';
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/opcoes_cadastro_animal.dart';
import 'package:agronexus/domain/repositories/remote/animal/animal_remote_repository.dart';
import 'package:dio/dio.dart';

class AnimalRemoteRepositoryImpl implements AnimalRemoteRepository {
  final HttpService httpService;

  AnimalRemoteRepositoryImpl({required this.httpService});

  @override
  Future<List<AnimalEntity>> getAnimais({
    int limit = 20,
    int offset = 0,
    String? search,
    String? especieId,
    String? status,
    String? propriedadeId,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (especieId != null && especieId.isNotEmpty) {
        queryParams['especie'] = especieId;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (propriedadeId != null && propriedadeId.isNotEmpty) {
        queryParams['propriedade'] = propriedadeId;
      }

      Response response = await httpService.get(
        path: API.animais,
        queryParameters: queryParams,
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;

      List<AnimalEntity> animais = [];
      for (var json in data) {
        try {
          animais.add(AnimalEntity.fromJson(json));
        } catch (e) {
          print('Erro ao fazer parse do animal: $e');
          print('JSON problemático: $json');
          // Continue para os próximos animais em caso de erro
        }
      }

      return animais;
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<AnimalEntity> getAnimal(String id) async {
    try {
      Response response = await httpService.get(
        path: API.animalById(id),
        isAuth: true,
      );
      return AnimalEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<AnimalEntity> createAnimal(AnimalEntity animal) async {
    try {
      Response response = await httpService.post(
        path: API.animais,
        data: animal.toJsonSend(),
        isAuth: true,
      );
      return AnimalEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<AnimalEntity> updateAnimal(String id, AnimalEntity animal) async {
    try {
      Response response = await httpService.put(
        path: API.animalById(id),
        data: animal.toJsonSend(),
        isAuth: true,
      );
      return AnimalEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteAnimal(String id) async {
    try {
      await httpService.delete(
        path: API.animalById(id),
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<OpcoesCadastroAnimal> getOpcoesCadastro() async {
    try {
      Response response = await httpService.get(
        path: '${API.animais}opcoes-cadastro/',
        isAuth: true,
      );
      return OpcoesCadastroAnimal.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<List<RacaAnimal>> getRacasByEspecie(String especieId) async {
    try {
      Response response = await httpService.get(
        path: '${API.animais}racas-por-especie/',
        queryParameters: {'especie': especieId},
        isAuth: true,
      );
      List<dynamic> data = response.data;
      return data.map((json) => RacaAnimal.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<List<String>> getCategoriasByEspecie(String especieId) async {
    try {
      Response response = await httpService.get(
        path: '${API.animais}categorias-por-especie/',
        queryParameters: {'especie': especieId},
        isAuth: true,
      );
      List<dynamic> data = response.data;
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
