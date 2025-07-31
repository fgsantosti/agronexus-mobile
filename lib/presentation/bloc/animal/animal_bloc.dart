import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/services/animal_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'animal_events.dart';
part 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  final AnimalService service;

  AnimalBloc({required this.service}) : super(const AnimalState()) {
    on<CreateAnimalEvent>(_onCreateEvent);
    on<UpdateAnimalEvent>(_onUpdateEvent);
    on<DeleteAnimalEvent>(_onDeleteEvent);
    on<ListAnimalEvent>(_onListEvent);
    on<NextPageAnimalEvent>(_onNextPageAnimalEvent);
    on<UpdateLoadedAnimalEvent>(_onUpdateLoadedAnimalEvent);
    on<AnimalDetailEvent>(_onAnimalDetailEvent);
  }

  Future<void> _onCreateEvent(
    CreateAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(state.copyWith(status: () => AnimalStatus.loading));
    try {
      await service.createEntity(entity: event.entity);
      emit(state.copyWith(status: () => AnimalStatus.created));
    } catch (e) {
      emit(state.copyWith(status: () => AnimalStatus.failure));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(state.copyWith(status: () => AnimalStatus.loading));
    try {
      await service.updateEntity(entity: event.entity);
      emit(state.copyWith(status: () => AnimalStatus.updated));
    } catch (e) {
      emit(state.copyWith(status: () => AnimalStatus.failure));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(state.copyWith(status: () => AnimalStatus.loading));
    try {
      await service.deleteEntity(entity: event.entity);
      emit(state.copyWith(status: () => AnimalStatus.success));
    } catch (e) {
      emit(state.copyWith(status: () => AnimalStatus.failure));
    }
  }

  Future<void> _onListEvent(
    ListAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(
      state.copyWith(
        status: () => AnimalStatus.loading,
        search: () => event.search,
      ),
    );
    try {
      final ListBaseEntity<AnimalEntity> result = await service.listEntities(
        limit: event.limit,
        offset: event.offset,
        search: event.search,
      );
      emit(
        state.copyWith(
          status: () => AnimalStatus.success,
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
      emit(state.copyWith(status: () => AnimalStatus.failure));
    }
  }

  void _onNextPageAnimalEvent(
    NextPageAnimalEvent event,
    Emitter<AnimalState> emit,
  ) {
    if (state.offset >= state.count) return;
    add(
      ListAnimalEvent(
        limit: state.limit,
        offset: state.offset,
        search: state.search,
        isLoadingMore: true,
      ),
    );
  }

  void _onUpdateLoadedAnimalEvent(
    UpdateLoadedAnimalEvent event,
    Emitter<AnimalState> emit,
  ) {
    emit(state.copyWith(entity: () => event.entity));
  }

  void _onAnimalDetailEvent(
    AnimalDetailEvent event,
    Emitter<AnimalState> emit,
  ) async {
    emit(state.copyWith(status: () => AnimalStatus.loading));
    try {
      final AnimalEntity result = await service.getEntity(id: event.id);
      emit(
        state.copyWith(
          status: () => AnimalStatus.success,
          entity: () => result,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: () => AnimalStatus.failure));
    }
  }
}
