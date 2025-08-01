import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';

// Events
abstract class ReproducaoEvent extends Equatable {
  const ReproducaoEvent();

  @override
  List<Object?> get props => [];
}

// Inseminação Events
class LoadInseminacoesEvent extends ReproducaoEvent {
  final String? animalId;
  final String? estacaoMontaId;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const LoadInseminacoesEvent({
    this.animalId,
    this.estacaoMontaId,
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [animalId, estacaoMontaId, dataInicio, dataFim];
}

class CreateInseminacaoEvent extends ReproducaoEvent {
  final InseminacaoEntity inseminacao;

  const CreateInseminacaoEvent(this.inseminacao);

  @override
  List<Object> get props => [inseminacao];
}

class UpdateInseminacaoEvent extends ReproducaoEvent {
  final String id;
  final InseminacaoEntity inseminacao;

  const UpdateInseminacaoEvent(this.id, this.inseminacao);

  @override
  List<Object> get props => [id, inseminacao];
}

class DeleteInseminacaoEvent extends ReproducaoEvent {
  final String id;

  const DeleteInseminacaoEvent(this.id);

  @override
  List<Object> get props => [id];
}

// Diagnóstico Events
class LoadDiagnosticosGestacaoEvent extends ReproducaoEvent {
  final String? animalId;
  final String? inseminacaoId;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const LoadDiagnosticosGestacaoEvent({
    this.animalId,
    this.inseminacaoId,
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [animalId, inseminacaoId, dataInicio, dataFim];
}

class CreateDiagnosticoGestacaoEvent extends ReproducaoEvent {
  final DiagnosticoGestacaoEntity diagnostico;

  const CreateDiagnosticoGestacaoEvent(this.diagnostico);

  @override
  List<Object> get props => [diagnostico];
}

class UpdateDiagnosticoGestacaoEvent extends ReproducaoEvent {
  final String id;
  final DiagnosticoGestacaoEntity diagnostico;

  const UpdateDiagnosticoGestacaoEvent(this.id, this.diagnostico);

  @override
  List<Object> get props => [id, diagnostico];
}

class DeleteDiagnosticoGestacaoEvent extends ReproducaoEvent {
  final String id;

  const DeleteDiagnosticoGestacaoEvent(this.id);

  @override
  List<Object> get props => [id];
}

// Parto Events
class LoadPartosEvent extends ReproducaoEvent {
  final String? animalId;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const LoadPartosEvent({
    this.animalId,
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [animalId, dataInicio, dataFim];
}

class CreatePartoEvent extends ReproducaoEvent {
  final PartoEntity parto;

  const CreatePartoEvent(this.parto);

  @override
  List<Object> get props => [parto];
}

class UpdatePartoEvent extends ReproducaoEvent {
  final String id;
  final PartoEntity parto;

  const UpdatePartoEvent(this.id, this.parto);

  @override
  List<Object> get props => [id, parto];
}

class DeletePartoEvent extends ReproducaoEvent {
  final String id;

  const DeletePartoEvent(this.id);

  @override
  List<Object> get props => [id];
}

// Estação de Monta Events
class LoadEstacoesMotaEvent extends ReproducaoEvent {
  final bool? ativa;

  const LoadEstacoesMotaEvent({this.ativa});

  @override
  List<Object?> get props => [ativa];
}

class CreateEstacaoMontaEvent extends ReproducaoEvent {
  final EstacaoMontaEntity estacao;

  const CreateEstacaoMontaEvent(this.estacao);

  @override
  List<Object> get props => [estacao];
}

class UpdateEstacaoMontaEvent extends ReproducaoEvent {
  final String id;
  final EstacaoMontaEntity estacao;

  const UpdateEstacaoMontaEvent(this.id, this.estacao);

  @override
  List<Object> get props => [id, estacao];
}

class DeleteEstacaoMontaEvent extends ReproducaoEvent {
  final String id;

  const DeleteEstacaoMontaEvent(this.id);

  @override
  List<Object> get props => [id];
}

// Protocolo IATF Events
class LoadProtocolosIATFEvent extends ReproducaoEvent {
  final bool? ativo;

  const LoadProtocolosIATFEvent({this.ativo});

  @override
  List<Object?> get props => [ativo];
}

class CreateProtocoloIATFEvent extends ReproducaoEvent {
  final ProtocoloIATFEntity protocolo;

  const CreateProtocoloIATFEvent(this.protocolo);

  @override
  List<Object> get props => [protocolo];
}

class UpdateProtocoloIATFEvent extends ReproducaoEvent {
  final String id;
  final ProtocoloIATFEntity protocolo;

  const UpdateProtocoloIATFEvent(this.id, this.protocolo);

  @override
  List<Object> get props => [id, protocolo];
}

class DeleteProtocoloIATFEvent extends ReproducaoEvent {
  final String id;

  const DeleteProtocoloIATFEvent(this.id);

  @override
  List<Object> get props => [id];
}

// Relatórios Events
class LoadRelatorioPrenhezEvent extends ReproducaoEvent {
  final String? estacaoMontaId;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const LoadRelatorioPrenhezEvent({
    this.estacaoMontaId,
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [estacaoMontaId, dataInicio, dataFim];
}

class LoadEstatisticasReproducaoEvent extends ReproducaoEvent {
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const LoadEstatisticasReproducaoEvent({
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [dataInicio, dataFim];
}

class LoadResumoReproducaoEvent extends ReproducaoEvent {}

class LoadInseminacoesPendenteDiagnosticoEvent extends ReproducaoEvent {}

class LoadGestacoesPendentePartoEvent extends ReproducaoEvent {}
