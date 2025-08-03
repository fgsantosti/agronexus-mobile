import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/reproducao_service.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';

class ReproducaoBloc extends Bloc<ReproducaoEvent, ReproducaoState> {
  final ReproducaoService _service;

  ReproducaoBloc(this._service) : super(ReproducaoInitial()) {
    // Inseminação handlers
    on<LoadInseminacoesEvent>(_onLoadInseminacoes);
    on<CreateInseminacaoEvent>(_onCreateInseminacao);
    on<UpdateInseminacaoEvent>(_onUpdateInseminacao);
    on<DeleteInseminacaoEvent>(_onDeleteInseminacao);
    on<LoadOpcoesCadastroInseminacaoEvent>(_onLoadOpcoesCadastroInseminacao);

    // Diagnóstico handlers
    on<LoadDiagnosticosGestacaoEvent>(_onLoadDiagnosticosGestacao);
    on<CreateDiagnosticoGestacaoEvent>(_onCreateDiagnosticoGestacao);
    on<UpdateDiagnosticoGestacaoEvent>(_onUpdateDiagnosticoGestacao);
    on<DeleteDiagnosticoGestacaoEvent>(_onDeleteDiagnosticoGestacao);

    // Parto handlers
    on<LoadPartosEvent>(_onLoadPartos);
    on<CreatePartoEvent>(_onCreateParto);
    on<UpdatePartoEvent>(_onUpdateParto);
    on<DeletePartoEvent>(_onDeleteParto);

    // Estação de Monta handlers
    on<LoadEstacoesMotaEvent>(_onLoadEstacoesMonta);
    on<CreateEstacaoMontaEvent>(_onCreateEstacaoMonta);
    on<UpdateEstacaoMontaEvent>(_onUpdateEstacaoMonta);
    on<DeleteEstacaoMontaEvent>(_onDeleteEstacaoMonta);

    // Protocolo IATF handlers
    on<LoadProtocolosIATFEvent>(_onLoadProtocolosIATF);
    on<CreateProtocoloIATFEvent>(_onCreateProtocoloIATF);
    on<UpdateProtocoloIATFEvent>(_onUpdateProtocoloIATF);
    on<DeleteProtocoloIATFEvent>(_onDeleteProtocoloIATF);

    // Relatórios handlers
    on<LoadRelatorioPrenhezEvent>(_onLoadRelatorioPrenhez);
    on<LoadEstatisticasReproducaoEvent>(_onLoadEstatisticasReproducao);
    on<LoadResumoReproducaoEvent>(_onLoadResumoReproducao);
    on<LoadInseminacoesPendenteDiagnosticoEvent>(_onLoadInseminacoesPendenteDiagnostico);
    on<LoadGestacoesPendentePartoEvent>(_onLoadGestacoesPendenteParto);
  }

  // Inseminação handlers
  Future<void> _onLoadInseminacoes(LoadInseminacoesEvent event, Emitter<ReproducaoState> emit) async {
    emit(InseminacoesLoading());
    try {
      final inseminacoes = await _service.getInseminacoes(
        animalId: event.animalId,
        estacaoMontaId: event.estacaoMontaId,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );
      emit(InseminacoesLoaded(inseminacoes));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onCreateInseminacao(CreateInseminacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      print('DEBUG BLOC - Criando inseminação...');
      final inseminacao = await _service.createInseminacao(event.inseminacao);
      print('DEBUG BLOC - Inseminação criada com sucesso: ${inseminacao.id}');
      print('DEBUG BLOC - Emitindo estado InseminacaoCreated');
      emit(InseminacaoCreated(inseminacao));
    } catch (e) {
      print('DEBUG BLOC - Erro ao criar inseminação: $e');
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onUpdateInseminacao(UpdateInseminacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final inseminacao = await _service.updateInseminacao(event.id, event.inseminacao);
      emit(InseminacaoUpdated(inseminacao));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onDeleteInseminacao(DeleteInseminacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      await _service.deleteInseminacao(event.id);
      emit(InseminacaoDeleted(event.id));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onLoadOpcoesCadastroInseminacao(LoadOpcoesCadastroInseminacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(OpcoesCadastroInseminacaoLoading());
    try {
      final opcoes = await _service.getOpcoesCadastroInseminacao();
      emit(OpcoesCadastroInseminacaoLoaded(opcoes));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  // Diagnóstico handlers
  Future<void> _onLoadDiagnosticosGestacao(LoadDiagnosticosGestacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(DiagnosticosGestacaoLoading());
    try {
      final diagnosticos = await _service.getDiagnosticosGestacao(
        animalId: event.animalId,
        inseminacaoId: event.inseminacaoId,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );
      emit(DiagnosticosGestacaoLoaded(diagnosticos));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onCreateDiagnosticoGestacao(CreateDiagnosticoGestacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final diagnostico = await _service.createDiagnosticoGestacao(event.diagnostico);
      emit(DiagnosticoGestacaoCreated(diagnostico));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onUpdateDiagnosticoGestacao(UpdateDiagnosticoGestacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final diagnostico = await _service.updateDiagnosticoGestacao(event.id, event.diagnostico);
      emit(DiagnosticoGestacaoUpdated(diagnostico));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onDeleteDiagnosticoGestacao(DeleteDiagnosticoGestacaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      await _service.deleteDiagnosticoGestacao(event.id);
      emit(DiagnosticoGestacaoDeleted(event.id));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  // Parto handlers
  Future<void> _onLoadPartos(LoadPartosEvent event, Emitter<ReproducaoState> emit) async {
    emit(PartosLoading());
    try {
      final partos = await _service.getPartos(
        animalId: event.animalId,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );
      emit(PartosLoaded(partos));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onCreateParto(CreatePartoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final parto = await _service.createParto(event.parto);
      emit(PartoCreated(parto));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onUpdateParto(UpdatePartoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final parto = await _service.updateParto(event.id, event.parto);
      emit(PartoUpdated(parto));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onDeleteParto(DeletePartoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      await _service.deleteParto(event.id);
      emit(PartoDeleted(event.id));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  // Estação de Monta handlers
  Future<void> _onLoadEstacoesMonta(LoadEstacoesMotaEvent event, Emitter<ReproducaoState> emit) async {
    emit(EstacoesMotaLoading());
    try {
      final estacoes = await _service.getEstacoesMonta(ativa: event.ativa);
      emit(EstacoesMotaLoaded(estacoes));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onCreateEstacaoMonta(CreateEstacaoMontaEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final estacao = await _service.createEstacaoMonta(event.estacao);
      emit(EstacaoMontaCreated(estacao));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onUpdateEstacaoMonta(UpdateEstacaoMontaEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final estacao = await _service.updateEstacaoMonta(event.id, event.estacao);
      emit(EstacaoMontaUpdated(estacao));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onDeleteEstacaoMonta(DeleteEstacaoMontaEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      await _service.deleteEstacaoMonta(event.id);
      emit(EstacaoMontaDeleted(event.id));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  // Protocolo IATF handlers
  Future<void> _onLoadProtocolosIATF(LoadProtocolosIATFEvent event, Emitter<ReproducaoState> emit) async {
    emit(ProtocolosIATFLoading());
    try {
      final protocolos = await _service.getProtocolosIATF(ativo: event.ativo);
      emit(ProtocolosIATFLoaded(protocolos));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onCreateProtocoloIATF(CreateProtocoloIATFEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final protocolo = await _service.createProtocoloIATF(event.protocolo);
      emit(ProtocoloIATFCreated(protocolo));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onUpdateProtocoloIATF(UpdateProtocoloIATFEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final protocolo = await _service.updateProtocoloIATF(event.id, event.protocolo);
      emit(ProtocoloIATFUpdated(protocolo));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onDeleteProtocoloIATF(DeleteProtocoloIATFEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      await _service.deleteProtocoloIATF(event.id);
      emit(ProtocoloIATFDeleted(event.id));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  // Relatórios handlers
  Future<void> _onLoadRelatorioPrenhez(LoadRelatorioPrenhezEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final relatorio = await _service.getRelatorioPrenhez(
        estacaoMontaId: event.estacaoMontaId,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );
      emit(RelatorioPrenhezLoaded(relatorio));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onLoadEstatisticasReproducao(LoadEstatisticasReproducaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final estatisticas = await _service.getEstatisticasReproducao(
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );
      emit(EstatisticasReproducaoLoaded(estatisticas));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onLoadResumoReproducao(LoadResumoReproducaoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ResumoReproducaoLoading());
    try {
      final resumo = await _service.getResumoReproducao();
      emit(ResumoReproducaoLoaded(resumo));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onLoadInseminacoesPendenteDiagnostico(LoadInseminacoesPendenteDiagnosticoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final inseminacoes = await _service.getInseminacoesPendenteDiagnostico();
      emit(InseminacoesPendenteDiagnosticoLoaded(inseminacoes));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }

  Future<void> _onLoadGestacoesPendenteParto(LoadGestacoesPendentePartoEvent event, Emitter<ReproducaoState> emit) async {
    emit(ReproducaoLoading());
    try {
      final gestacoes = await _service.getGestacoesPendenteParto();
      emit(GestacoesPendentePartoLoaded(gestacoes));
    } catch (e) {
      emit(ReproducaoError(e.toString()));
    }
  }
}
