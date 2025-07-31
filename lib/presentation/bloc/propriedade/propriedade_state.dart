part of 'propriedade_bloc.dart';

abstract class PropriedadeState extends Equatable {
  const PropriedadeState();

  @override
  List<Object?> get props => [];
}

class PropriedadeInitial extends PropriedadeState {}

class PropriedadeLoading extends PropriedadeState {}

class PropriedadeListLoaded extends PropriedadeState {
  final List<PropriedadeEntity> entities;
  final bool hasReachedMax;
  final String? searchTerm;

  const PropriedadeListLoaded({
    required this.entities,
    required this.hasReachedMax,
    this.searchTerm,
  });

  PropriedadeListLoaded copyWith({
    List<PropriedadeEntity>? entities,
    bool? hasReachedMax,
    String? searchTerm,
  }) {
    return PropriedadeListLoaded(
      entities: entities ?? this.entities,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [entities, hasReachedMax, searchTerm];
}

class PropriedadeLoaded extends PropriedadeState {
  final PropriedadeEntity entity;

  const PropriedadeLoaded({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class PropriedadeCreated extends PropriedadeState {
  final PropriedadeEntity entity;

  const PropriedadeCreated({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class PropriedadeUpdated extends PropriedadeState {
  final PropriedadeEntity entity;

  const PropriedadeUpdated({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class PropriedadeDeleted extends PropriedadeState {
  final PropriedadeEntity entity;

  const PropriedadeDeleted({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class PropriedadeError extends PropriedadeState {
  final String message;

  const PropriedadeError({required this.message});

  @override
  List<Object?> get props => [message];
}
