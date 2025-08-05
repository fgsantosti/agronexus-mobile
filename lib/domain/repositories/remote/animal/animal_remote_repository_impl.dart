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
      print('🔍 Iniciando carregamento de opções de cadastro...');

      // Faz chamadas separadas para cada endpoint
      final especiesResponse = await httpService.get(
        path: 'api/v1/especies/',
        isAuth: true,
      );
      print('✅ Espécies carregadas: ${especiesResponse.data is List ? especiesResponse.data.length : especiesResponse.data['results']?.length ?? 0}');

      final racasResponse = await httpService.get(
        path: 'api/v1/racas/',
        isAuth: true,
      );
      print('✅ Raças carregadas: ${racasResponse.data is List ? racasResponse.data.length : racasResponse.data['results']?.length ?? 0}');

      final propriedadesResponse = await httpService.get(
        path: 'api/v1/propriedades/',
        isAuth: true,
      );
      print('✅ Propriedades carregadas: ${propriedadesResponse.data is List ? propriedadesResponse.data.length : propriedadesResponse.data['results']?.length ?? 0}');

      final lotesResponse = await httpService.get(
        path: 'api/v1/lotes/',
        isAuth: true,
      );
      print('✅ Lotes carregados: ${lotesResponse.data is List ? lotesResponse.data.length : lotesResponse.data['results']?.length ?? 0}');

      final animaisResponse = await httpService.get(
        path: API.animais,
        isAuth: true,
      );
      print('✅ Animais carregados: ${animaisResponse.data is List ? animaisResponse.data.length : animaisResponse.data['results']?.length ?? 0}');

      // Combina os dados em uma única estrutura
      final opcoes = {
        'especies': especiesResponse.data is List ? especiesResponse.data : (especiesResponse.data['results'] ?? []),
        'racas': racasResponse.data is List ? racasResponse.data : (racasResponse.data['results'] ?? []),
        'propriedades': propriedadesResponse.data is List ? propriedadesResponse.data : (propriedadesResponse.data['results'] ?? []),
        'lotes': lotesResponse.data is List ? lotesResponse.data : (lotesResponse.data['results'] ?? []),
        'possiveis_pais': animaisResponse.data is List ? animaisResponse.data : (animaisResponse.data['results'] ?? []),
        'possiveis_maes': animaisResponse.data is List ? animaisResponse.data : (animaisResponse.data['results'] ?? []),
        'categorias': ['Bezerro', 'Bezerro desmamado', 'Garrote', 'Boi', 'Touro', 'Bezerra', 'Bezerra desmamada', 'Novilha', 'Vaca', 'Matriz'], // Categorias fixas
      };

      print('🔍 Tentando fazer parse das opções...');
      final result = OpcoesCadastroAnimal.fromJson(opcoes);
      print('✅ Parse das opções concluído com sucesso!');

      return result;
    } catch (e) {
      print('❌ Erro ao carregar opções: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<List<RacaAnimal>> getRacasByEspecie(String especieId) async {
    try {
      Response response = await httpService.get(
        path: 'api/v1/racas/',
        queryParameters: {'especie': especieId},
        isAuth: true,
      );

      List<dynamic> data = response.data is List ? response.data : (response.data['results'] ?? []);
      return data.map((json) => RacaAnimal.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<List<String>> getCategoriasByEspecie(String especieId) async {
    try {
      // Como não há endpoint específico, retorna categorias baseadas na espécie
      // Pode ser melhorado futuramente se houver categorias específicas por espécie na API
      return ['Bezerro', 'Bezerro desmamado', 'Garrote', 'Boi', 'Touro', 'Bezerra', 'Bezerra desmamada', 'Novilha', 'Vaca', 'Matriz'];
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
