import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/repositories/remote/reproducao/reproducao_repository.dart';
import 'package:dio/dio.dart';

class ReproducaoRepositoryImpl implements ReproducaoRepository {
  final HttpService httpService;

  ReproducaoRepositoryImpl({required this.httpService});

  // Inseminações
  @override
  Future<List<InseminacaoEntity>> getInseminacoes({
    String? animalId,
    String? estacaoMontaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (animalId != null) queryParameters['animal_id'] = animalId;
      if (estacaoMontaId != null) queryParameters['estacao_monta_id'] = estacaoMontaId;
      if (dataInicio != null) queryParameters['data_inicio'] = dataInicio.toIso8601String().split('T')[0];
      if (dataFim != null) queryParameters['data_fim'] = dataFim.toIso8601String().split('T')[0];

      Response response = await httpService.get(
        path: '/api/v1/inseminacoes/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => InseminacaoEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<InseminacaoEntity> getInseminacao(String id) async {
    try {
      Response response = await httpService.get(
        path: '/api/v1/inseminacoes/$id/',
        isAuth: true,
      );
      return InseminacaoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<InseminacaoEntity> createInseminacao(InseminacaoEntity inseminacao) async {
    try {
      Response response = await httpService.post(
        path: '/api/v1/inseminacoes/',
        data: inseminacao.toJson(),
        isAuth: true,
      );
      return InseminacaoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<InseminacaoEntity> updateInseminacao(String id, InseminacaoEntity inseminacao) async {
    try {
      Response response = await httpService.put(
        path: '/api/v1/inseminacoes/$id/',
        data: inseminacao.toJson(),
        isAuth: true,
      );
      return InseminacaoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteInseminacao(String id) async {
    try {
      await httpService.delete(
        path: '/api/v1/inseminacoes/$id/',
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  // Diagnósticos de Gestação
  @override
  Future<List<DiagnosticoGestacaoEntity>> getDiagnosticosGestacao({
    String? animalId,
    String? inseminacaoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (animalId != null) queryParameters['animal_id'] = animalId;
      if (inseminacaoId != null) queryParameters['inseminacao_id'] = inseminacaoId;
      if (dataInicio != null) queryParameters['data_inicio'] = dataInicio.toIso8601String().split('T')[0];
      if (dataFim != null) queryParameters['data_fim'] = dataFim.toIso8601String().split('T')[0];

      Response response = await httpService.get(
        path: '/api/v1/diagnosticos-gestacao/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => DiagnosticoGestacaoEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<DiagnosticoGestacaoEntity> getDiagnosticoGestacao(String id) async {
    try {
      Response response = await httpService.get(
        path: '/api/v1/diagnosticos-gestacao/$id/',
        isAuth: true,
      );
      return DiagnosticoGestacaoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<DiagnosticoGestacaoEntity> createDiagnosticoGestacao(DiagnosticoGestacaoEntity diagnostico) async {
    try {
      Response response = await httpService.post(
        path: '/api/v1/diagnosticos-gestacao/',
        data: diagnostico.toJson(),
        isAuth: true,
      );
      return DiagnosticoGestacaoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<DiagnosticoGestacaoEntity> updateDiagnosticoGestacao(String id, DiagnosticoGestacaoEntity diagnostico) async {
    try {
      Response response = await httpService.put(
        path: '/api/v1/diagnosticos-gestacao/$id/',
        data: diagnostico.toJson(),
        isAuth: true,
      );
      return DiagnosticoGestacaoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteDiagnosticoGestacao(String id) async {
    try {
      await httpService.delete(
        path: '/api/v1/diagnosticos-gestacao/$id/',
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  // Partos
  @override
  Future<List<PartoEntity>> getPartos({
    String? animalId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (animalId != null) queryParameters['animal_id'] = animalId;
      if (dataInicio != null) queryParameters['data_inicio'] = dataInicio.toIso8601String().split('T')[0];
      if (dataFim != null) queryParameters['data_fim'] = dataFim.toIso8601String().split('T')[0];

      Response response = await httpService.get(
        path: '/api/v1/partos/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => PartoEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<PartoEntity> getParto(String id) async {
    try {
      Response response = await httpService.get(
        path: '/api/v1/partos/$id/',
        isAuth: true,
      );
      return PartoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<PartoEntity> createParto(PartoEntity parto) async {
    try {
      Response response = await httpService.post(
        path: '/api/v1/partos/',
        data: parto.toJson(),
        isAuth: true,
      );
      return PartoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<PartoEntity> updateParto(String id, PartoEntity parto) async {
    try {
      Response response = await httpService.put(
        path: '/api/v1/partos/$id/',
        data: parto.toJson(),
        isAuth: true,
      );
      return PartoEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteParto(String id) async {
    try {
      await httpService.delete(
        path: '/api/v1/partos/$id/',
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  // Estações de Monta
  @override
  Future<List<EstacaoMontaEntity>> getEstacoesMonta({bool? ativa}) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (ativa != null) queryParameters['ativa'] = ativa;

      Response response = await httpService.get(
        path: '/api/v1/estacoes-monta/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => EstacaoMontaEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<EstacaoMontaEntity> getEstacaoMonta(String id) async {
    try {
      Response response = await httpService.get(
        path: '/api/v1/estacoes-monta/$id/',
        isAuth: true,
      );
      return EstacaoMontaEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<EstacaoMontaEntity> createEstacaoMonta(EstacaoMontaEntity estacao) async {
    try {
      Response response = await httpService.post(
        path: '/api/v1/estacoes-monta/',
        data: estacao.toJson(),
        isAuth: true,
      );
      return EstacaoMontaEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<EstacaoMontaEntity> updateEstacaoMonta(String id, EstacaoMontaEntity estacao) async {
    try {
      Response response = await httpService.put(
        path: '/api/v1/estacoes-monta/$id/',
        data: estacao.toJson(),
        isAuth: true,
      );
      return EstacaoMontaEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteEstacaoMonta(String id) async {
    try {
      await httpService.delete(
        path: '/api/v1/estacoes-monta/$id/',
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  // Protocolos IATF
  @override
  Future<List<ProtocoloIATFEntity>> getProtocolosIATF({bool? ativo}) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (ativo != null) queryParameters['ativo'] = ativo;

      Response response = await httpService.get(
        path: '/api/v1/protocolos-iatf/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => ProtocoloIATFEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<ProtocoloIATFEntity> getProtocoloIATF(String id) async {
    try {
      Response response = await httpService.get(
        path: '/api/v1/protocolos-iatf/$id/',
        isAuth: true,
      );
      return ProtocoloIATFEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<ProtocoloIATFEntity> createProtocoloIATF(ProtocoloIATFEntity protocolo) async {
    try {
      Response response = await httpService.post(
        path: '/api/v1/protocolos-iatf/',
        data: protocolo.toJson(),
        isAuth: true,
      );
      return ProtocoloIATFEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<ProtocoloIATFEntity> updateProtocoloIATF(String id, ProtocoloIATFEntity protocolo) async {
    try {
      Response response = await httpService.put(
        path: '/api/v1/protocolos-iatf/$id/',
        data: protocolo.toJson(),
        isAuth: true,
      );
      return ProtocoloIATFEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteProtocoloIATF(String id) async {
    try {
      await httpService.delete(
        path: '/api/v1/protocolos-iatf/$id/',
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  // Relatórios e Estatísticas
  @override
  Future<Map<String, dynamic>> getRelatorioPrenhez({
    String? estacaoMontaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (estacaoMontaId != null) queryParameters['estacao_monta_id'] = estacaoMontaId;
      if (dataInicio != null) queryParameters['data_inicio'] = dataInicio.toIso8601String().split('T')[0];
      if (dataFim != null) queryParameters['data_fim'] = dataFim.toIso8601String().split('T')[0];

      Response response = await httpService.get(
        path: '/api/v1/relatorios/prenhez/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      return response.data;
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getEstatisticasReproducao({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (dataInicio != null) queryParameters['data_inicio'] = dataInicio.toIso8601String().split('T')[0];
      if (dataFim != null) queryParameters['data_fim'] = dataFim.toIso8601String().split('T')[0];

      Response response = await httpService.get(
        path: '/api/v1/relatorios/estatisticas-reproducao/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      return response.data;
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
