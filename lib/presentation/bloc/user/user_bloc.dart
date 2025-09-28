import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/services/user_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_events.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(const UserState()) {
    on<CreateUserEvent>(_onCreateUserEvent);
    on<UpdateUserEvent>(_onUpdateUserEvent);
    on<DeleteUserEvent>(_onDeleteUserEvent);
    on<GetSelfUserEvent>(_onGetSelfUserEvent);
    on<ChangePasswordEvent>(_onChangePasswordEvent);
    on<UpdateLoadedUserEvent>(_onUpdateLoadedUserEvent);
    on<ListUsersEvent>(_onListAllUsersEvent);
    on<NextPageUserEvent>(_onNextPageUserEvent);
    on<LogoutUserEvent>(_onLogoutUserEvent);
  }

  Future<void> _onCreateUserEvent(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: () => UserStatus.loading));
    try {
      UserEntity user = await userService.createUser(
        user: event.user,
        password: event.password,
        password2: event.password2,
      );
      emit(state.copyWith(status: () => UserStatus.created, entity: () => user));
    } catch (e) {
      String errorMessage = 'Não foi possível criar usuário';
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      emit(state.copyWith(
        status: () => UserStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }

  Future<void> _onUpdateUserEvent(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: () => UserStatus.loading));
    try {
      UserEntity user = await userService.updateUser(
        user: event.user,
      );
      emit(state.copyWith(status: () => UserStatus.updated, entity: () => user));
    } catch (e) {
      String errorMessage = 'Não foi possível atualizar usuário';
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      emit(state.copyWith(
        status: () => UserStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }

  Future<void> _onDeleteUserEvent(DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: () => UserStatus.loading));
    try {
      await userService.deleteUser(event.id);
      emit(state.copyWith(status: () => UserStatus.deleted));
    } catch (e) {
      String errorMessage = 'Não foi possível excluir usuário';
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      emit(state.copyWith(
        status: () => UserStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }

  Future<void> _onGetSelfUserEvent(GetSelfUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: () => UserStatus.loading));
    try {
      UserEntity user = await userService.getSelfUser();
      emit(state.copyWith(status: () => UserStatus.initial, entity: () => user));
    } catch (e) {
      String errorMessage = 'Não foi possível carregar usuário';
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      emit(state.copyWith(
        status: () => UserStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }

  Future<void> _onChangePasswordEvent(ChangePasswordEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: () => UserStatus.loading));
    try {
      await userService.updatePassword(
        lastPassword: event.lastPassword,
        password: event.password,
        password2: event.password2,
      );
      emit(state.copyWith(status: () => UserStatus.passwordChanged));
    } catch (e) {
      String errorMessage = 'Não foi possível alterar senha';
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      emit(state.copyWith(
        status: () => UserStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }

  void _onUpdateLoadedUserEvent(
    UpdateLoadedUserEvent event,
    Emitter<UserState> emit,
  ) {
    emit(
      state.copyWith(entity: () => event.user, status: () => UserStatus.initial),
    );
  }

  Future<void> _onListAllUsersEvent(
    ListUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        status: () => UserStatus.loading,
        profile: () => event.profile,
        search: () => event.search,
      ),
    );
    try {
      ListBaseEntity<UserEntity> result = await userService.listAllUsers(
        limit: event.limit,
        offset: event.offset,
        profile: event.profile ?? state.profile,
        search: event.search ?? state.search,
      );
      emit(
        state.copyWith(
          status: () => UserStatus.success,
          entities: () => event.isLoadingMore ? [...state.entities, ...result.results] : result.results,
          limit: () => event.limit,
          offset: () => event.offset + event.limit,
          profile: () => event.profile ?? state.profile,
          search: () => event.search ?? state.search,
          count: () => result.count,
        ),
      );
    } catch (e) {
      String errorMessage = 'Não foi possível carregar lista de usuários';
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      emit(state.copyWith(
        status: () => UserStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }

  void _onNextPageUserEvent(
    NextPageUserEvent event,
    Emitter<UserState> emit,
  ) {
    if (state.offset >= state.count) return;
    add(
      ListUsersEvent(
        limit: state.limit,
        offset: state.offset,
        profile: state.profile,
        search: state.search,
        isLoadingMore: true,
      ),
    );
  }

  Future<void> _onLogoutUserEvent(
    LogoutUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: () => UserStatus.loading));
    try {
      await userService.logout();
      emit(state.copyWith(
        status: () => UserStatus.loggedOut,
        entity: () => null,
        entities: () => [],
      ));
    } catch (e) {
      String errorMessage = 'Não foi possível sair da conta';
      if (e is AgroNexusException) {
        errorMessage = e.message;
      }
      emit(state.copyWith(
        status: () => UserStatus.failure,
        errorMessage: () => errorMessage,
      ));
    }
  }
}
