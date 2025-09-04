import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/repositories/remote/reproducao/reproducao_remote_repository.dart';
import 'package:dio/dio.dart';
import 'package:agronexus/config/api.dart';

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
        path: API.inseminacoes,
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
        path: API.inseminacaoById(id),
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
      print('DEBUG REPOSITORY - Enviando dados para API: ${inseminacao.toJson()}');
      Response response = await httpService.post(
        path: API.inseminacoes,
        data: inseminacao.toJson(),
        isAuth: true,
      );
      print('DEBUG REPOSITORY - Status Code: ${response.statusCode}');
      print('DEBUG REPOSITORY - Response Data Type: ${response.data.runtimeType}');
      print('DEBUG REPOSITORY - Response Data Length: ${response.data.toString().length}');
      print('DEBUG REPOSITORY - Response Data: ${response.data}');

      final inseminacaoEntity = InseminacaoEntity.fromJson(response.data);
      print('DEBUG REPOSITORY - Parsing bem-sucedido');
      return inseminacaoEntity;
    } catch (e) {
      print('DEBUG REPOSITORY - Erro capturado: $e');
      print('DEBUG REPOSITORY - Erro tipo: ${e.runtimeType}');
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<InseminacaoEntity> updateInseminacao(String id, InseminacaoEntity inseminacao) async {
    try {
      Response response = await httpService.put(
        path: API.inseminacaoById(id),
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
        path: API.inseminacaoById(id),
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<OpcoesCadastroInseminacao> getOpcoesCadastroInseminacao() async {
    try {
      Response response = await httpService.get(
        path: API.inseminacoesOpcoes,
        isAuth: true,
      );
      return OpcoesCadastroInseminacao.fromJson(response.data);
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
        path: API.diagnosticosGestacao,
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
        path: API.diagnosticoGestacaoById(id),
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
        path: API.diagnosticosGestacao,
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
        path: API.diagnosticoGestacaoById(id),
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
        path: API.diagnosticoGestacaoById(id),
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
        path: API.partos,
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
        path: API.partoById(id),
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
        path: API.partos,
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
        path: API.partoById(id),
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
        path: API.partoById(id),
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
        path: API.estacoesMonta,
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
        path: API.estacaoMontaById(id),
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
        path: API.estacoesMonta,
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
        path: API.estacaoMontaById(id),
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
        path: API.estacaoMontaById(id),
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
        path: API.protocolosIATF,
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
        path: API.protocoloIATFById(id),
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
        path: API.protocolosIATF,
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
        path: API.protocoloIATFById(id),
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
        path: API.protocoloIATFById(id),
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
        path: API.relatoriosPrenhez,
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
        path: API.relatoriosEstatisticasReproducao,
        queryParameters: queryParameters,
        isAuth: true,
      );

      return response.data;
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getResumoReproducao() async {
    try {
      Response response = await httpService.get(
        path: API.estatisticasReproducao,
        isAuth: true,
      );

      return response.data;
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  // Novos métodos para estação de monta avançada
  @override
  Future<Map<String, dynamic>> getEstacaoMontaDetalhe(String estacaoMontaId) async {
    try {
      Response response = await httpService.get(
        path: '${API.estacoesMonta}/$estacaoMontaId/detalhe/',
        isAuth: true,
      );
      return response.data;
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getLotesDisponivel({String? propriedadeId}) async {
    try {
      Map<String, dynamic> queryParameters = {};
      if (propriedadeId != null) queryParameters['propriedade_id'] = propriedadeId;

      Response response = await httpService.get(
        path: '${API.lotes}/disponivel/',
        queryParameters: queryParameters,
        isAuth: true,
      );

      // A API retorna uma lista direta, não um objeto com 'results'
      if (response.data is List) {
        return response.data;
      } else {
        return response.data['results'] ?? response.data;
      }
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<void> associarLotesEstacao(String estacaoMontaId, List<String> loteIds) async {
    try {
      await httpService.post(
        path: '${API.estacoesMonta}/$estacaoMontaId/associar_lotes/',
        data: {'lote_ids': loteIds},
        isAuth: true,
      );
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<List<DiagnosticoGestacaoEntity>> getDiagnosticosPorEstacao(String estacaoMontaId) async {
    try {
      Response response = await httpService.get(
        path: API.diagnosticosGestacao,
        queryParameters: {'estacao_monta_id': estacaoMontaId},
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => DiagnosticoGestacaoEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<List<PartoEntity>> getPartosPorEstacao(String estacaoMontaId) async {
    try {
      Response response = await httpService.get(
        path: API.partos,
        queryParameters: {'estacao_monta_id': estacaoMontaId},
        isAuth: true,
      );

      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => PartoEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardEstacao(String estacaoMontaId) async {
    try {
      Response response = await httpService.get(
        path: '${API.estacoesMonta}/$estacaoMontaId/dashboard/',
        isAuth: true,
      );
      return response.data;
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }
}
