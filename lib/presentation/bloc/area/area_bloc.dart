import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/area_service.dart';
import 'area_event.dart';
import 'area_state.dart';

class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final AreaService service;
  AreaBloc(this.service) : super(AreaInitial()) {
    on<LoadAreasEvent>(_onLoadAreas);
    on<CreateAreaEvent>(_onCreateArea);
    on<UpdateAreaEvent>(_onUpdateArea);
    on<DeleteAreaEvent>(_onDeleteArea);
  }

  Future<void> _onLoadAreas(LoadAreasEvent event, Emitter<AreaState> emit) async {
    emit(AreaLoading());
    try {
      final areas = await service.getAreas(propriedadeId: event.propriedadeId);
      emit(AreasLoaded(areas));
    } catch (e) {
      emit(AreaError(e.toString()));
    }
  }

  Future<void> _onCreateArea(CreateAreaEvent event, Emitter<AreaState> emit) async {
    emit(AreaLoading());
    try {
      final created = await service.createArea(event.area);
      emit(AreaCreated(created));
    } catch (e) {
      emit(AreaError(e.toString()));
    }
  }

  Future<void> _onUpdateArea(UpdateAreaEvent event, Emitter<AreaState> emit) async {
    emit(AreaLoading());
    try {
      final updated = await service.updateArea(event.id, event.area);
      emit(AreaUpdated(updated));
    } catch (e) {
      emit(AreaError(e.toString()));
    }
  }

  Future<void> _onDeleteArea(DeleteAreaEvent event, Emitter<AreaState> emit) async {
    emit(AreaLoading());
    try {
      await service.deleteArea(event.id);
      emit(AreaDeleted(event.id));
    } catch (e) {
      emit(AreaError(e.toString()));
    }
  }
}
