import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/animal_service.dart';
import 'animal_event.dart';
import 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  final AnimalService _animalService;
  List<dynamic> _allAnimais = [];
  int _currentOffset = 0;
  static const int _limit = 20;

  AnimalBloc(this._animalService) : super(AnimalInitial()) {
    on<LoadAnimaisEvent>(_onLoadAnimais);
    on<LoadAnimalDetailEvent>(_onLoadAnimalDetail);
    on<CreateAnimalEvent>(_onCreateAnimal);
    on<UpdateAnimalEvent>(_onUpdateAnimal);
    on<DeleteAnimalEvent>(_onDeleteAnimal);
    on<LoadOpcoesCadastroEvent>(_onLoadOpcoesCadastro);
    on<LoadRacasByEspecieEvent>(_onLoadRacasByEspecie);
    on<LoadCategoriasByEspecieEvent>(_onLoadCategoriasByEspecie);
    on<NextPageAnimaisEvent>(_onNextPageAnimais);
  }

  Future<void> _onLoadAnimais(
    LoadAnimaisEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      emit(AnimalLoading());

      final animais = await _animalService.getAnimais(
        limit: event.limit,
        offset: event.offset,
        search: event.search,
        especieId: event.especieId,
        status: event.status,
        propriedadeId: event.propriedadeId,
      );

      if (event.offset == 0) {
        _allAnimais = List.from(animais);
        _currentOffset = 0;
      } else {
        _allAnimais.addAll(animais);
      }

      _currentOffset += animais.length;

      emit(AnimaisLoaded(
        animais: List.from(_allAnimais),
        count: _allAnimais.length,
        hasMore: animais.length == event.limit,
      ));
    } catch (e) {
      emit(AnimalError('Erro ao carregar animais: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAnimalDetail(
    LoadAnimalDetailEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      emit(AnimalLoading());

      final animal = await _animalService.getAnimal(event.id);

      emit(AnimalDetailLoaded(animal));
    } catch (e) {
      emit(AnimalError('Erro ao carregar detalhes do animal: ${e.toString()}'));
    }
  }

  Future<void> _onCreateAnimal(
    CreateAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      emit(AnimalLoading());

      final animal = await _animalService.createAnimal(event.animal);

      emit(AnimalCreated(animal));
    } catch (e) {
      emit(AnimalError('Erro ao criar animal: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAnimal(
    UpdateAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      emit(AnimalLoading());

      final animal = await _animalService.updateAnimal(event.id, event.animal);

      emit(AnimalUpdated(animal));
    } catch (e) {
      emit(AnimalError('Erro ao atualizar animal: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAnimal(
    DeleteAnimalEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      emit(AnimalLoading());

      await _animalService.deleteAnimal(event.id);

      emit(AnimalDeleted(event.id));
    } catch (e) {
      emit(AnimalError('Erro ao deletar animal: ${e.toString()}'));
    }
  }

  Future<void> _onLoadOpcoesCadastro(
    LoadOpcoesCadastroEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      emit(AnimalLoading());

      final opcoes = await _animalService.getOpcoesCadastro();

      emit(OpcoesCadastroLoaded(opcoes));
    } catch (e) {
      emit(AnimalError('Erro ao carregar opções de cadastro: ${e.toString()}'));
    }
  }

  Future<void> _onLoadRacasByEspecie(
    LoadRacasByEspecieEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      final racas = await _animalService.getRacasByEspecie(event.especieId);

      emit(RacasLoaded(racas));
    } catch (e) {
      emit(AnimalError('Erro ao carregar raças: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCategoriasByEspecie(
    LoadCategoriasByEspecieEvent event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      final categorias = await _animalService.getCategoriasByEspecie(event.especieId);

      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(AnimalError('Erro ao carregar categorias: ${e.toString()}'));
    }
  }

  Future<void> _onNextPageAnimais(
    NextPageAnimaisEvent event,
    Emitter<AnimalState> emit,
  ) async {
    if (state is AnimaisLoaded) {
      final currentState = state as AnimaisLoaded;
      if (currentState.hasMore) {
        add(LoadAnimaisEvent(offset: _currentOffset, limit: _limit));
      }
    }
  }
}
