import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/services/fazenda_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'fazenda_events.dart';
part 'fazenda_state.dart';

class FazendaBloc extends Bloc<FazendaEvent, FazendaState> {
  final FazendaService service;

  FazendaBloc({required this.service}) : super(const FazendaState()) {
    on<CreateFazendaEvent>(_onCreateEvent);
    on<UpdateFazendaEvent>(_onUpdateEvent);
    on<DeleteFazendaEvent>(_onDeleteEvent);
    on<ListFazendaEvent>(_onListEvent);
    on<NextPageFazendaEvent>(_onNextPageFazendaEvent);
    on<UpdateLoadedFazendaEvent>(_onUpdateLoadedFazendaEvent);
    on<FazendaDetailEvent>(_onFazendaDetailEvent);
  }

  Future<void> _onCreateEvent(
    CreateFazendaEvent event,
    Emitter<FazendaState> emit,
  ) async {
    emit(state.copyWith(status: () => FazendaStatus.loading));
    try {
      await service.createEntity(entity: event.entity);
      emit(state.copyWith(status: () => FazendaStatus.created));
    } catch (e) {
      emit(state.copyWith(status: () => FazendaStatus.failure));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateFazendaEvent event,
    Emitter<FazendaState> emit,
  ) async {
    emit(state.copyWith(status: () => FazendaStatus.loading));
    try {
      await service.updateEntity(entity: event.entity);
      emit(state.copyWith(status: () => FazendaStatus.updated));
    } catch (e) {
      emit(state.copyWith(status: () => FazendaStatus.failure));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteFazendaEvent event,
    Emitter<FazendaState> emit,
  ) async {
    emit(state.copyWith(status: () => FazendaStatus.loading));
    try {
      await service.deleteEntity(entity: event.entity);
      emit(state.copyWith(status: () => FazendaStatus.success));
    } catch (e) {
      emit(state.copyWith(status: () => FazendaStatus.failure));
    }
  }

  Future<void> _onListEvent(
    ListFazendaEvent event,
    Emitter<FazendaState> emit,
  ) async {
    emit(
      state.copyWith(
        status: () => FazendaStatus.loading,
        search: () => event.search,
      ),
    );
    try {
      final ListBaseEntity<FazendaEntity> result = await service.listEntities(
        limit: event.limit,
        offset: event.offset,
        search: event.search,
      );
      emit(
        state.copyWith(
          status: () => FazendaStatus.success,
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
      emit(state.copyWith(status: () => FazendaStatus.failure));
    }
  }

  void _onNextPageFazendaEvent(
    NextPageFazendaEvent event,
    Emitter<FazendaState> emit,
  ) {
    if (state.offset >= state.count) return;
    add(
      ListFazendaEvent(
        limit: state.limit,
        offset: state.offset,
        search: state.search,
        isLoadingMore: true,
      ),
    );
  }

  void _onUpdateLoadedFazendaEvent(
    UpdateLoadedFazendaEvent event,
    Emitter<FazendaState> emit,
  ) {
    emit(state.copyWith(entity: () => event.entity));
  }

  void _onFazendaDetailEvent(
    FazendaDetailEvent event,
    Emitter<FazendaState> emit,
  ) async {
    emit(state.copyWith(status: () => FazendaStatus.loading));
    try {
      final FazendaEntity result = await service.getEntity(id: event.id);
      emit(
        state.copyWith(
          status: () => FazendaStatus.success,
          entity: () => result,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: () => FazendaStatus.failure));
    }
  }
}
