import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/lote_service.dart';
import 'package:agronexus/presentation/bloc/lote/lote_events.dart';
import 'package:agronexus/presentation/bloc/lote/lote_state.dart';

class LoteBloc extends Bloc<LoteEvent, LoteState> {
  final LoteService _loteService;

  LoteBloc(this._loteService) : super(LoteInitial()) {
    on<LoadLotesEvent>(_onLoadLotes);
    on<CreateLoteEvent>(_onCreateLote);
    on<UpdateLoteEvent>(_onUpdateLote);
    on<DeleteLoteEvent>(_onDeleteLote);
  }

  Future<void> _onLoadLotes(
    LoadLotesEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(LoteLoading());
    try {
      final lotes = await _loteService.getLotes(search: event.search);
      emit(LotesLoaded(lotes));
    } catch (e) {
      emit(LoteError('Erro ao carregar lotes: ${e.toString()}'));
    }
  }

  Future<void> _onCreateLote(
    CreateLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(LoteLoading());
    try {
      await _loteService.createLote(event.lote);
      emit(LoteCreated());
    } catch (e) {
      emit(LoteError('Erro ao criar lote: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateLote(
    UpdateLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(LoteLoading());
    try {
      await _loteService.updateLote(event.lote.id!, event.lote);
      emit(LoteUpdated());
    } catch (e) {
      emit(LoteError('Erro ao atualizar lote: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteLote(
    DeleteLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(LoteLoading());
    try {
      await _loteService.deleteLote(event.loteId);
      emit(LoteDeleted());
    } catch (e) {
      emit(LoteError('Erro ao excluir lote: ${e.toString()}'));
    }
  }
}
