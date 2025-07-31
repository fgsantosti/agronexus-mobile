part of 'animal_bloc.dart';

abstract class AnimalEvent extends Equatable {
  const AnimalEvent();
}

class CreateAnimalEvent extends AnimalEvent {
  final AnimalEntity entity;
  const CreateAnimalEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class UpdateAnimalEvent extends AnimalEvent {
  final AnimalEntity entity;
  const UpdateAnimalEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class DeleteAnimalEvent extends AnimalEvent {
  final AnimalEntity entity;
  const DeleteAnimalEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class ListAnimalEvent extends AnimalEvent {
  final int limit;
  final int offset;
  final String? search;
  final bool isLoadingMore;

  const ListAnimalEvent({
    this.limit = 20,
    this.offset = 0,
    this.search,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [limit, offset, search, isLoadingMore];
}

class AnimalDetailEvent extends AnimalEvent {
  final String id;
  const AnimalDetailEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class NextPageAnimalEvent extends AnimalEvent {
  const NextPageAnimalEvent();

  @override
  List<Object?> get props => [];
}

class UpdateLoadedAnimalEvent extends AnimalEvent {
  final AnimalEntity entity;
  const UpdateLoadedAnimalEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}
