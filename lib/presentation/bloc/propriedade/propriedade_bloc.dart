import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/models/propriedade_entity.dart';
import '../../../domain/services/propriedade_service.dart';

part 'propriedade_events.dart';
part 'propriedade_state.dart';

class PropriedadeBloC extends Bloc<PropriedadeEvent, PropriedadeState> {
  final PropriedadeService service;
  PropriedadeEntity? selectedEntity;

  PropriedadeBloC({required this.service}) : super(PropriedadeInitial()) {
    on<ListPropriedadeEvent>(_onListPropriedadeEvent);
    on<CreatePropriedadeEvent>(_onCreatePropriedadeEvent);
    on<UpdatePropriedadeEvent>(_onUpdatePropriedadeEvent);
    on<DeletePropriedadeEvent>(_onDeletePropriedadeEvent);
    on<GetPropriedadeEvent>(_onGetPropriedadeEvent);
    on<UpdateLoadedPropriedadeEvent>(_onUpdateLoadedPropriedadeEvent);
  }

  Future<void> _onListPropriedadeEvent(
    ListPropriedadeEvent event,
    Emitter<PropriedadeState> emit,
  ) async {
    emit(PropriedadeLoading());
    try {
      final entities = await service.listEntities(
        limit: event.limit ?? 20,
        offset: event.offset ?? 0,
        search: event.search,
      );

      final hasReachedMax = entities.length < (event.limit ?? 20);

      emit(PropriedadeListLoaded(
        entities: entities,
        hasReachedMax: hasReachedMax,
        searchTerm: event.search,
      ));
    } catch (e) {
      emit(PropriedadeError(message: 'Erro ao listar propriedades: $e'));
    }
  }

  Future<void> _onCreatePropriedadeEvent(
    CreatePropriedadeEvent event,
    Emitter<PropriedadeState> emit,
  ) async {
    emit(PropriedadeLoading());
    try {
      final result = await service.createEntity(entity: event.entity);
      emit(PropriedadeCreated(entity: result));
    } catch (e) {
      emit(PropriedadeError(message: 'Erro ao criar propriedade: $e'));
    }
  }

  Future<void> _onUpdatePropriedadeEvent(
    UpdatePropriedadeEvent event,
    Emitter<PropriedadeState> emit,
  ) async {
    emit(PropriedadeLoading());
    try {
      final result = await service.updateEntity(entity: event.entity);
      selectedEntity = result;
      emit(PropriedadeUpdated(entity: result));
    } catch (e) {
      emit(PropriedadeError(message: 'Erro ao atualizar propriedade: $e'));
    }
  }

  Future<void> _onDeletePropriedadeEvent(
    DeletePropriedadeEvent event,
    Emitter<PropriedadeState> emit,
  ) async {
    emit(PropriedadeLoading());
    try {
      await service.deleteEntity(id: event.entity.id ?? '');
      emit(PropriedadeDeleted(entity: event.entity));
    } catch (e) {
      emit(PropriedadeError(message: 'Erro ao deletar propriedade: $e'));
    }
  }

  Future<void> _onGetPropriedadeEvent(
    GetPropriedadeEvent event,
    Emitter<PropriedadeState> emit,
  ) async {
    emit(PropriedadeLoading());
    try {
      final result = await service.getEntity(id: event.id);
      selectedEntity = result;
      emit(PropriedadeLoaded(entity: result));
    } catch (e) {
      emit(PropriedadeError(message: 'Erro ao carregar propriedade: $e'));
    }
  }

  void _onUpdateLoadedPropriedadeEvent(
    UpdateLoadedPropriedadeEvent event,
    Emitter<PropriedadeState> emit,
  ) {
    selectedEntity = event.entity;
    if (event.entity != null) {
      emit(PropriedadeLoaded(entity: event.entity!));
    } else {
      emit(PropriedadeInitial());
    }
  }
}
