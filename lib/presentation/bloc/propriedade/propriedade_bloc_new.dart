import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/propriedade_service_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';

class PropriedadeBlocNew extends Bloc<PropriedadeEvent, PropriedadeState> {
  final PropriedadeServiceNew _service;

  PropriedadeBlocNew(this._service) : super(PropriedadeInitial()) {
    on<LoadPropriedadesEvent>(_onLoadPropriedades);
    on<CreatePropriedadeEvent>(_onCreatePropriedade);
    on<UpdatePropriedadeEvent>(_onUpdatePropriedade);
    on<DeletePropriedadeEvent>(_onDeletePropriedade);
    on<GetPropriedadeEvent>(_onGetPropriedade);
  }

  Future<void> _onLoadPropriedades(LoadPropriedadesEvent event, Emitter<PropriedadeState> emit) async {
    emit(PropriedadeLoading());
    try {
      final propriedades = await _service.getPropriedades(
        limit: event.limit,
        offset: event.offset,
        search: event.search,
      );
      emit(PropriedadesLoaded(propriedades));
    } catch (e) {
      emit(PropriedadeError(e.toString()));
    }
  }

  Future<void> _onCreatePropriedade(CreatePropriedadeEvent event, Emitter<PropriedadeState> emit) async {
    emit(PropriedadeLoading());
    try {
      final propriedade = await _service.createPropriedade(event.propriedade);
      emit(PropriedadeCreated(propriedade));
    } catch (e) {
      emit(PropriedadeError(e.toString()));
    }
  }

  Future<void> _onUpdatePropriedade(UpdatePropriedadeEvent event, Emitter<PropriedadeState> emit) async {
    emit(PropriedadeLoading());
    try {
      final propriedade = await _service.updatePropriedade(event.id, event.propriedade);
      emit(PropriedadeUpdated(propriedade));
    } catch (e) {
      emit(PropriedadeError(e.toString()));
    }
  }

  Future<void> _onDeletePropriedade(DeletePropriedadeEvent event, Emitter<PropriedadeState> emit) async {
    emit(PropriedadeLoading());
    try {
      await _service.deletePropriedade(event.id);
      emit(PropriedadeDeleted(event.id));
    } catch (e) {
      emit(PropriedadeError(e.toString()));
    }
  }

  Future<void> _onGetPropriedade(GetPropriedadeEvent event, Emitter<PropriedadeState> emit) async {
    emit(PropriedadeLoading());
    try {
      final propriedade = await _service.getPropriedade(event.id);
      emit(PropriedadeLoaded(propriedade));
    } catch (e) {
      emit(PropriedadeError(e.toString()));
    }
  }
}
