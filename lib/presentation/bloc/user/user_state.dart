part of 'user_bloc.dart';

enum UserStatus {
  initial,
  loading,
  success,
  failure,
  passwordChanged,
  updated,
  created,
  deleted,
}

class UserState extends Equatable {
  final UserStatus status;
  final UserEntity? entity;
  final List<UserEntity> entities;
  final String? errorMessage;
  final int limit;
  final int offset;
  final int count;
  final String? profile;
  final String? search;

  const UserState({
    this.status = UserStatus.initial,
    this.entity,
    this.errorMessage,
    this.entities = const [],
    this.limit = 20,
    this.offset = 0,
    this.count = 0,
    this.profile,
    this.search,
  });

  @override
  List<Object?> get props => [
        status,
        entity,
        errorMessage,
        ...entities,
        limit,
        offset,
        profile,
        search,
        count,
      ];

  UserState copyWith({
    AgroNexusGetter<UserStatus>? status,
    AgroNexusGetter<UserEntity?>? entity,
    AgroNexusGetter<List<UserEntity>>? entities,
    AgroNexusGetter<String?>? errorMessage,
    AgroNexusGetter<int>? limit,
    AgroNexusGetter<int>? offset,
    AgroNexusGetter<String?>? profile,
    AgroNexusGetter<String?>? search,
    AgroNexusGetter<int>? count,
  }) {
    return UserState(
      status: status != null ? status() : this.status,
      entity: entity != null ? entity() : this.entity,
      entities: entities != null ? entities() : this.entities,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      limit: limit != null ? limit() : this.limit,
      offset: offset != null ? offset() : this.offset,
      profile: profile != null ? profile() : this.profile,
      search: search != null ? search() : this.search,
      count: count != null ? count() : this.count,
    );
  }
}
