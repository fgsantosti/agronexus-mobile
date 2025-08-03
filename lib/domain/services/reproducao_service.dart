import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/repositories/remote/reproducao/reproducao_remote_repository.dart';

class ReproducaoService {
  final ReproducaoRepository _repository;

  ReproducaoService(this._repository);

  // Inseminações
  Future<List<InseminacaoEntity>> getInseminacoes({
    String? animalId,
    String? estacaoMontaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    return await _repository.getInseminacoes(
      animalId: animalId,
      estacaoMontaId: estacaoMontaId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }

  Future<InseminacaoEntity> getInseminacao(String id) async {
    return await _repository.getInseminacao(id);
  }

  Future<InseminacaoEntity> createInseminacao(InseminacaoEntity inseminacao) async {
    return await _repository.createInseminacao(inseminacao);
  }

  Future<InseminacaoEntity> updateInseminacao(String id, InseminacaoEntity inseminacao) async {
    return await _repository.updateInseminacao(id, inseminacao);
  }

  Future<void> deleteInseminacao(String id) async {
    return await _repository.deleteInseminacao(id);
  }

  Future<OpcoesCadastroInseminacao> getOpcoesCadastroInseminacao() async {
    return await _repository.getOpcoesCadastroInseminacao();
  }

  // Diagnósticos de Gestação
  Future<List<DiagnosticoGestacaoEntity>> getDiagnosticosGestacao({
    String? animalId,
    String? inseminacaoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    return await _repository.getDiagnosticosGestacao(
      animalId: animalId,
      inseminacaoId: inseminacaoId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }

  Future<DiagnosticoGestacaoEntity> getDiagnosticoGestacao(String id) async {
    return await _repository.getDiagnosticoGestacao(id);
  }

  Future<DiagnosticoGestacaoEntity> createDiagnosticoGestacao(DiagnosticoGestacaoEntity diagnostico) async {
    return await _repository.createDiagnosticoGestacao(diagnostico);
  }

  Future<DiagnosticoGestacaoEntity> updateDiagnosticoGestacao(String id, DiagnosticoGestacaoEntity diagnostico) async {
    return await _repository.updateDiagnosticoGestacao(id, diagnostico);
  }

  Future<void> deleteDiagnosticoGestacao(String id) async {
    return await _repository.deleteDiagnosticoGestacao(id);
  }

  // Partos
  Future<List<PartoEntity>> getPartos({
    String? animalId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    return await _repository.getPartos(
      animalId: animalId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }

  Future<PartoEntity> getParto(String id) async {
    return await _repository.getParto(id);
  }

  Future<PartoEntity> createParto(PartoEntity parto) async {
    return await _repository.createParto(parto);
  }

  Future<PartoEntity> updateParto(String id, PartoEntity parto) async {
    return await _repository.updateParto(id, parto);
  }

  Future<void> deleteParto(String id) async {
    return await _repository.deleteParto(id);
  }

  // Estações de Monta
  Future<List<EstacaoMontaEntity>> getEstacoesMonta({bool? ativa}) async {
    return await _repository.getEstacoesMonta(ativa: ativa);
  }

  Future<EstacaoMontaEntity> getEstacaoMonta(String id) async {
    return await _repository.getEstacaoMonta(id);
  }

  Future<EstacaoMontaEntity> createEstacaoMonta(EstacaoMontaEntity estacao) async {
    return await _repository.createEstacaoMonta(estacao);
  }

  Future<EstacaoMontaEntity> updateEstacaoMonta(String id, EstacaoMontaEntity estacao) async {
    return await _repository.updateEstacaoMonta(id, estacao);
  }

  Future<void> deleteEstacaoMonta(String id) async {
    return await _repository.deleteEstacaoMonta(id);
  }

  // Protocolos IATF
  Future<List<ProtocoloIATFEntity>> getProtocolosIATF({bool? ativo}) async {
    return await _repository.getProtocolosIATF(ativo: ativo);
  }

  Future<ProtocoloIATFEntity> getProtocoloIATF(String id) async {
    return await _repository.getProtocoloIATF(id);
  }

  Future<ProtocoloIATFEntity> createProtocoloIATF(ProtocoloIATFEntity protocolo) async {
    return await _repository.createProtocoloIATF(protocolo);
  }

  Future<ProtocoloIATFEntity> updateProtocoloIATF(String id, ProtocoloIATFEntity protocolo) async {
    return await _repository.updateProtocoloIATF(id, protocolo);
  }

  Future<void> deleteProtocoloIATF(String id) async {
    return await _repository.deleteProtocoloIATF(id);
  }

  // Relatórios e Estatísticas
  Future<Map<String, dynamic>> getRelatorioPrenhez({
    String? estacaoMontaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    return await _repository.getRelatorioPrenhez(
      estacaoMontaId: estacaoMontaId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }

  Future<Map<String, dynamic>> getEstatisticasReproducao({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    return await _repository.getEstatisticasReproducao(
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }

  // Métodos auxiliares para negócios
  Future<List<InseminacaoEntity>> getInseminacoesPendenteDiagnostico() async {
    final now = DateTime.now();
    final dataLimite = now.subtract(Duration(days: 30)); // 30 dias atrás

    final inseminacoes = await getInseminacoes(
      dataInicio: dataLimite,
      dataFim: now,
    );

    // Filtrar apenas inseminações que ainda não têm diagnóstico
    List<InseminacaoEntity> pendentes = [];
    for (var inseminacao in inseminacoes) {
      final diagnosticos = await getDiagnosticosGestacao(inseminacaoId: inseminacao.id);
      if (diagnosticos.isEmpty) {
        pendentes.add(inseminacao);
      }
    }

    return pendentes;
  }

  Future<List<DiagnosticoGestacaoEntity>> getGestacoesPendenteParto() async {
    final now = DateTime.now();
    final dataLimite = now.subtract(Duration(days: 300)); // ~10 meses atrás

    final diagnosticos = await getDiagnosticosGestacao(
      dataInicio: dataLimite,
      dataFim: now,
    );

    // Filtrar apenas gestações positivas que ainda não têm parto registrado
    return diagnosticos.where((diagnostico) {
      return diagnostico.resultado == ResultadoDiagnostico.positivo &&
          diagnostico.dataPartoPrevista != null &&
          diagnostico.dataPartoPrevista!.isBefore(now.add(Duration(days: 30))); // Próximas a parir
    }).toList();
  }

  Future<Map<String, dynamic>> getResumoReproducao() async {
    return await _repository.getResumoReproducao();
  }
}
