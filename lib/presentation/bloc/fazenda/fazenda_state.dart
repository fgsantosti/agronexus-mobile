part of 'fazenda_bloc.dart';

enum FazendaStatus { initial, loading, success, failure, created, updated }

class FazendaState extends Equatable {
  final FazendaStatus status;
  final List<FazendaEntity> entities;
  final FazendaEntity entity;
  final String? errorMessage;
  final int limit;
  final int offset;
  final int count;
  final String? search;

  const FazendaState({
    this.status = FazendaStatus.initial,
    this.entities = const [],
    this.entity = const FazendaEntity.empty(),
    this.errorMessage,
    this.limit = 20,
    this.offset = 0,
    this.count = 0,
    this.search,
  });

  FazendaState copyWith({
    AgroNexusGetter<FazendaStatus>? status,
    AgroNexusGetter<List<FazendaEntity>>? entities,
    AgroNexusGetter<FazendaEntity>? entity,
    AgroNexusGetter<String?>? errorMessage,
    AgroNexusGetter<int>? limit,
    AgroNexusGetter<int>? offset,
    AgroNexusGetter<int>? count,
    AgroNexusGetter<String?>? search,
  }) {
    return FazendaState(
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
