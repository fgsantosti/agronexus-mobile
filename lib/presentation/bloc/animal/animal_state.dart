part of 'animal_bloc.dart';

enum AnimalStatus { initial, loading, success, failure, created, updated }

class AnimalState extends Equatable {
  final AnimalStatus status;
  final List<AnimalEntity> entities;
  final AnimalEntity? entity;
  final String? errorMessage;
  final int limit;
  final int offset;
  final int count;
  final String? search;

  const AnimalState({
    this.status = AnimalStatus.initial,
    this.entities = const [],
    this.entity,
    this.errorMessage,
    this.limit = 20,
    this.offset = 0,
    this.count = 0,
    this.search,
  });

  AnimalState copyWith({
    AgroNexusGetter<AnimalStatus>? status,
    AgroNexusGetter<List<AnimalEntity>>? entities,
    AgroNexusGetter<AnimalEntity?>? entity,
    AgroNexusGetter<String?>? errorMessage,
    AgroNexusGetter<int>? limit,
    AgroNexusGetter<int>? offset,
    AgroNexusGetter<int>? count,
    AgroNexusGetter<String?>? search,
  }) {
    return AnimalState(
      status: status != null ? status() : this.status,
      entities: entities != null ? entities() : this.entities,
      entity: entity != null ? entity() : this.entity,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      limit: limit != null ? limit() : this.limit,
      offset: offset != null ? offset() : this.offset,
      count: count != null ? count() : this.count,
      search: search != null ? search() : this.search,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ...entities,
        entity,
        errorMessage,
        limit,
        offset,
        count,
        search,
      ];
}
