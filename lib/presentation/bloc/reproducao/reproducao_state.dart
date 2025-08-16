import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';

// States
abstract class ReproducaoState extends Equatable {
  const ReproducaoState();

  @override
  List<Object?> get props => [];
}

class ReproducaoInitial extends ReproducaoState {}

class ReproducaoLoading extends ReproducaoState {}

class ReproducaoError extends ReproducaoState {
  final String message;

  const ReproducaoError(this.message);

  @override
  List<Object> get props => [message];
}

// Loading states específicos para evitar conflitos
class InseminacoesLoading extends ReproducaoState {}

class DiagnosticosGestacaoLoading extends ReproducaoState {}

class PartosLoading extends ReproducaoState {}

class EstacoesMotaLoading extends ReproducaoState {}

class ProtocolosIATFLoading extends ReproducaoState {}

class ResumoReproducaoLoading extends ReproducaoState {}

// Inseminação States
class InseminacoesLoaded extends ReproducaoState {
  final List<InseminacaoEntity> inseminacoes;

  const InseminacoesLoaded(this.inseminacoes);

  @override
  List<Object> get props => [inseminacoes];
}

class InseminacaoCreated extends ReproducaoState {
  final InseminacaoEntity inseminacao;

  const InseminacaoCreated(this.inseminacao);

  @override
  List<Object> get props => [inseminacao];
}

class InseminacaoUpdated extends ReproducaoState {
  final InseminacaoEntity inseminacao;

  const InseminacaoUpdated(this.inseminacao);

  @override
  List<Object> get props => [inseminacao];
}

class InseminacaoDeleted extends ReproducaoState {
  final String id;

  const InseminacaoDeleted(this.id);

  @override
  List<Object> get props => [id];
}

// Diagnóstico States
class DiagnosticosGestacaoLoaded extends ReproducaoState {
  final List<DiagnosticoGestacaoEntity> diagnosticos;

  const DiagnosticosGestacaoLoaded(this.diagnosticos);

  @override
  List<Object> get props => [diagnosticos];
}

class DiagnosticoGestacaoCreated extends ReproducaoState {
  final DiagnosticoGestacaoEntity diagnostico;

  const DiagnosticoGestacaoCreated(this.diagnostico);

  @override
  List<Object> get props => [diagnostico];
}

class DiagnosticoGestacaoUpdated extends ReproducaoState {
  final DiagnosticoGestacaoEntity diagnostico;

  const DiagnosticoGestacaoUpdated(this.diagnostico);

  @override
  List<Object> get props => [diagnostico];
}

class DiagnosticoGestacaoDeleted extends ReproducaoState {
  final String id;

  const DiagnosticoGestacaoDeleted(this.id);

  @override
  List<Object> get props => [id];
}

// Parto States
class PartosLoaded extends ReproducaoState {
  final List<PartoEntity> partos;

  const PartosLoaded(this.partos);

  @override
  List<Object> get props => [partos];
}

class PartoCreated extends ReproducaoState {
  final PartoEntity parto;

  const PartoCreated(this.parto);

  @override
  List<Object> get props => [parto];
}

class PartoUpdated extends ReproducaoState {
  final PartoEntity parto;

  const PartoUpdated(this.parto);

  @override
  List<Object> get props => [parto];
}

class PartoDeleted extends ReproducaoState {
  final String id;

  const PartoDeleted(this.id);

  @override
  List<Object> get props => [id];
}

// Estação de Monta States
class EstacoesMotaLoaded extends ReproducaoState {
  final List<EstacaoMontaEntity> estacoes;

  const EstacoesMotaLoaded(this.estacoes);

  @override
  List<Object> get props => [estacoes];
}

class EstacaoMontaCreated extends ReproducaoState {
  final EstacaoMontaEntity estacao;

  const EstacaoMontaCreated(this.estacao);

  @override
  List<Object> get props => [estacao];
}

class EstacaoMontaUpdated extends ReproducaoState {
  final EstacaoMontaEntity estacao;

  const EstacaoMontaUpdated(this.estacao);

  @override
  List<Object> get props => [estacao];
}

class EstacaoMontaDeleted extends ReproducaoState {
  final String id;

  const EstacaoMontaDeleted(this.id);

  @override
  List<Object> get props => [id];
}

// Protocolo IATF States
class ProtocolosIATFLoaded extends ReproducaoState {
  final List<ProtocoloIATFEntity> protocolos;

  const ProtocolosIATFLoaded(this.protocolos);

  @override
  List<Object> get props => [protocolos];
}

class ProtocoloIATFCreated extends ReproducaoState {
  final ProtocoloIATFEntity protocolo;

  const ProtocoloIATFCreated(this.protocolo);

  @override
  List<Object> get props => [protocolo];
}

class ProtocoloIATFUpdated extends ReproducaoState {
  final ProtocoloIATFEntity protocolo;

  const ProtocoloIATFUpdated(this.protocolo);

  @override
  List<Object> get props => [protocolo];
}

class ProtocoloIATFDeleted extends ReproducaoState {
  final String id;

  const ProtocoloIATFDeleted(this.id);

  @override
  List<Object> get props => [id];
}

// Relatórios States
class RelatorioPrenhezLoaded extends ReproducaoState {
  final Map<String, dynamic> relatorio;

  const RelatorioPrenhezLoaded(this.relatorio);

  @override
  List<Object> get props => [relatorio];
}

class EstatisticasReproducaoLoaded extends ReproducaoState {
  final Map<String, dynamic> estatisticas;

  const EstatisticasReproducaoLoaded(this.estatisticas);

  @override
  List<Object> get props => [estatisticas];
}

class ResumoReproducaoLoaded extends ReproducaoState {
  final Map<String, dynamic> resumo;

  const ResumoReproducaoLoaded(this.resumo);

  @override
  List<Object> get props => [resumo];
}

class InseminacoesPendenteDiagnosticoLoaded extends ReproducaoState {
  final List<InseminacaoEntity> inseminacoes;

  const InseminacoesPendenteDiagnosticoLoaded(this.inseminacoes);

  @override
  List<Object> get props => [inseminacoes];
}

class GestacoesPendentePartoLoaded extends ReproducaoState {
  final List<DiagnosticoGestacaoEntity> gestacoes;

  const GestacoesPendentePartoLoaded(this.gestacoes);

  @override
  List<Object> get props => [gestacoes];
}

class OpcoesCadastroInseminacaoLoading extends ReproducaoState {}

class OpcoesCadastroInseminacaoLoaded extends ReproducaoState {
  final OpcoesCadastroInseminacao opcoes;

  const OpcoesCadastroInseminacaoLoaded(this.opcoes);

  @override
  List<Object> get props => [opcoes];
}

// Novos states para estação de monta avançada
class EstacaoMontaDetalheLoading extends ReproducaoState {}

class EstacaoMontaDetalheLoaded extends ReproducaoState {
  final EstacaoMontaEntity estacao;
  final List<dynamic> lotes; // Lista de lotes associados

  const EstacaoMontaDetalheLoaded(this.estacao, this.lotes);

  @override
  List<Object> get props => [estacao, lotes];
}

class LotesDisponivelLoading extends ReproducaoState {}

class LotesDisponivelLoaded extends ReproducaoState {
  final List<dynamic> lotes; // Lista de lotes disponíveis para associar

  const LotesDisponivelLoaded(this.lotes);

  @override
  List<Object> get props => [lotes];
}

class LotesAssociados extends ReproducaoState {
  final String message;

  const LotesAssociados(this.message);

  @override
  List<Object> get props => [message];
}

class DashboardEstacaoLoading extends ReproducaoState {}

class DashboardEstacaoLoaded extends ReproducaoState {
  final Map<String, dynamic> dashboard;

  const DashboardEstacaoLoaded(this.dashboard);

  @override
  List<Object> get props => [dashboard];
}
