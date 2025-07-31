part of 'lote_bloc.dart';

enum LoteStatus { initial, loading, success, failure, created, updated }

class LoteState extends Equatable {
  final LoteStatus status;
  final List<LoteEntity> entities;
  final LoteEntity? entity;
  final String? errorMessage;
  final int limit;
  final int offset;
  final int count;
  final String? search;

  const LoteState({
    this.status = LoteStatus.initial,
    this.entities = const [],
    this.entity,
    this.errorMessage,
    this.limit = 20,
    this.offset = 0,
    this.count = 0,
    this.search,
  });

  LoteState copyWith({
    AgroNexusGetter<LoteStatus>? status,
    AgroNexusGetter<List<LoteEntity>>? entities,
    AgroNexusGetter<LoteEntity?>? entity,
    AgroNexusGetter<String?>? errorMessage,
    AgroNexusGetter<int>? limit,
    AgroNexusGetter<int>? offset,
    AgroNexusGetter<int>? count,
    AgroNexusGetter<String?>? search,
  }) {
    return LoteState(
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
