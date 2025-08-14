import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/animal_entity.dart';

abstract class AnimalEvent extends Equatable {
  const AnimalEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnimaisEvent extends AnimalEvent {
  final int limit;
  final int offset;
  final String? search;
  final String? especieId;
  final String? status;
  final String? propriedadeId;

  const LoadAnimaisEvent({
    this.limit = 20,
    this.offset = 0,
    this.search,
    this.especieId,
    this.status,
    this.propriedadeId,
  });

  @override
  List<Object?> get props => [limit, offset, search, especieId, status, propriedadeId];
}

class LoadAnimalDetailEvent extends AnimalEvent {
  final String id;

  const LoadAnimalDetailEvent(this.id);

  @override
  List<Object> get props => [id];
}

class CreateAnimalEvent extends AnimalEvent {
  final AnimalEntity animal;

  const CreateAnimalEvent(this.animal);

  @override
  List<Object> get props => [animal];
}

class UpdateAnimalEvent extends AnimalEvent {
  final String id;
  final AnimalEntity animal;

  const UpdateAnimalEvent(this.id, this.animal);

  @override
  List<Object> get props => [id, animal];
}

class DeleteAnimalEvent extends AnimalEvent {
  final String id;

  const DeleteAnimalEvent(this.id);

  @override
  List<Object> get props => [id];
}

class LoadOpcoesCadastroEvent extends AnimalEvent {
  const LoadOpcoesCadastroEvent();
}

class LoadRacasByEspecieEvent extends AnimalEvent {
  final String especieId;

  const LoadRacasByEspecieEvent(this.especieId);

  @override
  List<Object> get props => [especieId];
}

class LoadCategoriasByEspecieEvent extends AnimalEvent {
  final String especieId;

  const LoadCategoriasByEspecieEvent(this.especieId);

  @override
  List<Object> get props => [especieId];
}

class LoadFilhosDaMaeEvent extends AnimalEvent {
  final String maeId;
  final String? status;

  const LoadFilhosDaMaeEvent(this.maeId, {this.status = 'ativo'});

  @override
  List<Object?> get props => [maeId, status];
}

class NextPageAnimaisEvent extends AnimalEvent {
  const NextPageAnimaisEvent();
}
