part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}

class CreateUserEvent extends UserEvent {
  final UserEntity user;
  final String password;
  final String password2;

  const CreateUserEvent({
    required this.user,
    required this.password,
    required this.password2,
  });

  @override
  List<Object?> get props => [user, password, password2];
}

class ChangePasswordEvent extends UserEvent {
  final String lastPassword;
  final String password;
  final String password2;

  const ChangePasswordEvent({
    required this.password,
    required this.password2,
    required this.lastPassword,
  });

  @override
  List<Object?> get props => [password, password2, lastPassword];
}

class UpdateUserEvent extends UserEvent {
  final UserEntity user;

  const UpdateUserEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

class DeleteUserEvent extends UserEvent {
  final String id;

  const DeleteUserEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class GetSelfUserEvent extends UserEvent {
  const GetSelfUserEvent();

  @override
  List<Object?> get props => [];
}

class ListUsersEvent extends UserEvent {
  final int limit;
  final int offset;
  final String? profile;
  final String? search;
  final bool isLoadingMore;

  const ListUsersEvent({
    this.limit = 20,
    this.offset = 0,
    this.profile,
    this.search,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [limit, offset, profile, search, isLoadingMore];
}

class UpdateLoadedUserEvent extends UserEvent {
  final UserEntity user;

  const UpdateLoadedUserEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

class NextPageUserEvent extends UserEvent {
  const NextPageUserEvent();

  @override
  List<Object?> get props => [];
}
