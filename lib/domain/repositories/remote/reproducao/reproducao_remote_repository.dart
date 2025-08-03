import 'package:agronexus/domain/models/reproducao_entity.dart';

abstract class ReproducaoRepository {
  // Inseminações
  Future<List<InseminacaoEntity>> getInseminacoes({
    String? animalId,
    String? estacaoMontaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<InseminacaoEntity> getInseminacao(String id);
  Future<InseminacaoEntity> createInseminacao(InseminacaoEntity inseminacao);
  Future<InseminacaoEntity> updateInseminacao(String id, InseminacaoEntity inseminacao);
  Future<void> deleteInseminacao(String id);
  Future<OpcoesCadastroInseminacao> getOpcoesCadastroInseminacao();

  // Diagnósticos de Gestação
  Future<List<DiagnosticoGestacaoEntity>> getDiagnosticosGestacao({
    String? animalId,
    String? inseminacaoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<DiagnosticoGestacaoEntity> getDiagnosticoGestacao(String id);
  Future<DiagnosticoGestacaoEntity> createDiagnosticoGestacao(DiagnosticoGestacaoEntity diagnostico);
  Future<DiagnosticoGestacaoEntity> updateDiagnosticoGestacao(String id, DiagnosticoGestacaoEntity diagnostico);
  Future<void> deleteDiagnosticoGestacao(String id);

  // Partos
  Future<List<PartoEntity>> getPartos({
    String? animalId,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<PartoEntity> getParto(String id);
  Future<PartoEntity> createParto(PartoEntity parto);
  Future<PartoEntity> updateParto(String id, PartoEntity parto);
  Future<void> deleteParto(String id);

  // Estações de Monta
  Future<List<EstacaoMontaEntity>> getEstacoesMonta({bool? ativa});
  Future<EstacaoMontaEntity> getEstacaoMonta(String id);
  Future<EstacaoMontaEntity> createEstacaoMonta(EstacaoMontaEntity estacao);
  Future<EstacaoMontaEntity> updateEstacaoMonta(String id, EstacaoMontaEntity estacao);
  Future<void> deleteEstacaoMonta(String id);

  // Protocolos IATF
  Future<List<ProtocoloIATFEntity>> getProtocolosIATF({bool? ativo});
  Future<ProtocoloIATFEntity> getProtocoloIATF(String id);
  Future<ProtocoloIATFEntity> createProtocoloIATF(ProtocoloIATFEntity protocolo);
  Future<ProtocoloIATFEntity> updateProtocoloIATF(String id, ProtocoloIATFEntity protocolo);
  Future<void> deleteProtocoloIATF(String id);

  // Relatórios e Estatísticas
  Future<Map<String, dynamic>> getRelatorioPrenhez({
    String? estacaoMontaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<Map<String, dynamic>> getEstatisticasReproducao({
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<Map<String, dynamic>> getResumoReproducao();
}
