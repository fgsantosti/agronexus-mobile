import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/domain/services/lote_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'lote_events.dart';
part 'lote_state.dart';

class LoteBloc extends Bloc<LoteEvent, LoteState> {
  final LoteService service;

  LoteBloc({required this.service}) : super(const LoteState()) {
    on<CreateLoteEvent>(_onCreateEvent);
    on<UpdateLoteEvent>(_onUpdateEvent);
    on<DeleteLoteEvent>(_onDeleteEvent);
    on<ListLoteEvent>(_onListEvent);
    on<NextPageLoteEvent>(_onNextPageLoteEvent);
    on<UpdateLoadedLoteEvent>(_onUpdateLoadedLoteEvent);
    on<LoteDetailEvent>(_onLoteDetailEvent);
  }

  Future<void> _onCreateEvent(
    CreateLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: () => LoteStatus.loading));
    try {
      await service.createEntity(entity: event.entity);
      emit(state.copyWith(status: () => LoteStatus.created));
    } catch (e) {
      emit(state.copyWith(status: () => LoteStatus.failure));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: () => LoteStatus.loading));
    try {
      await service.updateEntity(entity: event.entity);
      emit(state.copyWith(status: () => LoteStatus.updated));
    } catch (e) {
      emit(state.copyWith(status: () => LoteStatus.failure));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: () => LoteStatus.loading));
    try {
      await service.deleteEntity(entity: event.entity);
      emit(state.copyWith(status: () => LoteStatus.success));
    } catch (e) {
      emit(state.copyWith(status: () => LoteStatus.failure));
    }
  }

  Future<void> _onListEvent(
    ListLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(
      state.copyWith(
        status: () => LoteStatus.loading,
        search: () => event.search,
      ),
    );
    try {
      final ListBaseEntity<LoteEntity> result = await service.listEntities(
        limit: event.limit,
        offset: event.offset,
        search: event.search,
      );
      emit(
        state.copyWith(
          status: () => LoteStatus.success,
          entities: () => event.isLoadingMore
              ? [...state.entities, ...result.results]
              : result.results,
          limit: () => event.limit,
          offset: () => event.offset + event.limit,
          search: () => event.search ?? state.search,
          count: () => result.count,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: () => LoteStatus.failure));
    }
  }

  void _onNextPageLoteEvent(
    NextPageLoteEvent event,
    Emitter<LoteState> emit,
  ) {
    if (state.offset >= state.count) return;
    add(
      ListLoteEvent(
        limit: state.limit,
        offset: state.offset,
        search: state.search,
        isLoadingMore: true,
      ),
    );
  }

  void _onUpdateLoadedLoteEvent(
    UpdateLoadedLoteEvent event,
    Emitter<LoteState> emit,
  ) {
    emit(state.copyWith(entity: () => event.entity));
  }

  void _onLoteDetailEvent(
    LoteDetailEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: () => LoteStatus.loading));
    try {
      final LoteEntity result = await service.getEntity(id: event.id);
      emit(
        state.copyWith(
          status: () => LoteStatus.success,
          entity: () => result,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: () => LoteStatus.failure));
    }
  }
}
