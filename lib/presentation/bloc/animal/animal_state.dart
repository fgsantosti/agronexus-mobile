import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/opcoes_cadastro_animal.dart';

abstract class AnimalState extends Equatable {
  const AnimalState();

  @override
  List<Object?> get props => [];
}

class AnimalInitial extends AnimalState {}

class AnimalLoading extends AnimalState {}

class AnimaisLoaded extends AnimalState {
  final List<AnimalEntity> animais;
  final int count;
  final bool hasMore;

  const AnimaisLoaded({
    required this.animais,
    required this.count,
    required this.hasMore,
  });

  @override
  List<Object> get props => [animais, count, hasMore];
}

class AnimalDetailLoaded extends AnimalState {
  final AnimalEntity animal;

  const AnimalDetailLoaded(this.animal);

  @override
  List<Object> get props => [animal];
}

class AnimalCreated extends AnimalState {
  final AnimalEntity animal;

  const AnimalCreated(this.animal);

  @override
  List<Object> get props => [animal];
}

class AnimalUpdated extends AnimalState {
  final AnimalEntity animal;

  const AnimalUpdated(this.animal);

  @override
  List<Object> get props => [animal];
}

class AnimalDeleted extends AnimalState {
  final String id;

  const AnimalDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class OpcoesCadastroLoaded extends AnimalState {
  final OpcoesCadastroAnimal opcoes;

  const OpcoesCadastroLoaded(this.opcoes);

  @override
  List<Object> get props => [opcoes];
}

class RacasLoaded extends AnimalState {
  final List<RacaAnimal> racas;

  const RacasLoaded(this.racas);

  @override
  List<Object> get props => [racas];
}

class CategoriasLoaded extends AnimalState {
  final List<String> categorias;

  const CategoriasLoaded(this.categorias);

  @override
  List<Object> get props => [categorias];
}

class FilhosDaMaeLoaded extends AnimalState {
  final List<AnimalEntity> filhos;
  final String maeId;

  const FilhosDaMaeLoaded({
    required this.filhos,
    required this.maeId,
  });

  @override
  List<Object> get props => [filhos, maeId];
}

class AllAnimaisForExportLoaded extends AnimalState {
  final List<AnimalEntity> animais;

  const AllAnimaisForExportLoaded({
    required this.animais,
  });

  @override
  List<Object> get props => [animais];
}

class AnimalError extends AnimalState {
  final String message;

  const AnimalError(this.message);

  @override
  List<Object> get props => [message];
}
